process BWA_MEM2 {

    container 'community.wave.seqera.io/library/bwa-mem2:2.3--b402a8a421274e88'

    input: 
    tuple val(sample_id), path(reads)
    path reference

    output:
    tuple val(sample_id), path("${sample_id}.sam"), emit: sam

script:
    """
    bwa-mem2 mem \
        -t ${task.cpus} \
        ${reference} \
        ${reads} \
        > ${sample_id}.sam
    """

}

