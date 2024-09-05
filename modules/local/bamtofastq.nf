/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    BAMTOFASTQ: SAMTOOLS
    Convert BamtoFastq using samtools
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process BAMTOFASTQ {
    conda "${projectDir}/envs/samtools.yml"
    label "Bamtofastq"

    input:
        path(bamfile)
        
    output:
        path("*.fastq.gz"),                 emit: demultiplexed_fastq

    
    script:
    """
    bam_file_name=\$(basename ${bamfile} .bam)

    samtools fastq \
                -T "*" \
                --threads ${task.cpus} \
                ${bamfile} | gzip \
                > \$bam_file_name.fastq.gz

    """
}