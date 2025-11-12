# Detect differentially expressed genes from bulk RNA-seq data

This workflow starts from Illumina sequencing data (fastq files). The goal is to produce lists of genes that are differentially
expressed between two experimental groups, and identify gene ontology (GO) terms enriched for DE genes.

The dataset includes 3-5 replicates from two tissues (blood and lung) of mice with two different genetic backgrounds (wildtype
and interferon alpha/gamma receptor double knockout). These mice were either infected with toxoplasma or are uninfected
controls. I work on wt lungs sample. 

The fastq files are here: `/data/courses/rnaseq_course/toxoplasma_de`, where you also find a README file with more details. The samples are a subset from `Singhania et al. 2019` and the fastq files were downloaded through the Gene Expression Omnibus (GEO), accession GSE119855. 
The library preparation protocol was strand-specific and the libraries were sequenced on an Illumina HiSeq 4000 in paired-end mode.


It is recommended to use containers for the tools that you need to use on the cluster. This also helps with reproducibility and
portability, so that your analysis is not dependent on a specific setup on a system.

- used `symlink_reads.sh` to create links to the read files not to physically copy them to my repository (does not work cause I need the unzipped files(?))
- cp /data/courses/rnaseq_course/toxoplasma_de/reads_Lung/* /data/users/iambrogetti/RNA-seq/data/reads_Lung/

For interactive sessions:
> srun --pty -t 00:30:00 --partition=pshort_el8 -n 1 -c 1 --mem=2G bash



## 1. Quality checks

- `FastQC` to assess the quality of the data
    - created `QC_lung.sh` for the quality control script
    - run `QC_lung.sh` via `for_QC.sh` to iterate through all the samples
    
- `multiQC` to get the summary report

No need to trim the reads, they're good quality. I just noticed an increment of GC content for a sample: SSR7821938 _1 and _2.

## 2. Map reads to the reference genome

- Download the latest reference genome sequence and associated annotation for your species from the Ensembl ftp site.
    - wget https://ftp.ensembl.org/pub/release-115/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa.gz    # sequence
    - wget https://ftp.ensembl.org/pub/release-115/gtf/mus_musculus/Mus_musculus.GRCm39.115.gtf.gz     # annotation

    - `sum <file>` to verify the files are intact

- Produce all required index files for Hisat2
    - `ref_indexing.sh`

- For each sample separately, map the reads to the reference genome using Hisat2. The correct strandedness setting for this library prep protocol is RF.
    - `mapping_par.slurm` core code
    - `map_run.sh` cycle over mapping_par
- `samtools view` convert sam to bam
- `samtools sort` sort bam
- `samtools index` index the sorted bam

Bonus: Use the Integrative Genomics Viewer to inspect some of your bam files. It is easiest if you download the bam
files to your local machine for this step. To reduce file size, you could use samtools view to extract a smaller genomic
region. 


