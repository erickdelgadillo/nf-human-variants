# nf-human-variants

![Version](https://img.shields.io/badge/version-v0.1.0-blue)
![Nextflow](https://img.shields.io/badge/Nextflow-DSL2-23aa62)
![Java](https://img.shields.io/badge/Java-17%2B-orange)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)

> A modular Nextflow DSL2 pipeline for human germline variant calling
> from paired-end short-read sequencing data.

`nf-human-variants` is a bioinformatics workflow developed to build a
reproducible human germline variant-calling pipeline while exploring
modular Nextflow DSL2 workflow design, containerized execution, and
standard NGS processing tools.

The current implementation covers the workflow from paired-end FASTQ
discovery through quality control, preprocessing, BWA-MEM2 alignment,
and BAM sorting.

> **Status:** Work in progress. Variant calling, genotyping, filtering,
> annotation, and several reference-preparation and alignment-QC stages
> are still under development.

------------------------------------------------------------------------

## Overview

The pipeline is being developed progressively toward the following
workflow:

``` text
Paired-end FASTQ
      |
      +----------------> Raw-read quality control (FastQC)
      |
      v
Read preprocessing / trimming (fastp)
      |
      v
Read alignment to reference genome (BWA-MEM2)
      |
      v
     SAM
      |
      v
BAM sorting (samtools)
      |
      v
BAM indexing (samtools)
      |
      v
Duplicate marking / handling (GATK MarkDuplicates)
      |
      v
Germline variant calling (GATK HaplotypeCaller)
      |
      v
     gVCF
      |
      v
Genotyping (GATK GenotypeGVCFs)
      |
      v
     VCF
      |
      v
Variant filtering (GATK / bcftools)
      |
      v
Variant quality control (bcftools)
      |
      v
Functional / clinical annotation (VEP / ClinVar)
      |
      v
Prioritized germline variants


Reference FASTA
      |
      +---> BWA index (BWA-MEM2)
      +---> FASTA index / .fai (samtools faidx)
      +---> Sequence dictionary / .dict (GATK CreateSequenceDictionary)
```

The initial biological scope is **germline SNP and small-indel
detection**.

Somatic variant calling, copy-number variation, structural variants, and
tumor/normal analysis are outside the current scope.

------------------------------------------------------------------------

## Current implementation

### Paired-end FASTQ discovery

Input reads are discovered automatically using Nextflow file-pair
channels.

Files following conventions such as:

``` text
sample_R1.fastq.gz
sample_R2.fastq.gz
```

are paired and propagated through the workflow with their sample
identifier.

### FastQC

Raw paired-end reads are evaluated with **FastQC** before preprocessing.

Typical outputs include:

``` text
sample_R1_fastqc.html
sample_R1_fastqc.zip
sample_R2_fastqc.html
sample_R2_fastqc.zip
```

Reports are published under:

``` text
results/fastqc/
```

### fastp

Paired-end reads are filtered and trimmed with **fastp**.

The module produces processed reads together with HTML and JSON reports:

``` text
sample_R1.trimmed.fastq.gz
sample_R2.trimmed.fastq.gz
sample_fastp.html
sample_fastp.json
```

Outputs are published under:

``` text
results/fastp/
```

### BWA-MEM2 reference indexing

The configured reference FASTA is indexed with **BWA-MEM2** before
alignment.

The indexing process generates the auxiliary files required by BWA-MEM2
and exposes them to the downstream alignment process.

### BWA-MEM2 alignment

Trimmed reads from `fastp` are connected directly to the **BWA-MEM2**
alignment module.

The current workflow therefore implements:

``` text
FASTQ
  |
  v
fastp
  |
  v
BWA-MEM2
  |
  v
SAM
```

Alignment is no longer an isolated module: it is connected to the main
workflow.

### BAM sorting

SAM output produced by BWA-MEM2 is transformed into the metadata
structure required by the nf-core `samtools/sort` module and passed
downstream for BAM sorting.

The currently connected processing path is therefore:

``` text
paired FASTQ
     |
     +----> FastQC
     |
     v
   fastp
     |
     v
 BWA-MEM2
     |
     v
    SAM
     |
     v
samtools sort
     |
     v
sorted BAM
```

BAM indexing and subsequent alignment-processing stages are not yet
implemented.

### Containerized execution

Pipeline processes use versioned container images and execute with
**Docker**.

Associating software environments with individual processes reduces
dependence on locally installed bioinformatics tools and improves
workflow reproducibility and portability.

------------------------------------------------------------------------

## Project structure

``` text
nf-human-variants/
├── main.nf
├── nextflow.config
├── modules/
│   ├── local/
│   │   ├── fastqc.nf
│   │   ├── fastp.nf
│   │   ├── bwa_mem2.nf
│   │   └── bwa_mem2_index.nf
│   └── nf-core/
│       └── samtools/
│           └── sort/
├── workflows/
├── conf/
├── data/
├── reference/
├── results/
├── .gitignore
└── README.md
```

Sequencing data, reference datasets, generated results, and Nextflow
work directories are excluded from Git tracking where appropriate.

------------------------------------------------------------------------

## Requirements

The current development environment requires:

-   Nextflow
-   Java 17+
-   Docker

Bioinformatics tools used by individual processes are provided through
containers rather than requiring manual installation on the host.

------------------------------------------------------------------------

## Running the pipeline

Run the workflow with:

``` bash
nextflow run main.nf
```

Resume a previous execution using the Nextflow cache:

``` bash
nextflow run main.nf -resume
```

Input reads and other workflow parameters are configured through
`nextflow.config`.

------------------------------------------------------------------------

## Input data

The current development dataset consists of paired-end human germline
short reads used for pipeline testing.

Large sequencing files are not stored in this repository.

The current reference genome is a small human test reference used for
workflow development and does **not** represent a complete production
GRCh38 reference.

The pipeline is intended to eventually support standard human WGS/WES
paired-end datasets through configurable input parameters and sample
metadata.

------------------------------------------------------------------------

## Development status

### Read processing and alignment

-   [x] Automatic paired-end FASTQ discovery
-   [x] FastQC module
-   [x] FastQC result publication
-   [x] Read filtering and trimming with fastp
-   [x] BWA-MEM2 reference indexing
-   [x] Connect fastp output to BWA-MEM2
-   [x] Alignment with BWA-MEM2
-   [x] BAM sorting with samtools
-   [x] BAM indexing with samtools
-   [x] Alignment quality control
-   [ ] MultiQC reporting

### Reference preparation

-   [x] BWA-MEM2 reference indexing
-   [x] Reference FASTA indexing with `samtools faidx`
-   [x] Reference sequence dictionary with GATK

### Variant calling

-   [ ] Duplicate handling
-   [ ] Germline variant calling with GATK HaplotypeCaller
-   [ ] Genotyping with GATK GenotypeGVCFs
-   [ ] Variant filtering
-   [ ] Variant quality control

### Annotation

-   [ ] Functional annotation
-   [ ] ClinVar integration

### Reproducibility and infrastructure

-   [x] Modular Nextflow DSL2 project structure
-   [x] Containerized execution with Docker
-   [ ] Production GRCh38 reference support
-   [ ] Test dataset / automated testing
-   [ ] Continuous integration

------------------------------------------------------------------------

## Biological scope

The workflow is intended to identify genomic positions where an
individual's sequencing data provide evidence for differences from the
human reference genome.

In simplified form:

``` text
Sequencing reads
      +
Human reference genome
      |
      v
Read alignment
      |
      v
Evidence for genomic differences
      |
      v
Variant calling
      |
      v
SNPs and small indels
```

A detected variant is **not equivalent to a pathogenic variant or a
clinical diagnosis**.

Downstream annotation and interpretation are required to determine
genomic context, predicted molecular consequence, population frequency,
and available clinical evidence.

------------------------------------------------------------------------

## Project goals

This project focuses on:

-   Reproducible workflow development with Nextflow DSL2
-   Modular bioinformatics pipeline architecture
-   Human NGS data processing
-   FASTQ, SAM, BAM/CRAM, and VCF handling
-   Germline variant calling
-   Functional and clinical variant annotation
-   Containerized software environments
-   Transparent and documented bioinformatics analysis

The repository is also intended as a practical development project for
progressively implementing the major stages of a modern germline
variant-calling workflow rather than presenting an already completed
production pipeline.

------------------------------------------------------------------------

## Roadmap

The next development stages are expected to extend the current alignment
workflow toward analysis-ready BAM files and germline variant calling.

Near-term priorities include:

1.  BAM indexing with samtools
2.  Reference FASTA indexing
3.  Reference sequence dictionary generation
4.  Alignment quality control
5.  Duplicate handling
6.  GATK HaplotypeCaller integration
7.  Genotyping and variant filtering
8.  MultiQC reporting
9.  Automated testing and continuous integration

Longer-term development will address production GRCh38 support and
functional and clinical variant annotation.

------------------------------------------------------------------------

## Disclaimer

This workflow is being developed for **research, training, and portfolio
purposes**.

It is not validated for clinical diagnosis or medical decision-making.

------------------------------------------------------------------------

## Author

**Erick Delgadillo-Nuño**

Bioinformatics · NGS · Nextflow · Reproducible scientific workflows
