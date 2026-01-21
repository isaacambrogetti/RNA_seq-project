#!/usr/bin/env bash

#SBATCH --cpus-per-task=8 \
#SBATCH --mem-per-cpu=50G \
#SBATCH --time=01:00:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=postHiseq \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/logs/outputs/%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/logs/errors/%x_%j.e \
#SBATCH --mail-type=end,error \
#SBATCH --mail-user=isaac.ambrogetti@unifr.ch

# set container directory, input file as input 1, sample name as basename input 1 .sam and output file as input 2 sample name .bam
CONTAINER="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
INPUT_FILE=${1}
sample_name=$(basename ${INPUT_FILE%.sam})
OUTPUT_FILE="${2}/${sample_name}.bam"

# debug and check for progress
echo -e "$INPUT_FILE \n$OUTPUT_FILE \n ${OUTPUT_FILE%.bam}_sorted.bam \n ${OUTPUT_FILE%.bam}_sorted.bai\n\n"

# command to run samtools view receiving in input the sam and outputting the bam
apptainer exec $CONTAINER samtools view \
    -bo $OUTPUT_FILE \
    $INPUT_FILE

echo "sam file converted to bam"

# command to sort the bam file, setting a temporary directory
apptainer exec $CONTAINER samtools sort \
    -T /data/users/iambrogetti/RNA-seq/.tmp \
    $OUTPUT_FILE \
    -o ${OUTPUT_FILE%.bam}_sorted.bam

echo "bam sorted"

# command to index the sorted bam file, giving as output the sorted and indexed bam
apptainer exec $CONTAINER samtools index -b \
    -o ${OUTPUT_FILE%.bam}_sorted.bai \
    ${OUTPUT_FILE%.bam}_sorted.bam

echo "bam indexed\nJOB COMPLETED"
