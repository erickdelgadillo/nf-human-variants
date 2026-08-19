# nf-human-variants

![Version](https://img.shields.io/badge/version-v0.1.0-blue)
![Nextflow](https://img.shields.io/badge/Nextflow-DSL2-23aa62)
![Java](https://img.shields.io/badge/Java-17%2B-orange)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)

A modular **Nextflow DSL2 pipeline for human germline variant calling** from paired-end short-read sequencing data.

The project is being developed as a reproducible bioinformatics workflow covering the main steps from raw sequencing reads to functionally and clinically annotated variants.

> **Status:** Work in progress — currently implements automated paired-end FASTQ discovery, FastQC quality control, read preprocessing with fastp, BWA-MEM2 reference indexing, and containerized execution with Docker.

## Overview

The pipeline is designed to progressively implement the following workflow:

```text
Paired-end FASTQ
       │
       ├──────────────► FastQC
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
 BAM sorting / indexing
       │
       ▼
 Duplicate handling
       │
       ▼
GATK HaplotypeCaller
       │
       ▼
      VCF
       │
       ▼
 Variant filtering
       │
       ▼
Functional / clinical annotation
       │
       ▼
Prioritized germline variants
```

The initial focus is **germline SNP and small indel detection**.
Somatic variant calling, copy-number variation, structural variants, and tumor/normal analysis are outside the current scope and may be incorporated later.

## Current implementation

### FastQC

The first implemented module performs quality control of paired-end FASTQ files using **FastQC**.

Input files following the naming convention:

```text
sample_R1.fastq.gz
sample_R2.fastq.gz
```

are automatically paired by Nextflow and passed to the FastQC process.

Example:

```text
human_germline_R1.fastq.gz
human_germline_R2.fastq.gz
        │
        ▼
   FASTQC process
        │
        ├── human_germline_R1_fastqc.html
        ├── human_germline_R1_fastqc.zip
        ├── human_germline_R2_fastqc.html
        └── human_germline_R2_fastqc.zip
```

Reports are published to:

```text
results/fastqc/
```
### fastp

Paired-end reads are processed with fastp for read filtering and trimming.
The module produces:

```text
sample_R1.trimmed.fastq.gz
sample_R2.trimmed.fastq.gz
sample_fastp.html
sample_fastp.json
```

Reports and processed reads are published to:

```text
results/fastp/
```
### BWA-MEM2 reference indexing
A reference FASTA file can be indexed using BWA-MEM2.
The indexing module generates the auxiliary files required by BWA-MEM2 for subsequent read alignment.
Read alignment itself is implemented as a module but is not yet connected to the main workflow.

### Containerized execution
Pipeline processes use versioned container images and are executed with Docker.
Container definitions are associated with individual Nextflow processes, reducing dependence on locally installed bioinformatics tools and improving workflow reproducibility and portability.


## Project structure

```text
nf-human-variants/
├── main.nf
├── nextflow.config
├── modules/
│   ├── fastqc.nf
│   ├── fastp.nf
│   ├── bwa_mem2.nf
│   └── bwa_mem2_index.nf
├── workflows/
├── conf/
├── data/
├── reference/
├── results/
├── .gitignore
└── README.md
```

Sequencing data, reference datasets, generated results, and Nextflow work directories are excluded from Git tracking where appropriate.

## Requirements

Current development environment:

* Nextflow
* Java 17+
* Docker

The project currently uses Docker for containerized execution to improve reproducibility and portability.

## Running the pipeline

Run the workflow:

```bash
nextflow run main.nf
```

Resume a previous execution using the Nextflow cache:

```bash
nextflow run main.nf -resume
```

Input reads can be configured through the Nextflow parameters defined in:

```bash
nextflow.config
```

## Input data

The current development dataset consists of paired-end human germline short reads used for pipeline testing.
Large sequencing files are not stored in this repository.
The current reference genome is a small human test reference used for workflow development and does not represent a complete production GRCh38 reference.
The pipeline is intended to eventually support standard human WGS/WES paired-end datasets through configurable input parameters and sample metadata.

## Planned development

* [x] Automatic paired-end FASTQ discovery
* [x] FastQC module
* [x] FastQC result publication
* [x] Read filtering and trimming with fastp
* [x] BWA-MEM2 reference indexing
* [ ] Connect fastp output to BWA-MEM2
* [ ] Alignment with BWA-MEM2
* [ ] BAM sorting and indexing
* [ ] Alignment quality control
* [ ] Duplicate handling
* [ ] Germline variant calling with GATK HaplotypeCaller
* [ ] Variant filtering
* [ ] Functional annotation
* [ ] ClinVar integration
* [ ] MultiQC reporting

### Reproducibility and infrastructure

* [x] Project structure
* [x] Containerized execution with Docker
* [ ] Production GRCh38 reference support
* [ ] Test dataset / automated testing
* [ ] Continuous integration

## Biological scope

The workflow is intended to identify positions where an individual's genome differs from the human reference genome.

In simplified form:

```text
Sequencing reads
      +
Human reference genome
      │
      ▼
Read alignment
      │
      ▼
Evidence for genomic differences
      │
      ▼
Variant calling
      │
      ▼
SNPs and small indels
```

A detected variant is **not equivalent to a pathogenic variant or a clinical diagnosis**.

Downstream annotation is required to determine its genomic context, predicted molecular consequence, population frequency, and available clinical evidence.

## Goals

This project focuses on:

* reproducible workflow development with Nextflow DSL2;
* modular pipeline architecture;
* human NGS data processing;
* FASTQ, BAM/CRAM and VCF handling;
* germline variant calling;
* functional and clinical variant annotation;
* software environments and containerization;
* transparent and documented bioinformatics analysis.

## Disclaimer

This workflow is being developed for **research, training, and portfolio purposes**.

It is not validated for clinical diagnosis or medical decision-making.
