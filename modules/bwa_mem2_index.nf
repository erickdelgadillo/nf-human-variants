process BWA_MEM2_INDEX {

    input:
    path reference

    output:
    path "${reference}*"

    script:
    """
    bwa-mem2 index ${reference}
    """
}
