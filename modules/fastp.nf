process FASTP {

    container 'community.wave.seqera.io/library/fastp:1.3.6--5a6797673f0eb245'

    tag "${sample_id}"

    publishDir "${projectDir}/results/fastp",
        mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), 
        path("${sample_id}_R{1,2}.trimmed.fastq.gz"),
        emit: reads
    
    path "${sample_id}_fastp.html", emit: html
    path "${sample_id}_fastp.json", emit: json

    script:
    """
    fastp \
        --in1 ${reads[0]} \
        --in2 ${reads[1]} \
        --out1 ${sample_id}_R1.trimmed.fastq.gz \
        --out2 ${sample_id}_R2.trimmed.fastq.gz \
        --html ${sample_id}_fastp.html \
        --json ${sample_id}_fastp.json \
        --thread ${task.cpus}
    """
}

