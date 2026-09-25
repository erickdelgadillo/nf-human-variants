# nf-human-variants — Learning Log

Use this file to record concepts learned through the project, not just completed features.

The goal is to preserve *why* the workflow is designed as it is.

---

## Nextflow DSL2

### Modules

**Concept:** isolate a process and expose a clear input/output interface.

**Applied in this project:** local modules for FastQC, fastp, BWA-MEM2, and BWA-MEM2 indexing; nf-core modules for standard operations.

**Key lesson:** process code should remain reusable and should not contain unnecessary project-specific configuration.

---

### Subworkflows

**Concept:** group related modules into coherent functional units.

**Applied in this project:**

- `PREPARE_REFERENCE`
- `PROCESS_READS`

**Key lesson:** subworkflows reduce orchestration complexity and create clean interfaces between phases.

---

### `(meta, data)` tuples

**Concept:** propagate sample identity and other metadata together with files.

**Applied in this project:** sample metadata are propagated from paired FASTQ discovery through preprocessing, alignment, and BAM processing.

**Key lesson:** filenames alone are not a robust long-term metadata model.

---

### `Channel.fromFilePairs`

**Concept:** discover paired-end reads from filename patterns.

**Applied in this project:** current FASTQ discovery.

**Limitation learned:** convenient for early development, but not sufficient as the permanent input contract for richer metadata.

**Next step:** replace primary input with a validated samplesheet.

---

### `Channel.value`

**Concept:** create a reusable value channel for static input.

**Applied in this project:** adapter inputs required by some nf-core module interfaces.

**Key lesson:** technically valid adapters can become opaque; document why static placeholder values exist.

---

### `join`

**Concept:** match channel elements by a common key.

**Applied in this project:** reconstruct BAM + BAI relationships downstream of sorting/indexing.

**Key lesson:** a join that works for one sample may still hide metadata or cardinality problems. Test with multiple samples.

---

## nf-core

### Official modules

**Concept:** reuse community-maintained standardized processes.

**Current examples:**

- `samtools/faidx`
- `samtools/sort`
- `samtools/index`
- `samtools/flagstat`
- `gatk4/createsequencedictionary`

**Key lesson:** prefer official modules for standard operations when their interfaces fit the workflow.

---

### Module signatures

**Concept:** nf-core modules often require specific tuple structures and auxiliary inputs.

**Key lesson:** inspect the exact module interface instead of assuming a generic `(meta, file)` shape.

---

### `modules.json`

**Concept:** track installed nf-core modules and their provenance.

**Key lesson:** update nf-core modules through the nf-core mechanism rather than manually editing provenance metadata.

---

## Reproducibility

### Containers

**Current approach:** Docker with versioned container images.

**Key lesson:** containerization is necessary but not sufficient for complete reproducibility.

Other relevant elements include:

- pinned software versions;
- reproducible test data;
- stable references;
- resource configuration;
- CI;
- documented execution commands.

---

### Configuration versus implementation

**Concept:** resource settings should not be hard-coded into reusable module logic unless necessary.

**Applied example:** process resource overrides in `nextflow.config`.

**Key lesson:** workflow logic, software implementation, and execution policy are separate concerns.

---

### `params.outdir`

**Current lesson:** defining a parameter is not enough if local modules still publish to fixed paths.

**Improvement:** centralize output behavior so the configured output directory is respected consistently.

---

## Human germline variant workflow

### Reference preparation

Current reference preparation includes:

- BWA-MEM2 index;
- FASTA `.fai`;
- GATK sequence dictionary.

**Key lesson:** generating required reference artifacts early creates a clean foundation for downstream GATK steps.

---

### Read groups

**Concept:** read-group metadata becomes functionally important for GATK-compatible workflows.

**Current status:** not yet implemented explicitly.

**Key lesson:** read groups depend on a sound metadata model, so samplesheet design should come first.

---

### Duplicate handling

**Current status:** not yet implemented.

**Key lesson:** duplicate handling should be a clear BAM-processing stage rather than an incidental detail hidden in alignment.

---

## Software-development lessons

### Implemented ≠ tested ≠ documented

Always distinguish:

- IMPLEMENTED
- TESTED
- DOCUMENTED
- PLANNED

A README can lag behind the code, and a successful run does not prove biological validity.

---

### Small commits

Preferred development unit:

- one coherent functional change;
- one testable outcome;
- one clear commit message;
- README update only when behavior or usage changed.

---

### Error diagnosis

When something fails:

1. read the exact error;
2. identify the failing process;
3. inspect its actual input/output contract;
4. test the smallest hypothesis;
5. avoid speculative rewrites;
6. validate the fix before continuing.

---

## Topics to add later

Add entries as they are genuinely learned and applied:

- samplesheet parsing;
- read-group construction;
- MarkDuplicates;
- HaplotypeCaller;
- gVCF workflows;
- GenotypeGVCFs;
- VEP;
- ClinVar;
- MultiQC;
- CI;
- production reference management.
