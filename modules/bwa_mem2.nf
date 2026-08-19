process BWA_MEM2 {

    container 'community.wave.seqera.io/library/bwa-mem2:2.2.1--9971ea336a9eddae'

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

