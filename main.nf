// -----------------------------------------------------------------------------
// Subworkflows
// -----------------------------------------------------------------------------

include { PREPARE_REFERENCE } from './subworkflows/local/prepare_reference'
include { PROCESS_READS     } from './subworkflows/local/process_reads'


// -----------------------------------------------------------------------------
// Main workflow
// -----------------------------------------------------------------------------

workflow {

    // -------------------------------------------------------------------------
    // 1. FASTQ discovery
    // -------------------------------------------------------------------------

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


    // -------------------------------------------------------------------------
    // 2. Reference genome
    // -------------------------------------------------------------------------

    reference_ch = Channel.fromPath(
        "${projectDir}/reference/genome.fasta",
        checkIfExists: true
    )


    // -------------------------------------------------------------------------
    // 3. Reference preparation
    // -------------------------------------------------------------------------

    PREPARE_REFERENCE(
        reference_ch
    )


    // -------------------------------------------------------------------------
    // 4. Read processing and alignment
    // -------------------------------------------------------------------------

    PROCESS_READS(
        reads_ch,
        PREPARE_REFERENCE.out.fasta,
        PREPARE_REFERENCE.out.bwa_index
    )
}