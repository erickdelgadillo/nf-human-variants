"""Write small, deterministic paired-end test reads from the committed reference."""
import gzip
from pathlib import Path

root = Path(__file__).resolve().parents[1]
reference = root / "reference/genome.fasta"
sequence = "".join(line.strip() for line in reference.read_text().splitlines() if not line.startswith(">"))
sequence = sequence.upper()
if len(sequence) < 300:
    raise ValueError("Reference must contain at least 300 bases")
output = root / "tests/ci_data"
output.mkdir(parents=True, exist_ok=True)
for mate, offset in [(1, 0), (2, 70)]:
    with gzip.open(output / f"synthetic_R{mate}.fastq.gz", "wt") as handle:
        for i in range(20):
            read = sequence[offset + i:offset + i + 80]
            if any(base not in "ACGT" for base in read):
                raise ValueError("Synthetic read contains ambiguous bases")
            handle.write(f"@read{i}/{mate}\n{read}\n+\n{'I' * len(read)}\n")
