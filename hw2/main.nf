nextflow.enable.dsl = 2

params.input_reads_folder = null
params.sra_id = null
params.reference = null
params.adapters = 'TruSeq3-PE.fa'
params.outdir = 'results'

include { download_sra } from './modules/download_sra.nf'
include { run_qc as qc_initial; run_qc as qc_trimmed } from './modules/qc.nf'
include { trimm } from './modules/trim.nf'
include { assemble } from './modules/assemble.nf'
include { map_reads } from './modules/map.nf'
include { coverage } from './modules/coverage.nf'

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
}
