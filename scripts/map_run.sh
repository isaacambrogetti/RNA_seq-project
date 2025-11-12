#!/usr/bin/env bash

#SBATCH --cpus-per-task=1 \
#SBATCH --mem-per-cpu=10MB \
#SBATCH --time=00:05:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=map_run \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/logs/outputs/%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/logs/errors/%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch

FILE_PATH="/data/users/iambrogetti/RNA-seq/scripts/mapping_par.slurm"

for file in /data/users/iambrogetti/RNA-seq/data/reads_Lung/*_1.fastq.gz; do
    file_2=${file%_1.fastq.gz}_2.fastq.gz
    sample_name=$(basename ${file%_1.fastq.gz})
    sbatch  $FILE_PATH $file $file_2 $sample_name
done