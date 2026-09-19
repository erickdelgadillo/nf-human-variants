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

This produces the reference files required for downstream alignment and variant calling.

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
│
├── conf/
│   └── test.config
│
├── workflows/
│   └── nf_human_variants.nf
│
├── subworkflows/
│   └── local/
│       ├── prepare_reference.nf
│       └── process_reads.nf
│
├── modules/
│   ├── local/
│   │   ├── fastqc.nf
│   │   ├── fastp.nf
│   │   ├── bwa_mem2.nf
│   │   └── bwa_mem2_index.nf
│   │
│   └── nf-core/
│       ├── gatk4/
│       └── samtools/
│
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

A small test dataset is available for development and pipeline validation.

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

The test profile overrides these parameters with the bundled development dataset.

Execution resources are also configured independently from process implementation. For example, memory requirements for GATK and CPU requirements for FastQC are defined through Nextflow configuration rather than by modifying upstream nf-core modules.

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

This will allow multiple samples and associated metadata to be represented explicitly and reproducibly.

A small set of publicly available human sequencing samples will then be used as a realistic end-to-end test dataset.

---

## Development roadmap

The immediate development priorities are:

1. Implement samplesheet-based sample input.
2. Validate the workflow with a small real human sequencing dataset.
3. Complete BAM preparation and duplicate handling.
4. Implement GATK germline variant calling.
5. Add variant filtering and QC.
6. Add functional and clinical annotation resources.
7. Add automated testing and CI.

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

