/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    QUALITY CONTROL NANOPORE SEQUENCING BATCH: PYCOQC
    Quality assessment of a batch of Nanopore sequencing data
    Ref: https://github.com/a-slide/pycoQC/tree/master
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process PYCOQC {
    tag "${batchID}"
    container "https://depot.galaxyproject.org/singularity/pycoqc%3A2.5.2--py_0"
    label "Pycoqc"
    debug true

    input:
        tuple   val(batchID),
                path(sequencing_summary)

    output:
        tuple   val(batchID),
                path("${batchID}_sequencing_summary.html")
    
    script:
    """
    pycoQC \
            --summary_file ${sequencing_summary} \
            --report_title ${batchID}_sequencing_summary \
            --html_outfile ${batchID}_sequencing_summary.html
    """
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MODKIT MANUAL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// Modkit is a bioinformatics tool for working with modified bases from
// Oxford Nanopore

// Usage: modkit <COMMAND>

// Commands:
//   pileup        Tabulates base modification calls across genomic
//                     positions. This command produces a bedMethyl
//                     formatted file. Schema and description of fields
//                     can be found in the README
//   adjust-mods   Performs various operations on BAM files containing
//                     base modification information, such as converting
//                     base modification codes and ignoring modification
//                     calls. Produces a BAM output file
//   update-tags   Renames Mm/Ml to tags to MM/ML. Also allows
//                     changing the the mode flag from silent '.' to
//                     explicitly '?' or '.'
//   sample-probs  Calculate an estimate of the base modification
//                     probability distribution
//   summary       Summarize the mod tags present in a BAM and get
//                     basic statistics. The default output is a totals
//                     table (designated by '#' lines) and a modification
//                     calls table. Descriptions of the columns can be
//                     found in the README
//   call-mods     Call mods from a modbam, creates a new modbam with
//                     probabilities set to 100% if a base modification is
//                     called or 0% if called canonical
//   motif-bed     Create BED file with all locations of a sequence
//                     motif. Example: modkit motif-bed CG 0
//   extract       Extract read-level base modification information
//                     from a modBAM into a tab-separated values table
//   repair        Repair MM and ML tags in one bam with the correct
//                     tags from another. To use this command, both
//                     modBAMs _must_ be sorted by read name. The "donor"
//                     modBAM's reads must be a superset of the acceptor's
//                     reads. Extra reads in the donor are allowed, and
//                     multiple reads with the same name (secondary, etc.)
//                     are allowed in the acceptor. Reads with an empty
//                     SEQ field cannot be repaired and will be rejected.
//                     Reads where there is an ambiguous alignment of the
//                     acceptor to the donor will be rejected (and
//                     logged). See the full documentation for details
//   dmr           Perform DMR test on a set of regions. Output a BED
//                     file of regions with the score column indicating
//                     the magnitude of the difference. Find the schema
//                     and description of fields can in the README as well
//                     as a description of the model and method. See
//                     subcommand help for additional details
//   pileup-hemi   Tabulates double-stranded base modification patters
//                     (such as hemi-methylation) across genomic motif
//                     positions. This command produces a bedMethyl file,
//                     the schema can be found in the online documentation
//   validate      Validate results from a set of mod-BAM files and
//                     associated BED files containing the ground truth
//                     modified base status at reference positions
//   help          Print this message or the help of the given
//                     subcommand(s)

// Options:
//   -h, --help     Print help
//   -V, --version  Print version