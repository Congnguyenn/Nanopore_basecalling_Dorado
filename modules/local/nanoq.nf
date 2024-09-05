/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    QC_LONG_READS: NANOQ
    Get the statistics information of input fastq
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process NANOQ {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoq:0.10.0--h031d066_1' :
        'quay.io/biocontainers/nanoq:0.10.0--h031d066_1' }"
    label "NanoQ"
    label "error_ignore"

    input:
        path(fastq)

    output:
        path "*_report_nanoq.tsv"
        path fastq 

    script:
    """
    # Extracted file name
    filename=\$(basename ${fastq} .fastq.gz)
    
    echo \$filename

    nanoq --stats -vvv \
          --report \$filename"_report_nanoq.tsv" \
          --input ${fastq}
    """
}