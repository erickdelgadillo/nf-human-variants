process FASTQC {

    tag "${sample_id}"

    publishDir "${projectDir}/results/fastqc",
        mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*_fastqc.html"), emit: html
    tuple val(sample_id), path("*_fastqc.zip"), emit: zip

    script:
    """
    fastqc \
        --threads ${task.cpus} \
        ${reads}
    """
}