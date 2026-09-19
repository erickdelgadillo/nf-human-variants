include { PREPARE_REFERENCE } from '../subworkflows/local/prepare_reference'
include { PROCESS_READS     } from '../subworkflows/local/process_reads'

workflow NF_HUMAN_VARIANTS {

    reads_ch = Channel
        .fromFilePairs(
            params.reads,
            checkIfExists: true
        )
        .map { sample_id, reads ->
            tuple(
                [
                    id: sample_id,
                    single_end: false
                ],
                reads
            )
        }

    reference_ch = Channel.fromPath(
        params.fasta,
        checkIfExists: true
    )

    PREPARE_REFERENCE(reference_ch)

    PROCESS_READS(
        reads_ch,
        PREPARE_REFERENCE.out.fasta,
        PREPARE_REFERENCE.out.bwa_index
    )
}