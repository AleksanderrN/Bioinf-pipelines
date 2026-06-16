process run_qc {
    tag "${reads_type}_${reads_label}"
    conda 'bioconda::fastqc=0.12.1'

    input:
        val reads_type
        tuple val(reads_label), path(reads)

    output:
        path "${reads_type}_qc_report"

    script:
    """
    mkdir ${reads_type}_qc_report
    fastqc -o ${reads_type}_qc_report/ $reads
    """
}
