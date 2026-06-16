process trimm {
    tag "$reads_label"
    conda 'bioconda::trimmomatic=0.39'

    input:
        tuple val(reads_label), path(reads)

    output:
        tuple val(reads_label), path("${reads_label}_R1_p.fq.gz"), path("${reads_label}_R2_p.fq.gz")

    script:
    """
    ADAPTER=\$(find \$CONDA_PREFIX/share -name '${params.adapters}' | head -n 1)

    trimmomatic PE -threads ${task.cpus} \\
        ${reads[0]} ${reads[1]} \\
        ${reads_label}_R1_p.fq.gz ${reads_label}_R1_u.fq.gz \\
        ${reads_label}_R2_p.fq.gz ${reads_label}_R2_u.fq.gz \\
        ILLUMINACLIP:\$ADAPTER:2:30:10 \\
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    """
}
