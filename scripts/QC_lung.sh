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

module load FastQC/0.11.9-Java-11 
module load fastp/0.23.4-GCC-10.3.0

INPUT_DIR="/data/users/iambrogetti/RNA-seq/reads_Lung"
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/qc_output"

fastqc "${1}" -o "$OUTPUT_DIR" -t $SLURM_CPUS_PER_TASK

echo "FastQC for SRR7821918_1.fastq.gz completed"



