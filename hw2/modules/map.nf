process map_reads {
    tag "$reads_label"
    conda 'bioconda::bwa=0.7.18 bioconda::samtools=1.21'
    publishDir "${params.outdir}/mapping", mode: 'copy'

    input:
        tuple val(reads_label), path(r1), path(r2)
        path reference

    output:
        tuple val(reads_label), path("${reads_label}.sorted.bam"), path("${reads_label}.sorted.bam.bai")

    script:
    """
    bwa index $reference
    bwa mem -t ${task.cpus} $reference $r1 $r2 | samtools sort -o ${reads_label}.sorted.bam -
    samtools index ${reads_label}.sorted.bam
    """
}
