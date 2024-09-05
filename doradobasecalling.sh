#!/bin/bash

#SBATCH --nodes=1
#SBATCH --partition=research_hi
#SBATCH --ntasks=1
#SBATCH --job-name=basecalling_dorado
#SBATCH --output=cpp-job.%j.out

export main="/mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/nf-core-doradobasecalling/main.nf"
workdir="/mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/work"

# nextflow run $main  \
#                 --input /mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/nf-core-doradobasecalling/assets/samplesheet_Nanopore_test.csv \
#                 --outdir /mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/nf-core-doradobasecalling/testdata/out_test \
#                 -profile conda,singularity \
#                 -resume \
#                 -w $workdir \
#                 -c /mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/nf-core-doradobasecalling/conf/custom.config


nextflow run $main  \
                --input /mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/nf-core-doradobasecalling/assets/samplesheet_Nanopore08.csv \
                --outdir /mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/NANOPORE_DATA/Basecalling_result/basecalling_result_Nanopore08 \
                -profile conda,singularity \
                -resume \
                -w $workdir \
                -c /mnt/NAS_PROJECT/vol_Phucteam/CONGNGUYEN/pipeline/nf-core-doradobasecalling/conf/custom.config
