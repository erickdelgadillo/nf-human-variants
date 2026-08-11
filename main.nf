include { FASTQC } from './modules/fastqc'

workflow {

    reads_ch = Channel
        .fromFilePairs(
            "${projectDir}/data/*_{R1,R2}.fastq.gz",
            checkIfExists: true
        )

    FASTQC(reads_ch)
}