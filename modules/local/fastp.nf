process FASTP {

    container 'community.wave.seqera.io/library/fastp:1.3.6--5a6797673f0eb245'

    tag "${meta.id}"

    publishDir "${projectDir}/results/fastp",
        mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta),
        path("${meta.id}_R{1,2}.trimmed.fastq.gz"),
        emit: reads

    path "${meta.id}_fastp.html", emit: html
    path "${meta.id}_fastp.json", emit: json

    script:
    """
    fastp \
        --in1 ${reads[0]} \
        --in2 ${reads[1]} \
        --out1 ${meta.id}_R1.trimmed.fastq.gz \
        --out2 ${meta.id}_R2.trimmed.fastq.gz \
        --html ${meta.id}_fastp.html \
        --json ${meta.id}_fastp.json \
        --thread ${task.cpus}
    """
}

