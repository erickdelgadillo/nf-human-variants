include { FASTQC } from './modules/fastqc'
include { FASTP } from './modules/fastp'

workflow {

    reads_ch = Channel
        .fromFilePairs(
            params.reads,
            checkIfExists: true
        )

    FASTQC(reads_ch)
    FASTP(reads_ch)
}
