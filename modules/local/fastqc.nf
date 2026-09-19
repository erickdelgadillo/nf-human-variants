process FASTQC {

    container 'community.wave.seqera.io/library/fastqc:0.12.1--9971ea336a9eddae'

    tag "${meta.id}"

    publishDir "${projectDir}/results/fastqc",
        mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_fastqc.html"), emit: html
    tuple val(meta), path("*_fastqc.zip"), emit: zip

    script:
    """
    fastqc \
        --threads ${task.cpus} \
        ${reads}
    """
}