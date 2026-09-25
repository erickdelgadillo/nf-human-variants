# nf-human-variants — Architectural Decisions

This file records decisions that should remain stable across development sessions.

## AD-001 — GitHub is the source of truth

The current default branch of `erickdelgadillo/nf-human-variants` is the authoritative source for implementation state.

Project files, PDFs, checkpoints, and prior conversations are contextual snapshots and may become outdated.

When sources conflict, use this priority:

1. Current GitHub repository code.
2. Explicit decisions made in recent project sessions.
3. `CURRENT_PROJECT_CHECKPOINT.md`.
4. `PROJECT_CONTEXT.md`.
5. `README.md`.
6. Older project files or conversations.

Do not claim that a component is implemented unless the current repository supports that conclusion.

---

## AD-002 — Incremental development

Develop one functional unit at a time.

Preferred cycle:

1. Define the technical problem.
2. Inspect the current repository.
3. Check official documentation.
4. Implement the smallest coherent change.
5. Run the workflow.
6. Inspect outputs and errors.
7. Fix only the verified problem.
8. Re-run.
9. Commit.
10. Update documentation when needed.

Avoid large speculative rewrites.

---

## AD-003 — Prefer nf-core modules

Use official nf-core modules when they are suitable for the task.

Local modules should be used when:

- no suitable nf-core module exists;
- the project needs behavior that the official module does not provide;
- the local implementation has a clear educational or architectural purpose.

Do not modify upstream nf-core module code unnecessarily.

Resource configuration and project-specific execution settings should preferably live outside upstream module code.

---

## AD-004 — Current scientific scope

The current scope is human **germline SNP and small-indel analysis**.

Out of immediate scope:

- somatic variant calling;
- tumor/normal workflows;
- structural variants;
- CNVs;
- clinical diagnosis;
- medical decision support.

These areas should not be introduced before the core germline workflow is complete and validated.

---

## AD-005 — Samplesheet before variant calling

Before introducing GATK variant calling, formalize sample input and metadata.

The initial samplesheet should remain minimal unless a concrete downstream requirement justifies additional fields.

Initial candidate schema:

```csv
sample,fastq_1,fastq_2
NA12878,path/to/R1.fastq.gz,path/to/R2.fastq.gz
```

Later fields may include library, lane, platform, and explicit read-group metadata if required.

---

## AD-006 — Metadata must remain explicit

Sample identity should not depend indefinitely on filename inference.

Metadata propagated through the workflow should be explicit, stable, and compatible with downstream GATK requirements.

Before read groups are implemented, define clearly what `meta.id` represents.

---

## AD-007 — Separate BAM preparation from read processing

Duplicate handling and later BAM preparation should be implemented as a separate functional unit rather than being hidden inside the current read-processing subworkflow.

Conceptual boundary:

```text
PROCESS_READS
    ↓
sorted BAM + BAI
    ↓
PROCESS_BAM
    ↓
analysis-ready BAM + BAI + duplicate metrics
```

This keeps the workflow modular and prepares a clean interface for GATK.

---

## AD-008 — LocusLens remains separate

`LocusLens` is a potential downstream visualization, prioritization, or interpretation layer.

It should remain conceptually separate from the core Nextflow germline workflow unless a future architectural decision explicitly changes this.

Conceptual relationship:

```text
nf-human-variants
    ↓
VCF / annotated variants
    ↓
LocusLens
```

---

## AD-009 — A successful run is not sufficient validation

Distinguish explicitly between:

- IMPLEMENTED
- TESTED
- DOCUMENTED
- PLANNED

These states are not equivalent.

A process that executes successfully is not automatically biologically valid or production-ready.

---

## AD-010 — Prefer primary technical sources

For implementation decisions, prioritize:

1. Nextflow documentation.
2. nf-core documentation and repositories.
3. Official tool documentation.
4. GATK / Broad Institute.
5. samtools / htslib.
6. Ensembl VEP.
7. NIST / Genome in a Bottle.

Use forums, blogs, GitHub Issues, and Stack Overflow as secondary evidence.
