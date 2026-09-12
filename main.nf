// -----------------------------------------------------------------------------
// Módulos del pipeline
// -----------------------------------------------------------------------------

include { FASTQC } from './modules/local/fastqc'
include { FASTP } from './modules/local/fastp'

include { BWA_MEM2_INDEX } from './modules/local/bwa_mem2_index'
include { BWA_MEM2 } from './modules/local/bwa_mem2'

include { SAMTOOLS_SORT } from './modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX } from './modules/nf-core/samtools/index/main'
include { SAMTOOLS_FAIDX } from './modules/nf-core/samtools/faidx/main'
include { SAMTOOLS_FLAGSTAT } from './modules/nf-core/samtools/flagstat/main'

include { GATK4_CREATESEQUENCEDICTIONARY } from './modules/nf-core/gatk4/createsequencedictionary/main'


workflow {

    // -------------------------------------------------------------------------
    // 1. Descubrimiento de FASTQ paired-end
    // -------------------------------------------------------------------------
    //
    // params.reads contiene el patrón de búsqueda definido en nextflow.config.
    //
    // fromFilePairs agrupa automáticamente los FASTQ R1 y R2 pertenecientes
    // a la misma muestra.
    //
    // El channel resultante tiene conceptualmente esta estructura:
    //
    // (sample_id, [R1.fastq.gz, R2.fastq.gz])
    //
    reads_ch = Channel
        .fromFilePairs(
            params.reads,
            checkIfExists: true
        )


    // -------------------------------------------------------------------------
    // 2. Control de calidad y preprocesamiento de reads
    // -------------------------------------------------------------------------

    // FASTQC analiza la calidad de los reads originales.
    FASTQC(reads_ch)

    // FASTP realiza trimming y filtrado de los reads.
    // Su output será utilizado posteriormente para el alineamiento.
    FASTP(reads_ch)


    // -------------------------------------------------------------------------
    // 3. Referencia genómica
    // -------------------------------------------------------------------------
    //
    // Creamos un channel que contiene el FASTA de referencia.
    //
    reference_ch = Channel.fromPath(
        "${projectDir}/reference/genome.fasta",
        checkIfExists: true
    )


    // -------------------------------------------------------------------------
    // 4. Preparación de la referencia para GATK
    // -------------------------------------------------------------------------
    //
    // El módulo nf-core de GATK no espera únicamente el FASTA.
    // Espera una tupla con:
    //
    // (meta, fasta)
    //
    // Por eso transformamos reference_ch y añadimos metadata.
    //
    reference_gatk_ch = reference_ch.map { fasta ->

        def meta = [
            id: 'reference'
        ]

        tuple(meta, fasta)
    }


    // -------------------------------------------------------------------------
    // 5. Índice de referencia para BWA-MEM2
    // -------------------------------------------------------------------------
    //
    // BWA-MEM2 necesita sus propios archivos de índice para poder alinear
    // los reads contra el genoma de referencia.
    //
    BWA_MEM2_INDEX(reference_ch)


    // -------------------------------------------------------------------------
    // 6. Índice FASTA (.fai) con samtools faidx
    // -------------------------------------------------------------------------
    //
    // SAMTOOLS_FAIDX espera una tupla con:
    //
    // (meta, fasta, fai)
    //
    // Como todavía NO existe un archivo .fai, pasamos [] en esa posición.
    // Esto indica al módulo que debe generarlo.
    //
    reference_faidx_ch = reference_ch.map { fasta ->

        def meta = [
            id: 'reference'
        ]

        tuple(meta, fasta, [])
    }

    // false indica que no necesitamos generar información adicional
    // sobre los tamaños de las secuencias.
    SAMTOOLS_FAIDX(
        reference_faidx_ch,
        false
    )


    // -------------------------------------------------------------------------
    // 7. Sequence dictionary (.dict) para GATK
    // -------------------------------------------------------------------------
    //
    // GATK utiliza un sequence dictionary para describir los contigs
    // de la referencia (nombre, longitud, checksum, etc.).
    //
    GATK4_CREATESEQUENCEDICTIONARY(
        reference_gatk_ch
    )


    // -------------------------------------------------------------------------
    // 8. Alineamiento de reads con BWA-MEM2
    // -------------------------------------------------------------------------
    //
    // Entradas:
    //   1. reads procesados por FASTP
    //   2. FASTA de referencia
    //   3. índices generados por BWA-MEM2
    //
    // El resultado es un archivo SAM por muestra.
    //
    BWA_MEM2(
        FASTP.out.reads,
        BWA_MEM2_INDEX.out.fasta,
        BWA_MEM2_INDEX.out.index
    )


    // -------------------------------------------------------------------------
    // 9. Adaptación del output de BWA al formato esperado por nf-core
    // -------------------------------------------------------------------------
    //
    // Nuestro módulo BWA_MEM2 devuelve:
    //
    // (sample_id, sam)
    //
    // Pero SAMTOOLS_SORT espera:
    //
    // (meta, sam/bam)
    //
    // Por eso transformamos sample_id en un mapa de metadata.
    //
    sam_ch = BWA_MEM2.out.sam.map { sample_id, sam ->

        def meta = [
            id: sample_id,
            single_end: false
        ]

        tuple(meta, sam)
    }


    // -------------------------------------------------------------------------
    // 10. Parámetros auxiliares para SAMTOOLS_SORT
    // -------------------------------------------------------------------------
    //
    // El módulo nf-core permite utilizar una referencia durante el sorting,
    // pero en nuestro caso no es necesaria.
    //
    // Por eso pasamos una referencia vacía.
    //
    reference_for_sort = Channel.value([[:], [], []])

    // No solicitamos un formato de índice específico durante el sorting.
    index_format = Channel.value('')


    // -------------------------------------------------------------------------
    // 11. Conversión SAM -> BAM y ordenamiento por coordenadas
    // -------------------------------------------------------------------------
    //
    // El SAM generado por BWA se convierte en un BAM ordenado.
    //
    SAMTOOLS_SORT(
        sam_ch,
        reference_for_sort,
        index_format
    )


    // -------------------------------------------------------------------------
    // 12. Indexación del BAM
    // -------------------------------------------------------------------------
    //
    // SAMTOOLS_INDEX recibe:
    //
    // (meta, bam)
    //
    // y produce:
    //
    // (meta, bai)
    //
    SAMTOOLS_INDEX(
        SAMTOOLS_SORT.out.bam
    )


    // -------------------------------------------------------------------------
    // 13. Combinar BAM + BAI para los módulos de QC
    // -------------------------------------------------------------------------
    //
    // SAMTOOLS_SORT devuelve:
    //
    // (meta, bam)
    //
    // SAMTOOLS_INDEX devuelve:
    //
    // (meta, bai)
    //
    // SAMTOOLS_FLAGSTAT necesita ambos archivos juntos:
    //
    // (meta, bam, bai)
    //
    // join utiliza el primer elemento de ambas tuplas (meta)
    // para emparejar el BAM con su índice correspondiente.
    //
    bam_bai_ch = SAMTOOLS_SORT.out.bam.join(
        SAMTOOLS_INDEX.out.index
    )


    // -------------------------------------------------------------------------
    // 14. QC del alineamiento con samtools flagstat
    // -------------------------------------------------------------------------
    //
    // FLAGSTAT calcula métricas básicas del BAM:
    //
    // - número total de reads
    // - reads mapeados
    // - reads correctamente emparejados
    // - singletons
    // - duplicados marcados
    //
    // Este proceso NO modifica el BAM: únicamente genera un informe.
    //
    SAMTOOLS_FLAGSTAT(
        bam_bai_ch
    )
}