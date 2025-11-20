#!/usr/bin/env bash

#SBATCH --cpus-per-task=8 \
#SBATCH --mem-per-cpu=5G \
#SBATCH --time=02:00:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=reads_per_gene \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/logs/outputs/%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/logs/errors/%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch


CONTAINER_feature="/containers/apptainer/subread_2.0.6.sif"
CONTAINER_multiqc="/containers/apptainer/multiqc-1.19.sif"
GENOME_FILES="/data/users/iambrogetti/RNA-seq/data/ref_genome/Mus_musculus.GRCm39.115.gtf"
INPUT_FILES="/data/users/iambrogetti/RNA-seq/data/bam/*_sorted.bam"
OUTPUT_FILE="/data/users/iambrogetti/RNA-seq/data/bam/reads_gene_counts.txt"
TMP="/data/users/iambrogetti/RNA-seq/.tmp"
QC_FILE="/data/users/iambrogetti/RNA-seq/data/bam"

touch $OUTPUT_FILE
chmod 777 $OUTPUT_FILE

apptainer exec $CONTAINER_feature featureCounts \
    -a $GENOME_FILES -o $OUTPUT_FILE \
    -p -B -C -s 2 --tmpDir $TMP \
    -T $SLURM_CPUS_PER_TASK $INPUT_FILES

sed -E -i 's#[^[:space:]]*/(SRR[0-9]+)\_sorted\.bam#\1#g' $OUTPUT_FILE

apptainer exec ${CONTAINER_multiqc} multiqc ${QC_FILE}/*.summary -o ${QC_FILE}