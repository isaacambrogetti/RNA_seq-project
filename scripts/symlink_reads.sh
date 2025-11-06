#!/bin/sh

#SBATCH --cpus-per-task=1 \
#SBATCH --mem-per-cpu=10K \
#SBATCH --time=00:05:00 \
#SBATCH --partition=pibu_el8 \
#SBATCH --job-name=symlinkReads \
#SBATCH --output=/data/users/iambrogetti/RNA-seq/outputs/output_%x_%j.o \
#SBATCH --error=/data/users/iambrogetti/RNA-seq/errors/error_%x_%j.e

SRC=/data/courses/rnaseq_course/toxoplasma_de/reads_Lung
DST=/data/users/iambrogetti/RNA-seq/reads_Lung

mkdir -p "$DST"
cd "$SRC" || exit 1

# create matching directories in destination
find . -type d -print0 | xargs -0 -I{} mkdir -p "$DST/{}"

# create symlinks for files
find . -type f -print0 | xargs -0 -I{} ln -s "$SRC/{}" "$DST/{}"