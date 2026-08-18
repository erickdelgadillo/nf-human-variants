process BWA_MEM2 {

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

