/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    QC_LONG_READS: FILTLONG
    Trim the given fastq. Defaulted conditions as follow: 1400<read_length<1700; 8<quality
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process FILTLONG {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/filtlong:0.2.1--hdcf5f25_2' :
        'quay.io/biocontainers/filtlong:0.2.1--hdcf5f25_2' }"
    label "Filtlong"

    input:
        path(fastq)
        
    output:
        tuple   env(filename),
                path("*-passed.fastq.gz")                              , emit: trimmed_fastq
    
    script:
    """
    # Extracted file name
    filename=\$(basename ${fastq} .fastq.gz)    

    export LC_ALL=C; unset LANGUAGE
    filtlong ${fastq} --min_length ${params.min_length} \
    --min_mean_q ${params.min_qscore} > \$filename"-passed.fastq"

    gzip \$filename"-passed.fastq"
    """
}