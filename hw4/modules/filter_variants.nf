process filter_variants {
    tag "${meta.id}"
    conda 'bioconda::bcftools=1.21'
    publishDir "${params.outdir}/filtered_variants", mode: 'copy'

  

    input:
        tuple val(meta), path(vcf)

    output:
        tuple val(meta), path("${meta.id}.filtered.vcf.gz"), emit: vcf

    stub:
    """
    touch ${meta.id}.filtered.vcf.gz
    """

    script:
    """
    bcftools filter \\
        -e 'QUAL<20 || INFO/DP<10' \\
        -O z \\
        -o ${meta.id}.filtered.vcf.gz \\
        ${vcf}
    """
}