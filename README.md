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

+ ```srun --pty -t 00:30:00 --partition=pshort_el8 -n 1 -c 1 --mem=2G bash```



## 1. Quality checks

- `FastQC` to assess the quality of the data
    - created `QC_lung.sh` for the quality control script
    - run `QC_lung.sh` via `for_QC.sh` to iterate through all the samples
    - _output_ 
        - fastqc.html for each file 
        - fastqc.zip that contains the information
            ```
            fastqc.zip/
            ├── fastqc_data.txt     # raw metrics for every FastQC module
            ├── summary.txt         # A line-by-line quick summary of pass / warn / fail status for each module
            ├── Icons/
            ├── Images/
            └── ...
            ``` 

- `multiQC` to get the summary report
    - crated  and run `multiQC.sh` to create a summary report of all the files created in the step before.
    - _output_
        - folder multiqc_data stores all the raw data it used to build the final report
        - multiqc_report.html


No need to trim the reads, they're good quality. I just noticed an increment of GC content for a sample: SSR7821938 _1 and _2.

_Documentation_
- FastQC
    - https://mugenomicscore.missouri.edu/PDF/FastQC_Manual.pdf
    - https://home.cc.umanitoba.ca/~psgendb/doc/fastqc.help
- multiQC
    - https://docs.seqera.io/multiqc

## 2. Map reads to the reference genome

1. Download the latest reference genome sequence and associated annotation for your species from the Ensembl ftp site.
    - wget https://ftp.ensembl.org/pub/release-115/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa.gz    # sequence
    - wget https://ftp.ensembl.org/pub/release-115/gtf/mus_musculus/Mus_musculus.GRCm39.115.gtf.gz     # annotation

    - `sum <file>` to verify the files are intact

2. Unzips the files downloaded and creates all required index files for Hisat2 from the .fa file
    - `ref_indexing.sh`
    - _output_
        - 8 .ht2 files containing different things

        | File | Contains | Purpose |
        | ------- | ------- | ------- |
        | **1–4** | Main FM-index of the genome | Core alignment operations |
        | **5–6** | Additional lookup tables | Faster searching |
        | **7–8** (if present) | Extensions for large genomes | Memory optimization |

++++++++++++++++++++++++++++++++++++

3. For each sample separately, map the reads to the reference genome using Hisat2. The correct strandedness setting for this library prep protocol is RF.
    - `mapping_par.slurm` core code
    - `map_run.sh` cycle over mapping_par
4. Samtools (`post_mapping.slurm` and `view_loop.sh`)
    - `samtools view` convert sam to bam
    - `samtools sort` sort bam
    - `samtools index` index the sorted bam

    
Bonus: Use the Integrative Genomics Viewer to inspect some of your bam files. It is easiest if you download the bam
files to your local machine for this step. To reduce file size, you could use samtools view to extract a smaller genomic
region. 

_Documentation_
- Hisat2
    - https://daehwankimlab.github.io/hisat2/manual/
    - https://github.com/DaehwanKimLab/hisat2
- 


## 3. Count the number of reads per gene

Summarize multiple paired-end datasets - use `featureCounts` then a `sed` command to clear the name of the columns to just the SRC name. And finally used `multiqc` to get the visualization of the summary feature counts.

_Documentation_
- featureCounts
    - https://subread.sourceforge.net/featureCounts.html
    - https://rnnh.github.io/bioinfo-notebook/docs/featureCounts.html


## 4. 
do heat map and other stuff





?? what file did i need to unzip? The reference genome?, for sure not the fastq files of the samples



Goal:
find level of expression and differentially expressed genes

step 4
do heat map

which are the genes that change with the condition -> fantasize but have a narrative

Fold Chagne (FC) is the ratio between the mean of the observations per condition, in the DESeq2 we get the logFC because it centers the values around 0:
when larger than 0 the expession is higher in one condition than the other (FC), usually control is denominator so you compare everything to the 0 which is control

e.g., logFC = -12 allora the condition expresses that gene much less than the control.


p-adjusted
every time we have a gene we're making a statistical test, in DEseq we're making thousands of test on the same value which means that by chance it is possible to have 



Vulcano plot
