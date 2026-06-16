nextflow.enable.dsl = 2

include { download_sra } from './modules/download_sra.nf'
include { run_qc as qc_initial; run_qc as qc_trimmed } from './modules/qc.nf'
include { trimm } from './modules/trim.nf'
include { assemble } from './modules/assemble.nf'
include { map_reads } from './modules/map.nf'
include { coverage } from './modules/coverage.nf'
include { SAMTOOLS_FAIDX  } from './modules/nf-core/samtools/faidx/main.nf'
include { BCFTOOLS_MPILEUP } from './modules/nf-core/bcftools/mpileup/main.nf'

workflow {

    if (params.sra_id) {
        reads_ch = download_sra(Channel.value(params.sra_id))
    } else {
        reads_ch = Channel.fromFilePairs("${params.input_reads_folder}/*_{1,2}.{fq,fastq}{,.gz}")
    }

    qc_initial('initial', reads_ch)

    trimmed_ch = trimm(reads_ch)

    trimmed_for_qc = trimmed_ch.map { label, r1, r2 -> tuple(label, [r1, r2]) }
    qc_trimmed('trimmed', trimmed_for_qc)

    if (params.reference) {
        reference_ch = Channel.fromPath(params.reference)
    } else {
        reference_ch = assemble(trimmed_ch).reference
    }

    bam_ch = map_reads(trimmed_ch, reference_ch)

    coverage(bam_ch)

    ref_for_faidx = reference_ch.map { ref -> tuple([id: 'ref'], ref, []) }

    SAMTOOLS_FAIDX(ref_for_faidx, false)
    fai_ch = SAMTOOLS_FAIDX.out.fai

    ref_for_mpileup = reference_ch
    .map { ref -> tuple([id: 'ref'], ref) }
    .join(fai_ch)
    .map { meta, ref, fai -> tuple(meta, ref, fai) }

    bam_for_mpileup = bam_ch.map { label, bam, bai -> 
    tuple([id: label], bam, [], []) 
    }

    BCFTOOLS_MPILEUP(bam_for_mpileup, ref_for_mpileup, false)

}
