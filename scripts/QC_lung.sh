#!/usr/bin/env bash

#SBATCH --cpus-per-task=4 \
#SBATCH --mem-per-cpu=1G \
#SBATCH --time=02:00:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=QC-lungs \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/outputs/output_%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/errors/error_%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch \

# load modules for fastqc
module load FastQC/0.11.9-Java-11

# set input and output directories
INPUT_DIR="/data/users/iambrogetti/RNA-seq/reads_Lung"
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/qc_output"

# run fastqc on the sample in input
fastqc "${1}" -o "$OUTPUT_DIR" -t $SLURM_CPUS_PER_TASK

# debugging and progress report check
echo "FastQC for ${1} completed"
