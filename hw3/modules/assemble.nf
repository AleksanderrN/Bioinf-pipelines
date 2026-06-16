process assemble {
    tag "$reads_label"
    conda 'bioconda::spades=4.0.0'
    publishDir "${params.outdir}/assembly", mode: 'copy'

    input:
        tuple val(reads_label), path(r1), path(r2)

    output:
        path "${reads_label}_scaffolds.fasta", emit: reference

    script:
    """
    spades.py -1 $r1 -2 $r2 -o spades_out --only-assembler -m 10 -t ${task.cpus}
    cp spades_out/scaffolds.fasta ${reads_label}_scaffolds.fasta
    """
}
