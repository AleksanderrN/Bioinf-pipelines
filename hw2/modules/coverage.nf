process coverage {
    tag "$reads_label"
    conda 'bioconda::samtools=1.21 conda-forge::matplotlib=3.9.2 conda-forge::pandas=2.2.3'
    publishDir "${params.outdir}/coverage", mode: 'copy'

    input:
        tuple val(reads_label), path(bam), path(bai)

    output:
        path "${reads_label}_depth.tsv"
        path "${reads_label}_coverage.png"

    script:
    """
    samtools depth -a $bam > ${reads_label}_depth.tsv
    plot_coverage.py ${reads_label}_depth.tsv ${reads_label} ${reads_label}_coverage.png
    """
}
