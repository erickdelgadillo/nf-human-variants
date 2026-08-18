include { FASTQC } from './modules/fastqc'
include { FASTP } from './modules/fastp'
include { BWA_MEM2_INDEX } from './modules/bwa_mem2_index'

workflow {

    reads_ch = Channel
        .fromFilePairs(
            params.reads,
            checkIfExists: true
        )

    FASTQC(reads_ch)
    FASTP(reads_ch)

    reference_ch = Channel.fromPath(
        "${projectDir}/data/reference/genome.fasta",
        checkIfExists: true
    )
    BWA_MEM2_INDEX(reference_ch),
    BWA_MEM2_INDEX.out.view()    
}
