import gzip
import random
from pathlib import Path

random.seed(42)

reference_path = Path("reference/genome.fasta")
output_dir = Path("data")

n_pairs = 10_000
read_length = 100
fragment_length = 250

output_dir.mkdir(exist_ok=True)


def reverse_complement(seq):
    complement = str.maketrans("ACGTN", "TGCAN")
    return seq.translate(complement)[::-1]


# Read reference FASTA
with open(reference_path) as handle:
    sequence = "".join(
        line.strip()
        for line in handle
        if not line.startswith(">")
    ).upper()

r1_path = output_dir / "human_germline_R1.fastq.gz"
r2_path = output_dir / "human_germline_R2.fastq.gz"

quality = "I" * read_length

with gzip.open(r1_path, "wt") as r1, gzip.open(r2_path, "wt") as r2:

    for i in range(1, n_pairs + 1):

        start = random.randint(
            0,
            len(sequence) - fragment_length
        )

        fragment = sequence[start:start + fragment_length]

        read1 = fragment[:read_length]
        read2 = reverse_complement(fragment[-read_length:])

        r1.write(
            f"@synthetic_{i}/1\n"
            f"{read1}\n"
            "+\n"
            f"{quality}\n"
        )

        r2.write(
            f"@synthetic_{i}/2\n"
            f"{read2}\n"
            "+\n"
            f"{quality}\n"
        )

print(f"Generated {n_pairs} paired-end reads")
print(r1_path)
print(r2_path)
