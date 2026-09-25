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

## Current evidence status

At the time this document was created:

- a test profile exists;
- development executions have been reported during project development;
- no reproducible multi-sample test record is yet documented here;
- no CI test exists;
- no truth-set benchmark exists;
- variant-calling validation is not applicable because variant calling is not yet implemented.

Add future executions here as they occur rather than reconstructing unverifiable historical details.
