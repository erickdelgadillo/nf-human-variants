process BWA_MEM2_INDEX {

    container 'community.wave.seqera.io/library/bwa-mem2:2.3--b402a8a421274e88'

    input:
    path reference

    output:
    path reference, emit: fasta
    path "${reference}.*", emit: index

    script:
    """
    bwa-mem2 index ${reference}
    """
}
