#!/usr/bin/env bash

#SBATCH --cpus-per-task=1 \
#SBATCH --mem-per-cpu=10MB \
#SBATCH --time=00:05:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=view_loop \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/logs/outputs/%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/logs/errors/%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch

# set input and output directories
INPUT_DIR="/data/users/iambrogetti/RNA-seq/data/sam"
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/data/bam"

# for each file with suffix .sam in the input directory run the post_mapping.slurm script 
# with the file as first input and output directory as second
for file in $INPUT_DIR/*.sam; do
    sbatch /data/users/iambrogetti/RNA-seq/scripts/post_mapping.slurm $file $OUTPUT_DIR
done
