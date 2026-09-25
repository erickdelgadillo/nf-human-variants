# nf-human-variants — Project Context

## 1. Why this project exists

`nf-human-variants` was created as a practical workflow-engineering project for learning and demonstrating modern bioinformatics development with Nextflow DSL2.

The project has two parallel goals.

### Technical goal

Build a modular, reproducible workflow for human germline SNP and small-indel analysis.

### Learning / portfolio goal

Use the workflow to develop demonstrable competence in:

- Nextflow DSL2;
- nf-core conventions;
- modular workflow architecture;
- channel design;
- metadata propagation;
- containers;
- reproducibility;
- testing;
- Git-based incremental development;
- germline variant analysis.

The project is intentionally built step by step rather than by generating a complete pipeline at once.

Understanding the architecture is part of the objective.

---

## 2. Scientific scope

Current scope:

```text
human germline variants
SNPs
small indels
short-read paired-end sequencing
```

Current non-goals:

```text
somatic calling
tumor/normal analysis
structural variants
CNVs
clinical diagnostics
medical decision support
```

These should not be introduced until the current germline workflow is mature.

---

## 3. Long-term conceptual workflow

The intended architecture is approximately:

```text
FASTQ
   ↓
raw-read QC
   ↓
read preprocessing
   ↓
alignment
   ↓
BAM processing
   ↓
germline variant calling
   ↓
variant QC / filtering
   ↓
annotation
   ↓
downstream exploration
```

Potential future downstream layer:

```text
nf-human-variants
        ↓
  annotated VCF
        ↓
    LocusLens
```

`LocusLens` should remain a separate project unless a future architectural decision explicitly changes this.

---

## 4. Current verified architecture

The current repository uses:

```text
main.nf
    ↓
workflows/nf_human_variants.nf
    ├── PREPARE_REFERENCE
    └── PROCESS_READS
```

This hierarchy is deliberate.

`main.nf` remains minimal and delegates orchestration to the workflow layer.

Subworkflows group related functional operations.

Individual processes remain modular.

---

## 5. Current implemented workflow

### Reads

```text
paired FASTQ
    │
    ├── FastQC
    │
    └── fastp
          ↓
      BWA-MEM2
          ↓
          SAM
          ↓
     samtools sort
          ↓
     sorted BAM
       ├── samtools index
       └── samtools flagstat
```

### Reference

```text
reference FASTA
    ├── BWA-MEM2 index
    ├── samtools faidx
    └── GATK CreateSequenceDictionary
```

Current endpoint:

```text
sorted BAM
BAI
flagstat metrics
```

Variant calling has not yet been implemented.

---

## 6. Module strategy

### Local modules

Currently used for:

- FastQC
- fastp
- BWA-MEM2
- BWA-MEM2 index

### nf-core modules

Currently used for:

- samtools faidx
- samtools sort
- samtools index
- samtools flagstat
- GATK CreateSequenceDictionary

### Design principle

Use official nf-core modules for standardized operations when they fit the workflow.

Do not modify upstream modules casually.

Local modules should have a concrete reason to exist.

---

## 7. Metadata philosophy

A major design transition in the project was moving toward explicit `(meta, data)` structures.

Current conceptual pattern:

```text
(meta, reads)
(meta, trimmed_reads)
(meta, SAM)
(meta, BAM)
```

The purpose is to keep biological/sample identity separate from filename conventions.

The current workflow still originates metadata from `Channel.fromFilePairs`.

That is temporary.

The planned samplesheet will make metadata explicit.

---

## 8. Input evolution

### Current

Filename-driven paired-end input.

Example pattern:

```text
*_{R1,R2}.fastq.gz
```

### Next

Validated samplesheet.

Initial candidate:

```csv
sample,fastq_1,fastq_2
NA12878,path/to/NA12878_R1.fastq.gz,path/to/NA12878_R2.fastq.gz
```

The initial schema should remain intentionally small.

Do not preemptively add metadata fields that are not yet required.

---

## 9. Development philosophy

The workflow should be developed incrementally.

Preferred development cycle:

```text
understand
→ inspect current code
→ consult primary documentation
→ make one coherent change
→ execute
→ inspect outputs/errors
→ correct
→ re-run
→ commit
→ document if necessary
```

Avoid:

- large speculative refactors;
- implementing several future stages simultaneously;
- accepting generated code without understanding it;
- treating successful execution as proof of biological correctness.

---

## 10. Error-solving philosophy

When a workflow run fails:

1. Read the exact error.
2. Identify the failing Nextflow process.
3. Inspect its real inputs and outputs.
4. Inspect the relevant channel structure.
5. Check the exact module signature.
6. Propose the smallest diagnostic step.
7. Validate the hypothesis.
8. Modify only what is justified.
9. Re-run.

Do not rewrite several modules because of one error unless evidence requires it.

---

## 11. Important concepts learned through the project

### Nextflow DSL2

The project has been used to learn:

- modules;
- workflows;
- subworkflows;
- channels;
- value channels;
- tuples;
- metadata propagation;
- process inputs/outputs;
- module interfaces;
- configuration profiles.

### nf-core

Important lessons include:

- official modules have strict interfaces;
- metadata tuple shapes matter;
- upstream modules should usually remain unchanged;
- `modules.json` records module provenance;
- configuration should remain separate from module implementation when possible.

### Reproducibility

Containers improve reproducibility but do not guarantee it alone.

Reproducibility also depends on:

- software versions;
- reference provenance;
- test-data provenance;
- configuration;
- resource settings;
- deterministic inputs;
- documentation;
- automated testing.

---

## 12. Current configuration

Current primary configuration file:

```text
nextflow.config
```

Current test configuration:

```text
conf/test.config
```

Docker is enabled.

Main parameters currently include:

```text
reads
fasta
outdir
```

Development execution:

```bash
nextflow run main.nf -profile test
```

Resume execution:

```bash
nextflow run main.nf -profile test -resume
```

---

## 13. Known architectural weak points

### Filename-based identity

Sample identity currently originates from filename conventions.

This is insufficient as the permanent input contract.

### Multi-sample robustness

Some channel operations, especially BAM/BAI association, need explicit validation with multiple samples.

### Read groups

A formal BWA-MEM2 read-group strategy does not yet exist.

### Duplicate handling

No duplicate-handling stage exists yet.

### BAM boundary

The project must formally define what constitutes an `analysis-ready BAM`.

### Output routing

`params.outdir` is not yet used uniformly by all local processes.

### Resources

CPU and memory configuration are still incomplete.

### Automated testing

A development profile exists, but no CI currently executes it.

### Test-data provenance

The small development dataset should eventually be generated or obtained in a documented reproducible way.

---

## 14. Important decisions already made

### GitHub is authoritative

The current default branch is the source of truth for implementation.

Stored project files can become stale.

### Build incrementally

One functional unit at a time.

### Prefer nf-core

Use community modules when appropriate.

### Germline first

Do not expand into somatic/SV/CNV analysis yet.

### Samplesheet before GATK

Explicit sample identity and metadata must be established before the variant-calling stage.

### Separate BAM processing

Duplicate handling should become its own functional layer, conceptually:

```text
PROCESS_READS
    ↓
PROCESS_BAM
    ↓
GATK
```

### Keep LocusLens separate

Variant interpretation/visualization is a downstream concern.

---

## 15. Current development checkpoint

The current functional workflow is:

```text
FASTQ
→ FastQC
→ fastp
→ BWA-MEM2
→ SAM
→ samtools sort
→ BAM
→ samtools index
→ BAI
→ samtools flagstat
```

Reference preparation includes:

```text
BWA-MEM2 index
samtools faidx
GATK CreateSequenceDictionary
```

No variant calling is currently implemented.

---

## 16. Current exact development task

Implement:

```text
samplesheet.csv
```

The first version should support:

```text
sample
fastq_1
fastq_2
```

Requirements:

- validate columns;
- validate file paths;
- maintain paired-end structure;
- construct stable metadata;
- maintain `(meta, reads)`;
- test multiple samples;
- maintain downstream sample association.

---

## 17. Decisions still open for the samplesheet task

These should be resolved during implementation:

### Meaning of `meta.id`

Recommended initial interpretation:

```text
stable biological sample identifier
```

but it should be explicitly agreed before implementation is finalized.

### Backward compatibility

Decide whether:

```text
--reads glob
```

remains temporarily supported alongside:

```text
--input samplesheet.csv
```

or whether samplesheet becomes the only supported interface immediately.

### Validation location

Decide whether validation lives in:

- Nextflow logic;
- a dedicated helper function;
- a dedicated script;
- another clean validation layer.

Avoid scattered validation logic.

---

## 18. Immediate future roadmap

```text
NOW
samplesheet
metadata contract
multi-sample validation

NEXT
read groups
duplicate handling
analysis-ready BAM
HaplotypeCaller

LATER
gVCF workflow
GenotypeGVCFs
variant QC
VEP
ClinVar
MultiQC
GRCh38 production configuration
automated tests
CI
```

---

## 19. Testing philosophy

Tests should answer specific engineering questions.

Examples:

### Samplesheet test

Does each row generate the correct `(meta, reads)`?

### Multi-sample test

Do sample A and sample B preserve correct identities through:

```text
fastp
alignment
sort
index
flagstat
```

### Invalid-input test

Does the pipeline fail clearly when:

- R1 is missing;
- R2 is missing;
- sample ID is empty;
- a path is invalid;
- required columns are absent?

### Later truth-set validation

Once variant calling exists, use appropriate public human benchmarking resources such as Genome in a Bottle / NIST.

---

## 20. Documentation policy

Documentation should reflect code but must not be used as stronger evidence than code.

Always distinguish:

```text
IMPLEMENTED
TESTED
DOCUMENTED
PLANNED
```

When README and implementation disagree:

```text
current GitHub code wins
```

---

## 21. Primary technical sources

Prefer:

1. Nextflow official documentation.
2. nf-core documentation and repositories.
3. Official documentation of each bioinformatics tool.
4. GATK / Broad Institute.
5. samtools / htslib.
6. Ensembl VEP.
7. NIST / Genome in a Bottle.

Secondary sources may include:

- GitHub Issues;
- forums;
- Stack Overflow;
- technical blogs.

Do not let secondary sources override current official documentation without a technical reason.

---

## 22. Repository review rule

Before proposing a substantial implementation change:

1. inspect the current default branch;
2. inspect recent relevant commits;
3. inspect the workflow and subworkflow affected;
4. inspect exact process/module signatures;
5. inspect `nextflow.config`;
6. inspect `conf/test.config`;
7. inspect the relevant channels and metadata;
8. then propose the smallest coherent change.

---

## 23. Source hierarchy

When information conflicts:

1. Current GitHub default branch.
2. Explicit recent project decisions.
3. `CURRENT_PROJECT_CHECKPOINT.md`.
4. This file.
5. `README.md`.
6. Older files, PDFs, or conversations.

The repository defines what exists.

This document explains why the project is built this way.
