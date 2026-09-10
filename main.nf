include { FASTQC } from './modules/local/fastqc'
include { FASTP } from './modules/local/fastp'
include { BWA_MEM2_INDEX } from './modules/local/bwa_mem2_index'
include { BWA_MEM2 } from './modules/local/bwa_mem2'
include { SAMTOOLS_SORT } from './modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX } from './modules/nf-core/samtools/index/main'
include { SAMTOOLS_FAIDX } from './modules/nf-core/samtools/faidx/main'
include { GATK4_CREATESEQUENCEDICTIONARY } from './modules/nf-core/gatk4/createsequencedictionary/main'

workflow {

    reads_ch = Channel
        .fromFilePairs(
            params.reads,
            checkIfExists: true
        )

    FASTQC(reads_ch)
    FASTP(reads_ch)

    reference_ch = Channel.fromPath(
        "${projectDir}/reference/genome.fasta",
        checkIfExists: true
    )

    reference_gatk_ch = reference_ch.map { fasta ->

        def meta = [
            id: 'reference'
        ]

        tuple(meta, fasta)
    }

    BWA_MEM2_INDEX(reference_ch)

    reference_faidx_ch = reference_ch.map { fasta ->

        def meta = [
            id: 'reference'
        ]

        tuple(meta, fasta, [])
    }

    SAMTOOLS_FAIDX(
        reference_faidx_ch,
        false
    )

    GATK4_CREATESEQUENCEDICTIONARY(
        reference_gatk_ch
    )

    BWA_MEM2(
        FASTP.out.reads,
        BWA_MEM2_INDEX.out.fasta,
        BWA_MEM2_INDEX.out.index
    )

    sam_ch = BWA_MEM2.out.sam.map { sample_id, sam ->

        def meta = [
            id: sample_id,
            single_end: false
        ]

        tuple(meta, sam)
    }

    reference_for_sort = Channel.value([[:], [], []])
    index_format = Channel.value('')

    SAMTOOLS_SORT(
        sam_ch,
        reference_for_sort,
        index_format
    )

    SAMTOOLS_INDEX(
        SAMTOOLS_SORT.out.bam
    )
}