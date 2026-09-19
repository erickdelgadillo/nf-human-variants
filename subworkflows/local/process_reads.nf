include { FASTQC            } from '../../modules/local/fastqc'
include { FASTP             } from '../../modules/local/fastp'
include { BWA_MEM2          } from '../../modules/local/bwa_mem2'
include { SAMTOOLS_SORT     } from '../../modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX    } from '../../modules/nf-core/samtools/index/main'
include { SAMTOOLS_FLAGSTAT } from '../../modules/nf-core/samtools/flagstat/main'

workflow PROCESS_READS {

    take:
    reads_ch
    reference_fasta
    bwa_index

    main:

    FASTQC(reads_ch)

    FASTP(reads_ch)

    BWA_MEM2(
        FASTP.out.reads,
        reference_fasta,
        bwa_index
    )

    reference_for_sort = Channel.value([[:], [], []])
    index_format = Channel.value('')

    SAMTOOLS_SORT(
        BWA_MEM2.out.sam,
        reference_for_sort,
        index_format
    )

    SAMTOOLS_INDEX(
        SAMTOOLS_SORT.out.bam
    )

    bam_bai_ch = SAMTOOLS_SORT.out.bam.join(
        SAMTOOLS_INDEX.out.index
    )

    SAMTOOLS_FLAGSTAT(
        bam_bai_ch
    )

    emit:
    bam      = SAMTOOLS_SORT.out.bam
    bai      = SAMTOOLS_INDEX.out.index
    flagstat = SAMTOOLS_FLAGSTAT.out.flagstat
}