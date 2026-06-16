nextflow.enable.dsl = 2

include { download_sra } from './modules/download_sra.nf'
include { run_qc as qc_initial; run_qc as qc_trimmed } from './modules/qc.nf'
include { trimm } from './modules/trim.nf'
include { assemble } from './modules/assemble.nf'
include { map_reads } from './modules/map.nf'
include { coverage } from './modules/coverage.nf'
include { SAMTOOLS_FAIDX  } from './modules/nf-core/samtools/faidx/main.nf'
include { BCFTOOLS_MPILEUP } from './modules/nf-core/bcftools/mpileup/main.nf'
include { filter_variants } from './modules/filter_variants.nf'

workflow {

    if (params.input_csv) {

        csv_ch = Channel.fromPath(params.input_csv, checkIfExists: true)
            | splitCsv(header: true)
            | map { row ->
                tuple(
                    row.sample_id,
                    row.virus,
                    [ file(row.reads_1, checkIfExists: true),
                      file(row.reads_2, checkIfExists: true) ],
                    file(row.reference, checkIfExists: true)
                )
            }

        reads_ch       = csv_ch.map { label, virus, reads, ref -> tuple(label, reads) }
        label_to_virus = csv_ch.map { label, virus, reads, ref -> tuple(label, virus) }
        refs_by_virus  = csv_ch.map { label, virus, reads, ref -> tuple(virus, ref) }.unique { it[0] }

    } else {

        if (params.sra_id) {
            reads_ch = download_sra(Channel.value(params.sra_id))
        } else {
            reads_ch = Channel.fromFilePairs("${params.input_reads_folder}/*_{1,2}.{fq,fastq}{,.gz}")
        }

        label_to_virus = reads_ch.map { label, reads -> tuple(label, 'default') }
        refs_by_virus  = Channel.of( tuple('default', file(params.reference, checkIfExists: true)) )
    }

    qc_initial('initial', reads_ch)

    trimmed_ch = trimm(reads_ch)

    trimmed_for_qc = trimmed_ch.map { label, r1, r2 -> tuple(label, [r1, r2]) }
    qc_trimmed('trimmed', trimmed_for_qc)

    trimmed_with_ref = trimmed_ch
        .join(label_to_virus)
        .map { label, r1, r2, virus -> tuple(virus, label, r1, r2) }
        .combine(refs_by_virus, by: 0)
        .map { virus, label, r1, r2, ref -> tuple(label, r1, r2, ref) }

    bam_ch = map_reads(trimmed_with_ref)

    coverage(bam_ch)

    SAMTOOLS_FAIDX(
        refs_by_virus.map { virus, ref -> tuple([id: virus], ref, []) },
        false
    )

    indexed_refs = SAMTOOLS_FAIDX.out.fai
        .map { meta, fai -> tuple(meta.id, fai) }
        .join(refs_by_virus)
        .map { virus, fai, ref -> tuple(virus, ref, fai) }

    bam_with_ref = bam_ch
        .join(label_to_virus)
        .map { label, bam, bai, virus -> tuple(virus, label, bam, bai) }
        .combine(indexed_refs, by: 0)

    bam_for_mpileup = bam_with_ref.map { virus, label, bam, bai, ref, fai ->
        tuple([id: label, virus: virus], bam, [], [])
    }
    ref_for_mpileup = bam_with_ref.map { virus, label, bam, bai, ref, fai ->
        tuple([id: virus], ref, fai)
    }

    BCFTOOLS_MPILEUP(bam_for_mpileup, ref_for_mpileup, false)

    filter_variants(BCFTOOLS_MPILEUP.out.vcf)

    filter_variants.out.vcf
        .collect()
        .view { vcfs -> "Filtered VCFs collected: ${vcfs}" }
}