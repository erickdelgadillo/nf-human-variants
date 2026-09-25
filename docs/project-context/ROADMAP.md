# nf-human-variants — Development Roadmap

This roadmap is intentionally ordered. Do not skip ahead unless a technical dependency requires it.

## NOW

### 1. Samplesheet input

- Replace filename-derived input with `samplesheet.csv`.
- Keep the initial schema minimal.
- Validate R1/R2 paths.
- Propagate stable sample metadata.
- Test with multiple samples.

### 2. Metadata contract

Define explicitly:

- what `meta.id` represents;
- which metadata are mandatory;
- which fields are technical versus biological;
- how future read-group fields will map into the workflow.

### 3. Multi-sample validation

Confirm that:

- BAM and BAI remain matched by sample;
- `join` behavior is correct for multiple samples;
- no cardinality or ordering assumptions are hidden by one-sample tests.

---

## NEXT

### 4. Read groups

Add a reproducible strategy for BWA-MEM2 `@RG` information.

Likely metadata requirements may include:

- sample;
- library;
- platform;
- lane or sequencing unit.

Do not add fields without a concrete downstream need.

### 5. Duplicate handling

Create a separate BAM-processing unit.

Conceptual contract:

```text
Input:
tuple(meta, sorted_bam)
tuple(meta, bai)

Output:
tuple(meta, marked_bam)
tuple(meta, marked_bai)
tuple(meta, duplicate_metrics)
```

### 6. Analysis-ready BAM boundary

Define the exact BAM state expected by variant calling.

### 7. GATK HaplotypeCaller

Add germline calling in gVCF mode.

### 8. gVCF workflow

- per-sample gVCF;
- downstream combination/genotyping strategy;
- clear sample identity throughout.

### 9. GenotypeGVCFs

Produce cohort-level VCF where appropriate.

---

## LATER

### 10. Variant filtering and QC

Evaluate appropriate strategy:

- hard filtering;
- VQSR only if justified by dataset scale;
- variant-level QC metrics.

### 11. Functional annotation

Add Ensembl VEP.

### 12. ClinVar integration

Integrate ClinVar as annotation/reference information.

Do not present the project as a clinical decision-support tool.

### 13. MultiQC

Integrate QC aggregation once FastQC, fastp, flagstat, and future metrics expose stable outputs.

### 14. Reproducible reference configuration

Add a production-oriented GRCh38 configuration.

Document:

- reference source;
- build;
- checksums;
- required indexes;
- associated resources.

### 15. Automated testing

Add end-to-end automated tests after the test dataset can be obtained or generated reproducibly from a clean checkout.

### 16. Continuous integration

Add CI once the test profile is small, deterministic, and self-contained.

### 17. Execution reporting

Consider enabling:

- trace;
- report;
- timeline;
- DAG.

### 18. Resource profiles

Define resource policies for:

- BWA-MEM2;
- fastp;
- samtools sort;
- GATK;
- other expensive steps.

### 19. Additional execution environments

Only if useful:

- Apptainer / Singularity;
- Wave;
- HPC profiles.

### 20. LocusLens

Develop separately as a downstream variant exploration, visualization, or prioritization layer.

Potential flow:

```text
nf-human-variants
    ↓
VCF / annotated VCF
    ↓
LocusLens
```

---

## OUT OF CURRENT SCOPE

Do not expand into these until the germline workflow is complete and validated:

- somatic variant calling;
- tumor/normal analysis;
- structural variants;
- CNVs;
- polygenic risk scoring;
- clinical interpretation;
- diagnostic claims.
