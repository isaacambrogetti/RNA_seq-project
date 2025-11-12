#!/usr/bin/env bash

#SBATCH --cpus-per-task=8 \
#SBATCH --mem-per-cpu=10G \
#SBATCH --time=01:00:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=mapping \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/logs/outputs/%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/logs/errors/%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch


CONTAINER="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
REF_DIR="/data/users/iambrogetti/RNA-seq/data/ref_genome/"
READS_FILE_1=${1}
READS_FILE_2=${2}
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/data/sam/${3}.sam"


echo -e "${READS_FILE_1}\n${READS_FILE_2}\n${OUTPUT_DIR}\n\n"

apptainer exec $CONTAINER hisat2 \
    -x "${REF_DIR}Mus_musculus.GRCm39" \
    -1 $READS_FILE_1 -2 $READS_FILE_2 -S $OUTPUT_DIR \
    --rna-strandness RF \
    --summary-file /data/users/iambrogetti/RNA-seq/data/sam/${3}_summary.txt \
    -p $SLURM_CPUS_PER_TASK