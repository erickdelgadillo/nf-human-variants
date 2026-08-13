# nf-human-variants

![Version](https://img.shields.io/badge/version-v0.1.0-blue)
![Nextflow](https://img.shields.io/badge/Nextflow-DSL2-23aa62)
![Java](https://img.shields.io/badge/Java-17%2B-orange)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)

A modular **Nextflow DSL2 pipeline for human germline variant calling** from paired-end short-read sequencing data.

The project is being developed as a reproducible bioinformatics workflow covering the main steps from raw sequencing reads to functionally and clinically annotated variants.

> **Status:** Work in progress — currently implements automated paired-end FASTQ discovery and FastQC quality control.

## Overview

The pipeline is designed to progressively implement the following workflow:

```text
Paired-end FASTQ
       │
       ▼
     FastQC
       │
       ▼
     fastp
       │
       ▼
   BWA-MEM2
       │
       ▼
    BAM/CRAM
       │
       ▼
 BAM processing
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

The initial focus is **germline SNP and small indel detection**. Somatic variant calling and tumor/normal analysis are outside the current scope but may be incorporated later.

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

## Project structure

```text
nf-human-variants/
├── main.nf
├── nextflow.config
├── modules/
│   └── fastqc.nf
├── workflows/
├── conf/
├── data/
├── results/
├── .gitignore
└── README.md
```

Sequencing data and generated results are excluded from Git tracking.

## Requirements

Current development environment:

* Nextflow
* Java 17+
* Conda/Mamba
* FastQC
* Docker

The project currently uses a dedicated Conda environment for local development. Containerized execution will be incorporated as the workflow develops to improve reproducibility and portability.

## Running the pipeline

Activate the development environment:

```bash
mamba activate nf-human-variants
```

Run the workflow:

```bash
nextflow run main.nf
```

Resume a previous execution using the Nextflow cache:

```bash
nextflow run main.nf -resume
```

## Input data

The current development dataset consists of paired-end human germline short reads used for pipeline testing.

Large sequencing files are **not stored in this repository**.

The pipeline is intended to eventually support standard human WGS/WES paired-end datasets through configurable input parameters and sample metadata.

## Planned development

* [x] Project structure
* [x] Automatic paired-end FASTQ discovery
* [x] FastQC module
* [x] FastQC result publication
* [ ] Read filtering and trimming with fastp
* [ ] Human reference genome handling
* [ ] Alignment with BWA-MEM2
* [ ] BAM sorting and indexing
* [ ] Duplicate handling
* [ ] Germline variant calling with GATK HaplotypeCaller
* [ ] Variant filtering
* [ ] Functional annotation
* [ ] ClinVar integration
* [ ] MultiQC reporting
* [ ] Containerized execution
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
