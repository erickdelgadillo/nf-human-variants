include { FASTQC } from './modules/fastqc'

workflow {

    reads_ch = Channel
        .fromFilePairs(
            params.reads,
            checkIfExists: true
        )

    FASTQC(reads_ch)
}