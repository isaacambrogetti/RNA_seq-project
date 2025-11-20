#!/usr/bin/env bash

#SBATCH --cpus-per-task=1 \
#SBATCH --mem-per-cpu=5G \
#SBATCH --time=00:10:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=multiQC \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/outputs/out_%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/errors/er_%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch



CONTAINER="/containers/apptainer/multiqc-1.19.sif"
INPUT_DIR="/data/users/iambrogetti/RNA-seq/data/qc_output"
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/data/qc_output"

apptainer exec ${CONTAINER} multiqc ${INPUT_DIR}/*fastqc.zip -o ${OUTPUT_DIR}
