/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
    Reference: https://community.nanoporetech.com/extraction_methods/human-blood-cfdna
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

// WorkflowDoradobasecalling.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CHANNELS CREATING
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

basecalling_model   = Channel.fromPath(params.basecalling_model)

modification_model  = Channel.value(params.modification_model)

barcode_kit         = Channel.value(params.barcode_kit)

min_qscore          = Channel.value(params.min_qscore)

min_align_score     = Channel.value(params.min_align_score)

reference           = Channel.fromPath(params.reference)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
bedfiles                   = Channel.fromPath("$projectDir/bedfiles/*.bed", checkIfExists: true).map { file -> [file.baseName, file.toString()] }
max_inves_flen             = Channel.value(params.max_inves_flen)
min_inves_flen             = Channel.value(params.min_length)
 
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { DORADO_BASECALLER             } from "${projectDir}/modules/local/dorado_basecall"

include { DORADO_DEMUX                  } from "${projectDir}/modules/local/dorado_demux"

include { DORADO_DEMUX_2ENDS            } from "${projectDir}/modules/local/dorado_demux_2ends"

include { FRAGMENT_LENGTH               } from "${projectDir}/modules/local/Fragment_Length"

include { BAMTOFASTQ                    } from "${projectDir}/modules/local/bamtofastq"

include { REMOVE_BAD_ALIGNMENT          } from "${projectDir}/modules/local/remove_bad_alignment"

include { MOSDEPTH                      } from "${projectDir}/modules/local/mosdepth"

include { SAMTOOLS_DEPTH                } from "${projectDir}/modules/local/samtools_depth"

include { SEQUENCING_SUMMARY            } from "${projectDir}/modules/local/sequencing_summary"

include { MODKIT                        } from "${projectDir}/modules/local/modkit"

include { PYCOQC                        } from "${projectDir}/modules/local/pycoqc"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INPUT_CHECK                   } from "${projectDir}/subworkflows/local/input_check"

include { QC_LONG_READS                 } from "${projectDir}/subworkflows/local/qc_ont"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow DORADOBASECALLING {

    ch_versions = Channel.empty()

    INPUT_CHECK (
                file(params.input))

        INPUT_CHECK.out.reads.view()

    // Basecalling, Demultiplexing and Alignment: Dorado
    DORADO_BASECALLER (INPUT_CHECK.out.reads,
                                    basecalling_model,
                                    modification_model,
                                    min_qscore,
                                    reference)

    // Demultiplexing: Dorado
    DORADO_DEMUX (DORADO_BASECALLER.out.basecalled_bam,
                                    barcode_kit)

    // Demultiplexing 2ends: Dorado
    DORADO_DEMUX_2ENDS (DORADO_BASECALLER.out.basecalled_bam,
                                    barcode_kit)

    // Render Fragment Length Distribution: Samtools + Rscript
    FRAGMENT_LENGTH (DORADO_DEMUX_2ENDS.out.demultiplexed_2ends_bam
                                    .flatten()
                                    .combine(min_inves_flen)
                                    .combine(max_inves_flen))

    // Convert BamtoFastq using samtools
    BAMTOFASTQ(DORADO_DEMUX.out.demultiplexed_bam.flatten())
    
    // Removing Bad Alignment: samtools
    REMOVE_BAD_ALIGNMENT (DORADO_DEMUX.out.demultiplexed_bam.flatten(),
                                    min_align_score)

    // Investigate the genome-wide coverage and depth of each barcode, using Samtool [depth/coverage]
    SAMTOOLS_DEPTH(REMOVE_BAD_ALIGNMENT.out.sorted_high_map_quality)

    // Investigate the regulatory regions coverage and depth of each barcode, using Mosdepth
    MOSDEPTH(REMOVE_BAD_ALIGNMENT.out.sorted_high_map_quality.combine(bedfiles))

    // Generate Sequencing Summary Table: Dorado
    SEQUENCING_SUMMARY (DORADO_BASECALLER.out.basecalled_bam)

    // Nanopore Sequencing Quality Assessment: PycoQC
    PYCOQC (SEQUENCING_SUMMARY.out.sequencing_summary)

    // QC LONG READS
    QC_LONG_READS(BAMTOFASTQ.out.demultiplexed_fastq.collect())

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.dump_parameters(workflow, params)
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

workflow.onError {
    if (workflow.errorReport.contains("Process requirement exceeds available memory")) {
        println("🛑 Default resources exceed availability 🛑 ")
        println("💡 See here on how to configure pipeline: https://nf-co.re/docs/usage/configuration#tuning-workflow-resources 💡")
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
