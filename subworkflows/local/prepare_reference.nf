include { BWA_MEM2_INDEX                 } from '../../modules/local/bwa_mem2_index'
include { SAMTOOLS_FAIDX                 } from '../../modules/nf-core/samtools/faidx/main'
include { GATK4_CREATESEQUENCEDICTIONARY } from '../../modules/nf-core/gatk4/createsequencedictionary/main'


workflow PREPARE_REFERENCE {

    take:
    reference_ch

    main:

    reference_gatk_ch = reference_ch.map { fasta ->
        def meta = [
            id: 'reference'
        ]

        tuple(meta, fasta)
    }

    reference_faidx_ch = reference_ch.map { fasta ->
        def meta = [
            id: 'reference'
        ]

        tuple(meta, fasta, [])
    }

    BWA_MEM2_INDEX(reference_ch)

    SAMTOOLS_FAIDX(
        reference_faidx_ch,
        false
    )

    GATK4_CREATESEQUENCEDICTIONARY(
        reference_gatk_ch
    )

    emit:
    fasta       = BWA_MEM2_INDEX.out.fasta
    bwa_index   = BWA_MEM2_INDEX.out.index
    fai         = SAMTOOLS_FAIDX.out.fai
    dict        = GATK4_CREATESEQUENCEDICTIONARY.out.dict
}