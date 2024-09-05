/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOSDEPTH
    QC The BAM files using mosdepth
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process MOSDEPTH {
    conda "${projectDir}/envs/mosdepth.yml"
    label "Mosdepth"
    tag "$sample"

    input:
        tuple   val(sample),
                path(sorted_bam),
                path(sorted_bai),
                val(bedtype),
                path(bedfile)

    output:
        tuple   val(sample),
                val(bedtype),
                path("*.regions.bed")                        , emit: mosdepth

    script:
    """
    mosdepth \
        --by ${bedfile} \
        ${sample}.${bedtype} \
        ${sorted_bam} \
        --threads ${task.cpus}

    gunzip *.gz
    """
}