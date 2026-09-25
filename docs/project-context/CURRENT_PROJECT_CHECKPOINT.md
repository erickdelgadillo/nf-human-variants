# nf-human-variants — Current Project Checkpoint

Last verified project state: 2026-09-25

Repository:
`erickdelgadillo/nf-human-variants`

Default branch:
`main`

Current verified commit:
`3e76bc15c9f1776ea858dfa3718d14909635a2d6`

> The current GitHub default branch is the authoritative source for implementation state.
> This checkpoint records the verified project state at the date above and may become outdated after future commits.

---

## 1. Project purpose

`nf-human-variants` is a modular Nextflow DSL2 workflow for learning, developing, and demonstrating reproducible human germline variant analysis.

The project is intended for:

- bioinformatics workflow engineering;
- Nextflow DSL2 practice;
- nf-core module integration;
- containerized reproducibility;
- human germline SNP and small-indel analysis;
- portfolio demonstration.

It is not intended for:

- clinical diagnosis;
- medical decision-making;
- validated clinical interpretation;
- production clinical pipelines.

The long-term conceptual workflow is:

```text
FASTQ
→ QC
→ preprocessing
→ alignment
→ BAM processing
→ germline variant calling
→ variant filtering / QC
→ annotation
→ downstream variant exploration
```

---

## 2. Current functional endpoint

The current workflow reaches:

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
       SAM
       │
       ▼
 samtools sort
       │
       ▼
  sorted BAM
       │
       ├── samtools index
       │        ↓
       │       BAI
       │
       └── samtools flagstat
                ↓
        alignment metrics
```

Current reference preparation is:

```text
Reference FASTA
      │
      ├── BWA-MEM2 index
      ├── samtools faidx → .fai
      └── GATK CreateSequenceDictionary → .dict
```

The pipeline does not yet perform variant calling.

The current BAM should not yet be considered formally `analysis-ready` for GATK.

---

## 3. Current architecture

The verified high-level architecture is:

```text
main.nf
    │
    ▼
workflows/nf_human_variants.nf
    │
    ├── PREPARE_REFERENCE
    │
    └── PROCESS_READS
```

### Entry point

`main.nf`

Current responsibility:

- import `NF_HUMAN_VARIANTS`;
- invoke the main workflow;
- contain no bioinformatics logic.

### Main workflow

`workflows/nf_human_variants.nf`

Current responsibilities:

- create the read input channel;
- create the reference input channel;
- attach sample metadata;
- invoke `PREPARE_REFERENCE`;
- invoke `PROCESS_READS`;
- connect reference outputs to read processing.

### Reference subworkflow

`subworkflows/local/prepare_reference.nf`

Current responsibilities:

- BWA-MEM2 indexing;
- `samtools faidx`;
- GATK `CreateSequenceDictionary`.

Outputs include:

- FASTA;
- BWA-MEM2 index;
- `.fai`;
- `.dict`.

Currently, FASTA and the BWA index are consumed by alignment.

The `.fai` and `.dict` are prepared for later GATK integration but are not yet used downstream.

### Read-processing subworkflow

`subworkflows/local/process_reads.nf`

Current processing chain:

```text
FastQC
→ fastp
→ BWA-MEM2
→ samtools sort
→ samtools index
→ samtools flagstat
```

Current outputs:

- sorted BAM;
- BAI;
- flagstat metrics.

---

## 4. Current modules

### Local modules

Currently present and connected:

- `fastqc`
- `fastp`
- `bwa_mem2`
- `bwa_mem2_index`

### nf-core modules

Currently integrated:

- `samtools/faidx`
- `samtools/sort`
- `samtools/index`
- `samtools/flagstat`
- `gatk4/createsequencedictionary`

Official nf-core modules should remain preferred for standard operations when their interfaces fit the workflow.

---

## 5. Metadata model

The workflow currently propagates sample identity with `(meta, data)` style tuples.

Conceptually:

```text
(meta, paired_reads)
→ (meta, trimmed_reads)
→ (meta, SAM)
→ (meta, BAM)
→ downstream sample-specific outputs
```

Current metadata are derived from paired-end filename discovery.

The current implementation includes:

```text
meta.id
single_end: false
```

This is adequate for the present development stage but is not yet considered the final metadata contract.

A future explicit samplesheet must replace filename-derived identity as the primary interface.

---

## 6. Current input model

Current read input uses paired-end discovery with `Channel.fromFilePairs`.

Typical pattern:

```text
*_{R1,R2}.fastq.gz
```

Current reference input is supplied through `params.fasta`.

This filename-driven model is temporary.

---

## 7. Configuration

`nextflow.config` currently:

- enables Docker;
- defines `params.reads`;
- defines `params.fasta`;
- defines `params.outdir`;
- contains a `test` profile;
- includes selected process resource overrides.

Current test profile:

```text
conf/test.config
```

It defines development paths for:

- paired FASTQ;
- reference FASTA;
- test output directory.

Typical development command:

```bash
nextflow run main.nf -profile test
```

Typical cache reuse:

```bash
nextflow run main.nf -profile test -resume
```

---

## 8. Current implementation status

### IMPLEMENTED

- Nextflow DSL2 project structure
- modular workflow architecture
- workflow entry point
- top-level workflow
- `PREPARE_REFERENCE`
- `PROCESS_READS`
- paired-end FASTQ discovery
- sample metadata propagation
- FastQC
- fastp
- BWA-MEM2 reference indexing
- BWA-MEM2 alignment
- `samtools faidx`
- GATK `CreateSequenceDictionary`
- `samtools sort`
- `samtools index`
- `samtools flagstat`
- Docker execution
- test profile

### TESTED / EVIDENCE AVAILABLE

The current development workflow has been executed during development.

However:

- no automated CI validation exists;
- no documented multi-sample validation has yet established that all BAM/BAI joins and sample associations are robust;
- no formal benchmarking against a truth set has been performed;
- no variant-calling validation exists because variant calling is not implemented.

### DOCUMENTED

The project has:

- README
- project context documents
- architectural decisions
- roadmap
- next-task definition
- development rules

Some README sections may lag behind the current code and must never override the current GitHub implementation.

### PLANNED

- validated samplesheet input
- explicit metadata contract
- multi-sample validation
- read groups
- duplicate handling
- analysis-ready BAM boundary
- GATK HaplotypeCaller
- gVCF generation
- GenotypeGVCFs
- variant filtering and QC
- VEP
- ClinVar annotation
- MultiQC
- reproducible GRCh38 configuration
- automated tests
- CI
- execution reports
- more complete resource configuration

---

## 9. Known technical issues / debt

### Samplesheet missing

The current input interface still derives sample identity from filenames.

This must be replaced with explicit sample metadata.

### `meta.id` semantics not formally defined

Before read groups are introduced, the project must define exactly what `meta.id` means.

Likely interpretation:

```text
biological sample identifier
```

but this should be explicitly confirmed during samplesheet design.

### BAM–BAI association must be validated with multiple samples

The current workflow reconstructs BAM/BAI relationships downstream of indexing.

A one-sample run can hide:

- cardinality problems;
- join-key errors;
- ordering assumptions;
- metadata mismatches.

This must be tested explicitly with at least two samples.

### Read groups are not yet implemented

The current BWA-MEM2 alignment does not yet have a formal reproducible `@RG` strategy.

This is required before the GATK stage.

### Duplicate handling is absent

No duplicate marking/handling step exists yet.

It should be implemented separately from `PROCESS_READS`.

### BAM is not yet formally analysis-ready

The current endpoint is:

```text
sorted BAM + BAI + flagstat
```

not:

```text
analysis-ready BAM
```

### `params.outdir` is not uniformly respected

Some local modules currently use fixed publication paths.

Output routing should eventually be centralized and consistent.

### Resource configuration is incomplete

Some tools depend on `task.cpus` or memory values without a complete project-wide resource policy.

### Test reproducibility is incomplete

A test profile exists, but:

- no CI executes it;
- test data provenance and generation should be documented more explicitly;
- a clean checkout should eventually be able to reproduce the test deterministically.

---

## 10. Current exact task

The next functional unit is:

# Implement a validated `samplesheet.csv` interface

Initial candidate schema:

```csv
sample,fastq_1,fastq_2
NA12878,path/to/NA12878_R1.fastq.gz,path/to/NA12878_R2.fastq.gz
```

The first implementation should remain minimal.

Do not add lane/library/platform fields until they are justified by downstream read-group requirements.

---

## 11. Definition of done for the current task

The samplesheet task is complete when:

- the CSV can be parsed;
- required columns are validated;
- FASTQ paths are checked;
- paired-end input is explicit;
- stable sample metadata are produced;
- `(meta, reads)` remains compatible with the downstream workflow;
- at least two samples are tested;
- BAM, BAI and flagstat remain correctly associated with each sample;
- invalid input produces clear failures;
- README usage instructions are updated;
- a clean commit is created.

Suggested commit:

```text
feat: add validated samplesheet input with sample metadata
```

---

## 12. Do not implement yet

Do not combine the samplesheet task with:

- duplicate handling;
- MarkDuplicates;
- complete read-group implementation;
- HaplotypeCaller;
- gVCF generation;
- GenotypeGVCFs;
- variant filtering;
- VQSR;
- VEP;
- ClinVar;
- structural variants;
- CNVs;
- somatic calling;
- tumor/normal analysis;
- large CI refactors;
- LocusLens integration.

---

## 13. Expected next phases

After samplesheet and multi-sample validation:

```text
samplesheet
→ explicit metadata contract
→ read groups
→ PROCESS_BAM
→ duplicate handling
→ analysis-ready BAM
→ GATK HaplotypeCaller in gVCF mode
→ genotyping
→ filtering / QC
→ annotation
```

---

## 14. Source-of-truth rule

When sources disagree:

1. Current GitHub default branch.
2. Explicit recent architectural decisions.
3. This checkpoint.
4. `PROJECT_CONTEXT.md`.
5. `README.md`.
6. Older documents and conversations.

Do not infer implementation status from the roadmap.

Always distinguish:

- IMPLEMENTED
- TESTED
- DOCUMENTED
- PLANNED
