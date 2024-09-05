#!/usr/bin/env Rscript

#Add argument parser
library(optparse)
library(ggplot2)

#Exclude the warning
options(warn=-1)

# #1.INPUT DECLARATION
# # Define the option

option_list <- list(
    make_option("--Flen_path",
                        dest="Flen_path",
                        type="character",
                        help="Path Fragment Length file"),
    make_option("--Outdir",
                        dest="Outdir",
                        type="character",
                        help="Output directory")
)

# Parse the command-line arguments
opt_parser = OptionParser(option_list=option_list)
opt        = parse_args(opt_parser)

# Import abundance table and metadata
Flen_path=opt$Flen_path
Outdir=opt$Outdir

df = read.table(Flen_path, header = F,check.names = F)

#Get the filename: taking the basename and remove ".Flen.txt"
filename = gsub(".Flen.txt","",basename(Flen_path))

#Naming the columns
colnames(df) = c("ReadID","CIGAR","FragLen")

Flen = ggplot(df, aes(x=FragLen)) + 
                geom_line(stat="bin", binwidth=1) + 
                theme_minimal() + 
                labs(title=paste0("Read Length Distribution: ",filename), x="Read Length", y="Number of Reads") + 
                theme(plot.title = element_text(hjust = 0.5))


Flen_log = ggplot(df, aes(x=FragLen)) + 
                geom_line(stat="bin", binwidth=1) + 
                theme_minimal() + 
                labs(title=paste0("Read Length Distribution (LogScale): ",filename), x="Read Length", y="Number of Reads: Log-scale") + 
                theme(plot.title = element_text(hjust = 0.5)) +
                scale_y_log10()

#Save the plot
ggsave(paste0(Outdir,"/",filename,"_Flen.png"), plot=Flen, width=8, height=5)
ggsave(paste0(Outdir,"/",filename,"_Flen_log.png"), plot=Flen_log, width=8, height=5)