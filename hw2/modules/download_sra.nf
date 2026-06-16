process download_sra {
    tag "$sra_id"
    conda 'bioconda::sra-tools=3.2.1'

    input:
        val sra_id

    output:
        tuple val(sra_id), path("${sra_id}_{1,2}.fastq.gz")

    script:
    """
    prefetch ${sra_id}
    fasterq-dump ${sra_id} --split-files --threads ${task.cpus}
    gzip ${sra_id}_1.fastq ${sra_id}_2.fastq
    """
}
