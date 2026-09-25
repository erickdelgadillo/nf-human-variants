# nf-human-variants

![Version](https://img.shields.io/badge/version-v0.1.0-blue)
![Nextflow](https://img.shields.io/badge/Nextflow-DSL2-23aa62)
![Java](https://img.shields.io/badge/Java-17%2B-orange)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)

A modular Nextflow DSL2 pipeline for learning and implementing a reproducible human germline variant calling workflow.

The project is being developed incrementally, following modern Nextflow and nf-core design principles. The current implementation covers read preprocessing, reference preparation, alignment, BAM processing, and basic alignment quality control.

> [!IMPORTANT]
> This project is intended for research, training, and workflow-development purposes. It is not intended for clinical diagnosis or medical decision-making.

---

## Current workflow

The pipeline currently implements:

```text
Paired-end FASTQ
       │
       ├── FastQC
       │
       ▼
     fastp
       │
       ▼
   BWA-MEM2
       │
       ▼
 samtools sort
       │
       ▼
 samtools index
       │
       ▼
samtools flagstat
```

Reference preparation is performed independently:

```text
Reference FASTA
      │
      ├── BWA-MEM2 index
      ├── samtools faidx
      └── GATK CreateSequenceDictionary
```

This produces the reference files required for downstream alignment and future variant calling.

---

## Architecture

The pipeline uses a modular Nextflow DSL2 structure.

```text
main.nf
    │
    ▼
workflows/
└── nf_human_variants.nf
        │
        ├── PREPARE_REFERENCE
        │
        └── PROCESS_READS
                │
                ▼
          individual modules
```

Current project structure:

```text
nf-human-variants/
├── main.nf
├── nextflow.config
├── conf/
│   └── test.config
├── workflows/
│   └── nf_human_variants.nf
├── subworkflows/
│   └── local/
│       ├── prepare_reference.nf
│       └── process_reads.nf
├── modules/
│   ├── local/
│   │   ├── fastqc.nf
│   │   ├── fastp.nf
│   │   ├── bwa_mem2.nf
│   │   └── bwa_mem2_index.nf
│   └── nf-core/
│       ├── gatk4/
│       └── samtools/
├── docs/
│   └── project-context/
├── data/
├── reference/
├── scripts/
└── results/
```

The top-level `main.nf` acts only as the pipeline entry point.

The main workflow is defined in:

```text
workflows/nf_human_variants.nf
```

while related processes are grouped into reusable subworkflows.

### `PREPARE_REFERENCE`

Prepares the reference genome using:

- BWA-MEM2 indexing
- `samtools faidx`
- GATK `CreateSequenceDictionary`

### `PROCESS_READS`

Performs sample-level processing using:

- FastQC
- fastp
- BWA-MEM2
- samtools sort
- samtools index
- samtools flagstat

Sample metadata are propagated through the workflow using the conventional DSL2 structure:

```text
(meta, data)
```

---

## Requirements

The current development environment uses:

- Nextflow
- Java
- Docker

Software dependencies used by individual processes are provided through containers.

Check your Nextflow installation with:

```bash
nextflow -version
```

Check Docker with:

```bash
docker --version
```

---

## Test profile

A small test dataset is used for development and pipeline validation.

The test configuration is defined in:

```text
conf/test.config
```

Run the test pipeline with:

```bash
nextflow run main.nf -profile test
```

To reuse cached tasks during development:

```bash
nextflow run main.nf -profile test -resume
```

The test profile currently defines:

- synthetic paired-end FASTQ reads
- a small test reference genome
- a dedicated test output directory

This allows the workflow architecture to be tested rapidly without requiring large human sequencing datasets.

Concrete executions and their outcomes should be recorded in:

```text
docs/project-context/TEST_EVIDENCE.md
```

---

## Configuration

General pipeline parameters are defined in:

```text
nextflow.config
```

The current main parameters include:

```nextflow
params {
    reads  = null
    fasta  = null
    outdir = "${projectDir}/results"
}
```

The test profile overrides these parameters with the development dataset.

Execution resources are configured independently from process implementation. For example, memory requirements for GATK and CPU requirements for FastQC are defined through Nextflow configuration rather than by modifying upstream nf-core modules.

---

## nf-core modules

Where suitable, the pipeline uses official nf-core modules.

Currently included nf-core modules include:

- `samtools/sort`
- `samtools/index`
- `samtools/faidx`
- `samtools/flagstat`
- `gatk4/createsequencedictionary`

Local modules are currently used for:

- FastQC
- fastp
- BWA-MEM2
- BWA-MEM2 indexing

Upstream nf-core module code is kept unchanged.

---

## Development status

### Input and preprocessing

- [x] Paired-end FASTQ discovery
- [x] Sample metadata channels
- [x] FastQC
- [x] fastp

### Reference preparation

- [x] BWA-MEM2 reference indexing
- [x] FASTA `.fai` generation
- [x] GATK sequence dictionary generation

### Alignment and BAM processing

- [x] BWA-MEM2 alignment
- [x] BAM sorting
- [x] BAM indexing
- [x] Alignment QC with `samtools flagstat`
- [ ] Additional alignment statistics
- [ ] Duplicate handling

### Variant calling

- [ ] GATK HaplotypeCaller
- [ ] gVCF generation
- [ ] GenotypeGVCFs
- [ ] Variant filtering
- [ ] Variant QC

### Annotation

- [ ] Variant annotation
- [ ] VEP
- [ ] ClinVar integration

### Workflow engineering

- [x] DSL2 modules
- [x] `(meta, data)` channel structure
- [x] Local subworkflows
- [x] Top-level workflow
- [x] Test profile
- [ ] Samplesheet-based input
- [ ] Multi-sample validation
- [ ] Small real human test dataset
- [ ] Automated end-to-end testing
- [ ] Continuous integration
- [ ] Production GRCh38 reference configuration

---

## Planned input model

The current test pipeline discovers paired-end FASTQ files directly.

The next development step is to replace this with a samplesheet-based interface:

```bash
nextflow run main.nf \
    --input samplesheet.csv \
    --outdir results
```

Initial target schema:

```csv
sample,fastq_1,fastq_2
NA12878,path/to/NA12878_R1.fastq.gz,path/to/NA12878_R2.fastq.gz
```

The initial implementation should remain minimal. Additional metadata such as library, lane, platform, and read-group fields should only be added when required by downstream workflow design.

---

## Development roadmap

### NOW

1. Implement validated `samplesheet.csv` input.
2. Define the explicit metadata contract.
3. Validate the workflow with multiple samples.

### NEXT

4. Add reproducible read groups.
5. Implement duplicate handling in a separate BAM-processing unit.
6. Define the `analysis-ready BAM` boundary.
7. Add GATK HaplotypeCaller in gVCF mode.

### LATER

8. Add cohort genotyping with GenotypeGVCFs.
9. Add variant filtering and QC.
10. Add VEP and ClinVar annotation.
11. Add MultiQC.
12. Add reproducible GRCh38 configuration.
13. Add automated testing and CI.

---

## Project continuity documentation

Development-state and architectural context are versioned under:

```text
docs/project-context/
```

Key documents:

- `CURRENT_PROJECT_CHECKPOINT.md` — verified current state and next development unit
- `PROJECT_CONTEXT.md` — project history, architecture, design rationale, and limitations
- `DECISIONS.md` — architectural decisions
- `NEXT_TASK.md` — exact current development task
- `ROADMAP.md` — ordered NOW / NEXT / LATER plan
- `TEST_EVIDENCE.md` — concrete execution records and test evidence
- `LEARNING_LOG.md` — technical concepts learned through the project

For implementation-state questions, the current GitHub default branch remains authoritative.

Always distinguish between:

- **IMPLEMENTED**
- **TESTED**
- **DOCUMENTED**
- **PLANNED**

These states are not equivalent.

---

## Purpose

This repository is being developed both as a functional genomics workflow and as a practical project for learning:

- Nextflow DSL2
- nf-core module conventions
- workflow modularization
- metadata-aware channels
- containerized reproducibility
- human germline variant analysis
- reproducible bioinformatics software development

The pipeline is intentionally developed incrementally so that each workflow component can be implemented, tested, and understood independently.

---

## License

See the repository license for usage terms.
