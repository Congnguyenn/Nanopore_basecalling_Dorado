/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SAMTOOLS_DEPTH
    Investigate the depth of coverage of a chr_bam file with -a option
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process SAMTOOLS_DEPTH {
    conda "${projectDir}/envs/samtools.yml"
    label "Samtools_depth"
    tag "$sample"

    input:
        tuple   val(sample),
                path(sorted_bam),
                path(sorted_bai)
        
    output:
        tuple   val(sample),
                path("*.depth.sum.tsv"),
                path("*.coverage.tsv")                 , emit: samtools
    
    script:
    """
    samtools depth \
                --threads ${task.cpus} \
                -a \
                ${sorted_bam} \
                > ${sample}_depth.tsv

    awk '{print \$3}' ${sample}_depth.tsv | sort | uniq -c | awk '{print \$2 "\\t" \$1}' > ${sample}.depth.sum.tsv

    samtools coverage \
                ${sorted_bam} \
                --output ${sample}.coverage.tsv

    """
}