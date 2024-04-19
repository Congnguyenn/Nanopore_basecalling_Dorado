#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=research_hi
#SBATCH --ntasks=1
#SBATCH --job-name=basecalling_dorado
#SBATCH --output=cpp-job.%j.out

export main="/mnt/DATAR09/DATA_CONGNGUYEN/pipeline/nf-core-doradobasecalling/main.nf"
workdir="/mnt/DATAR09/DATA_CONGNGUYEN/pipeline/work"

# nextflow run $main  \
#                 --input /mnt/DATAR09/DATA_CONGNGUYEN/pipeline/nf-core-doradobasecalling/assets/samplesheet_Nanopore01.csv \
#                 --outdir /mnt/DATAR09/DATA_CONGNGUYEN/pipeline/NANOPORE_DATA/Basecalling_result/selected/basecalling_result_Nanopore01 \
#                 -profile conda,singularity \
#                 -resume \
#                 -w $workdir \
#                 -c /mnt/DATAR09/DATA_CONGNGUYEN/pipeline/nf-core-doradobasecalling/conf/custom.config
