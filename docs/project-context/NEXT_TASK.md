# nf-human-variants — Current Development Task

## Goal

Replace filename-derived paired-end input with a validated samplesheet interface.

## Current checkpoint

The workflow currently reaches:

```text
Paired-end FASTQ
    ├── FastQC
    └── fastp
          ↓
      BWA-MEM2
          ↓
          SAM
          ↓
     samtools sort
          ↓
     sorted BAM
       ├── samtools index → BAI
       └── samtools flagstat → alignment QC
```

Reference preparation currently includes:

```text
Reference FASTA
    ├── BWA-MEM2 index
    ├── samtools faidx → .fai
    └── GATK CreateSequenceDictionary → .dict
```

## Immediate task

Design and implement a minimal `samplesheet.csv` interface.

Initial candidate:

```csv
sample,fastq_1,fastq_2
NA12878,path/to/NA12878_R1.fastq.gz,path/to/NA12878_R2.fastq.gz
```

## Requirements

The first implementation should:

- parse a CSV samplesheet;
- validate required fields;
- confirm paired-end FASTQ paths exist;
- create stable sample metadata;
- emit `(meta, reads)` in a form compatible with the current pipeline;
- support at least two samples in a test run;
- preserve current downstream behavior;
- keep metadata propagation intact.

## Questions to resolve during implementation

- What exactly should `meta.id` represent?
- Should the current glob input remain temporarily available as a compatibility path?
- Where should samplesheet validation live?
- Which validations are essential now versus later?
- What metadata will be needed for read groups in the next phase?

## Do not implement yet

Do not add these in the same development unit:

- MarkDuplicates / duplicate handling;
- read groups beyond what is required to define the metadata model;
- GATK HaplotypeCaller;
- gVCF generation;
- GenotypeGVCFs;
- VEP;
- ClinVar integration;
- large CI refactors;
- structural variant or somatic workflows.

## Definition of done

This task is complete when:

- `samplesheet.csv` is the primary input interface;
- at least two samples are parsed correctly;
- metadata are propagated correctly;
- R1/R2 pairing is validated;
- invalid inputs fail clearly;
- the workflow reaches the current BAM + BAI + flagstat endpoint;
- test execution succeeds;
- README usage instructions are updated;
- a clean commit is created.

## Suggested commit message

```text
feat: add validated samplesheet input with sample metadata
```

## Next task after completion

Define the read-group metadata strategy and then implement a separate BAM-preparation unit for duplicate handling.
