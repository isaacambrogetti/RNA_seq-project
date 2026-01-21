#!/usr/bin/env bash

#SBATCH --cpus-per-task=1 \
#SBATCH --mem-per-cpu=10K \
#SBATCH --time=00:05:00 \
#SBATCH --partition=pibu_el8

# set input output directories and position of the script to run for fastqc
OUTPUT_DIR="/data/users/iambrogetti/RNA-seq/qc_output"
INPUT_DIR="/data/users/iambrogetti/RNA-seq/reads_Lung"
SCRIPT_DIR="/data/users/iambrogetti/RNA-seq/scripts/QC_lung.sh"

# creates a file test.txt to store the output of the every for call (can be done with log too and it would look cleaner)
touch /data/users/iambrogetti/RNA-seq/scripts/test.txt
echo "starting loop..." > /data/users/iambrogetti/RNA-seq/scripts/test.txt
mkdir $OUTPUT_DIR

# for each file found with the suffix .gz, run the sbatch command of the script for qc
for file in $INPUT_DIR/*.gz; do
    sbatch $SCRIPT_DIR $file
    echo "$file is running qc" >> /data/users/iambrogetti/RNA-seq/scripts/test.txt
done
