#!/usr/bin/env bash

#SBATCH --cpus-per-task=8 \
#SBATCH --mem-per-cpu=50G \
#SBATCH --time=01:00:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=preHiseq \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/logs/outputs/out_%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/logs/errors/er_%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch


CONTAINER="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
INPUT_DIR="/data/users/iambrogetti/RNA-seq/data/ref_genome/"
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/data/ref_genome/Mus_musculus.GRCm39"


echo "Starting unzipping .fa and .gtf"

#gunzip -k "${INPUT_DIR}Mus_musculus.GRCm39.115.gtf.gz"
#gunzip -k "${INPUT_DIR}Mus_musculus.GRCm39.dna_sm.primary_assembly.fa.gz"

echo "Starting reference genome indexing"

apptainer exec $CONTAINER hisat2-build \
    -f "${INPUT_DIR}Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" \
    $OUTPUT_DIR \
    -p $SLURM_CPUS_PER_TASK

echo "indexing concluded"