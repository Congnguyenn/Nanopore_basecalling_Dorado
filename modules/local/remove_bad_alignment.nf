/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    REMOVE_BAD_ALIGNMENT: SAMTOOLS
    Performing basecalling using Dorado
    Ref: https://github.com/nanoporetech/dorado/tree/release-v0.5.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process REMOVE_BAD_ALIGNMENT {
    container "https://depot.galaxyproject.org/singularity/samtools%3A1.19.2--h50ea8bc_0"
    label "Remove_bad_alignment"
    debug true

    input:
        path(aligned_bam)
        val(min_map_score)

    output:
        tuple   env(filename),
                path("*_sorted_high_map_quality.bam"),
                path("*_sorted_high_map_quality.bam.bai"),                 emit: sorted_high_map_quality
    
    script:
    """
        # Extracted file name
        filename=\$(basename ${aligned_bam} .bam)

        samtools view \
                -q ${min_map_score} \
                -@ ${task.cpus} \
                -bh -o \$filename"_high_map_quality.bam" ${aligned_bam}
                
        samtools sort \
                \$filename"_high_map_quality.bam" \
                -@ ${task.cpus} \
                -o \$filename"_sorted_high_map_quality.bam"
        
        samtools index \
                -@ ${task.cpus} \
                \$filename"_sorted_high_map_quality.bam"
    """
}
