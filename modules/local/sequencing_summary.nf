/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SEQUENCING_SUMMARY: DORADO
    Performing basecalling using Dorado
    Ref: https://github.com/nanoporetech/dorado/tree/release-v0.5.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    process SEQUENCING_SUMMARY {
    tag "${batchID}"
    label "Sequencing_summary"
    debug true

    input:
        tuple   val(batchID),
                path(aligned_bam)

    output:
        tuple   val(batchID),
                path("${batchID}_summary.tsv"),                 emit: sequencing_summary
    
    script:
    """
    export dorado="/home/congnguyen/dorado-0.5.3-linux-x64/bin/dorado"
    
    \$dorado summary \
                -v ${aligned_bam} > ${batchID}_summary.tsv
    """
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 DORADO MANUAL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Usage: dorado [-h] [--device VAR] [--read-ids VAR] [--resume-from VAR] [--max-reads VAR] [--min-qscore VAR] [--batchsize VAR] [--chunksize VAR] [--overlap VAR] [--recursive] [--modified-bases VAR...] [--modified-bases-models VAR] [--modified-bases-threshold VAR] [--emit-fastq] [--emit-sam] [--emit-moves] [--reference VAR] [--kit-name VAR] [--barcode-both-ends] [--no-trim] [--trim VAR] [--sample-sheet VAR] [--barcode-arrangement VAR] [--barcode-sequences VAR] [--estimate-poly-a] [-k VAR] [-w VAR] [-I VAR] [--secondary VAR] [-N VAR] [-Y] [--bandwidth VAR] model data

// Positional arguments:
//   model                         model selection {fast,hac,sup}@v{version} for automatic model selection including modbases, or path to existing model directory 
//   data                          the data directory or file (POD5/FAST5 format). 

// Optional arguments:
//   -h, --help                    shows help message and exits 
//   -v, --verbose             
//   -x, --device                  device string in format "cuda:0,...,N", "cuda:all", "metal", "cpu" etc.. [default: "cuda:all"]
//   -l, --read-ids                A file with a newline-delimited list of reads to basecall. If not provided, all reads will be basecalled [default: ""]
//   --resume-from                 Resume basecalling from the given HTS file. Fully written read records are not processed again. [default: ""]
//   -n, --max-reads               [default: 0]
//   --min-qscore                  Discard reads with mean Q-score below this threshold. [default: 0]
//   -b, --batchsize               if 0 an optimal batchsize will be selected. batchsizes are rounded to the closest multiple of 64. [default: 0]
//   -c, --chunksize               [default: 10000]
//   -o, --overlap                 [default: 500]
//   -r, --recursive               Recursively scan through directories to load FAST5 and POD5 files 
//   --modified-bases              [nargs: 1 or more] 
//   --modified-bases-models       a comma separated list of modified base models [default: ""]
//   --modified-bases-threshold    the minimum predicted methylation probability for a modified base to be emitted in an all-context model, [0, 1] [default: 0.05]
//   --emit-fastq                  Output in fastq format. 
//   --emit-sam                    Output in SAM format. 
//   --emit-moves              
//   --reference                   Path to reference for alignment. [default: ""]
//   --kit-name                    Enable barcoding with the provided kit name. Choose from: EXP-NBD103 EXP-NBD104 EXP-NBD114 EXP-NBD196 EXP-PBC001 EXP-PBC096 SQK-16S024 SQK-16S114-24 SQK-LWB001 SQK-MLK111-96-XL SQK-MLK114-96-XL SQK-NBD111-24 SQK-NBD111-96 SQK-NBD114-24 SQK-NBD114-96 SQK-PBK004 SQK-PCB109 SQK-PCB110 SQK-PCB111-24 SQK-PCB114-24 SQK-RAB201 SQK-RAB204 SQK-RBK001 SQK-RBK004 SQK-RBK110-96 SQK-RBK111-24 SQK-RBK111-96 SQK-RBK114-24 SQK-RBK114-96 SQK-RLB001 SQK-RPB004 SQK-RPB114-24 VSK-PTC001 VSK-VMK001 VSK-VMK004 VSK-VPS001. 
//   --barcode-both-ends           Require both ends of a read to be barcoded for a double ended barcode. 
//   --no-trim                     Skip trimming of barcodes, adapters, and primers. If option is not chosen, trimming of all three is enabled. 
//   --trim                        Specify what to trim. Options are 'none', 'all', 'adapters', and 'primers'. Default behavior is to trim all detected adapters, primers, or barcodes. Choose 'adapters' to just trim adapters. The 'primers' choice will trim adapters and primers, but not barcodes. The 'none' choice is equivelent to using --no-trim. Note that this only applies to DNA. RNA adapters are always trimmed. [default: ""]
//   --sample-sheet                Path to the sample sheet to use. [default: ""]
//   --barcode-arrangement         Path to file with custom barcode arrangement. [default: <not representable>]
//   --barcode-sequences           Path to file with custom barcode sequences. [default: <not representable>]
//   --estimate-poly-a             Estimate poly-A/T tail lengths (beta feature). Primarily meant for cDNA and dRNA use cases. Note that if this flag is set, then adapter/primer detection will be disabled. 
//   -k                            minimap2 k-mer size for alignment (maximum 28). [default: 15]
//   -w                            minimap2 minimizer window size for alignment. [default: 10]
//   -I                            minimap2 index batch size. [default: "16G"]
//   --secondary                   minimap2 outputs secondary alignments [default: "yes"]
//   -N                            minimap2 retains at most INT secondary alignments [default: 5]
//   -Y                            minimap2 uses soft clipping for supplementary alignments 
//   --bandwidth                   minimap2 chaining/alignment bandwidth and optionally long-join bandwidth specified as NUM,[NUM] [default: "500,20K"]



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // $dorado basecaller \
    //                     --emit-moves \
    //                     --recursive \
    //                     --reference ${INPUT_DIR}/GRCh38.fa \
    //                     ${INPUT_DIR}/dorado-0.5.3-linux-x64/models/dna_r10.4.1_e8.2_400bps_hac@v4.3.0  \
    //                     ${INPUT_DIR}/nanopore_raw_data > ${OUTPUT_DIR}/aligned.bam

    // \$dorado basecaller \
    //     --verbose \
    //     --min-qscore 7 \
    //     --recursive \
    //     --emit-fastq \
    //     --emit-moves \
    //     --no-trim \
    //     --modified-bases \
    //     --modified-bases-models 
    //     /mnt/DATAR09/DATA_CONGNGUYEN/pipeline/nf-core-doradobasecalling/models/dna_r10.4.1_e8.2_400bps_hac@v4.3.0 ${pod5} > calls.bam

