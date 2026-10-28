# nf-human-variants — Test Evidence Log

This file records concrete workflow executions.

Do not treat a configured test profile as equivalent to a successful test.
Each entry should record the exact command, repository state, result, and inspected outputs.

---

## Test record template

### Date

YYYY-MM-DD

### Git state

- Branch:
- Commit:

### Goal

What was this run intended to verify?

### Command

```bash
# exact command
```

### Inputs

- Reads:
- Reference:
- Profile:
- Other parameters:

### Result

- Exit status:
- Successful processes:
- Failed processes:

### Outputs inspected

- FASTQC:
- fastp:
- BAM:
- BAI:
- flagstat:
- Other:

### Sample-association checks

For multi-sample runs, verify explicitly:

- each BAM belongs to the expected sample;
- each BAI matches the expected BAM;
- each flagstat report belongs to the expected sample;
- metadata IDs remain correct.

### Errors / warnings

```text
# exact messages if relevant
```

### Conclusion

State only what this run demonstrates.

Examples:

- "Single-sample test completed through BAM + BAI + flagstat."
- "Two-sample run preserved correct BAM/BAI/flagstat associations."
- "This run does not validate biological variant-calling accuracy."

---

## Local Ubuntu smoke test — 2026-10-28

### Git state
- Branch: `main`
- Commit confirmed after execution: `b055a57` (PR #22 merge)

### Goal
Reproduce the test-profile preprocessing, reference preparation, alignment, and alignment-QC pipeline on the local Ubuntu workstation.

### Command
```bash
nextflow run main.nf -profile test
```

### Inputs and environment
- Profile: `test`
- Paired-end input glob: `data/*_{R1,R2}.fastq.gz` (as configured in `conf/test.config`)
- Reference: `reference/genome.fasta`
- Nextflow: 26.04.6
- Environment prompt: `(nf-core)`

### Observed execution
All nine process invocations reached `[100%] 1 of 1 ✔`:
- `PREPARE_REFERENCE`: BWA_MEM2_INDEX, SAMTOOLS_FAIDX, GATK4_CREATESEQUENCEDICTIONARY
- `PROCESS_READS`: FASTQC, FASTP, BWA_MEM2, SAMTOOLS_SORT, SAMTOOLS_INDEX, SAMTOOLS_FLAGSTAT

No failed process appears in the shared terminal output.

### Output evidence
- `results/fastqc/`: R1 and R2 FastQC HTML and ZIP reports, listed in terminal output.
- `results/fastp/`: HTML, JSON, and trimmed paired FASTQ files, listed in terminal output.
- `work/8f/d517071c383acfc4ad51f648189170/human_germline.bam`: reported size 327405 bytes.
- `work/a7/626362fabaf6f70d71cfd4ba62fbc7/human_germline.bam.bai`: reported size 176 bytes.
- `work/41/778861eec347c3e5cb05d4a6c75580/human_germline.flagstat`: reported size 493 bytes.

Other copies of these artifacts were also listed under `work/`; their history and contents were not inspected. The paths above match process task IDs in this run.

### Limitations and follow-up
- Artifact presence and nonzero sizes were verified from user-supplied terminal output; BAM/BAI integrity, flagstat metrics, and biological concordance were **not** independently inspected.
- This was a single-sample test and does not demonstrate multi-sample identity correctness.
- Variant calling, truth-set accuracy, and real-data robustness are not tested.
- No changes to tracked project code were reported as part of the local run.
- Next step: inspect flagstat and BAM integrity with samtools, then develop multi-sample tests.

---

## Current evidence status

Historical notes below describe the original document status, updated where superseded:

- a test profile exists;
- development executions have been reported during project development;
- no reproducible multi-sample test record is yet documented here;
- GitHub Actions synthetic paired-end smoke-test CI was introduced in PR #22;
- no truth-set benchmark exists;
- variant-calling validation is not applicable because variant calling is not yet implemented.

Add future executions here as they occur rather than reconstructing unverifiable historical details.
