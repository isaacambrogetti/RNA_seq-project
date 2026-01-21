# Detect differentially expressed genes from bulk RNA-seq data

This workflow starts from Illumina sequencing data (fastq files). The goal is to check which genes are differentially
expressed between three experimental groups to understand how the DKO affect the cells pathways under toxoplasmosis, and identify gene ontology (GO) terms enriched for DE genes.

The dataset includes 3-5 replicates from lungs tissues of mice with two different genetic backgrounds (wildtype
and interferon alpha/gamma receptor double knockout). These mice were either infected with toxoplasma or are uninfected
controls.

The fastq files are here: `/data/courses/rnaseq_course/toxoplasma_de`, where you also find a README file with sample information on which group they belong to. The samples are a subset from `Singhania et al. 2019` and the fastq files were downloaded through the Gene Expression Omnibus (GEO), accession GSE119855. 
The library preparation protocol was strand-specific and the libraries were sequenced on an Illumina HiSeq 4000 in paired-end mode.


To help reproducibility for the part on IBU cluster containers have been used to run the programs most of the time, and for the R part the environment have been saved and loaded on GitHub using renv.
From step 4 on, **all the scripts are findable in R-steps/DEscripts.Rmd and can be run with R** (non fundamental code in DEanalysis_support.Rmd), the others were run in the IBU cluster in the repository /data/users/iambrogetti/RNA-seq.

- used `symlink_reads.sh` to create links to the read files not to physically copy them to my repository
- cp /data/courses/rnaseq_course/toxoplasma_de/reads_Lung/* /data/users/iambrogetti/RNA-seq/data/reads_Lung/

For interactive sessions:

+ ```srun --pty -t 00:30:00 --partition=pshort_el8 -n 1 -c 1 --mem=2G bash```

## How the signaling works (simplified)
1. A cell produces interferon cytokines (IFN-α/β or IFN-γ)
2. Interferons bind to their specific receptors:
3. Type I IFNs → IFNAR
4. Type II IFN → IFNGR
5. This activates the JAK–STAT signaling pathway
6. STAT transcription factors enter the nucleus
7. ISGs (like Oas1a, Ifit1, Gbp5, Irf1) are transcribed

## 1. Quality checks

1. `FastQC` to assess the quality of the data
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

2. `multiQC` to get the summary report
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

3. For each paired sample, separately map the reads to the reference genome using Hisat2. The correct strandedness setting for this library prep protocol is RF.
    - `mapping_par.slurm` core code
    - `map_run.sh` cycle over mapping_par for each sample
    - _output_
        - SAM files (human readable file that contains all the alignment information)
        - summary file containing the mapping statistics

4. To process the SAM files and obtain sorted and indexed BAM via (`post_mapping.slurm` and `view_loop.sh`).
    - `samtools view` convert sam to bam
    - `samtools sort` sort bam
    - `samtools index` index the sorted bam
    - _output_
        - .bam
        - _sorted.bam
        - _sorted.bai (sorted bam index)
    
Bonus: Use the Integrative Genomics Viewer to inspect some of your bam files. It is easiest if you download the bam
files to your local machine for this step. To reduce file size, you could use samtools view to extract a smaller genomic
region. 

_Documentation_
- Hisat2
    - https://daehwankimlab.github.io/hisat2/manual/
    - https://github.com/DaehwanKimLab/hisat2
- samtools
    - https://www.htslib.org/doc/samtools.html


## 3. Count the number of reads per gene

The script `reads_per_gene.sh` Use all of your bam files as input for featureCounts to produce a table of counts containing the number of reads per gene in each sample.

- `featureCounts`
    - Takes in input the GTF file and the list of the sorted BAM files to produce a table containing Genes ~ Samples.
        | Options | Function |
        | ------- | ------- |
        | -p | treat reads as paired-end |
        | -B | require both ends mapped to count a fragment |
        | -C | exclude chimeric fragments |
        | -s 2 | strandedness = 2 (reverse strand / RF library) |
    - _output_
        - `.txt` count file with header/comment lines and then a table (genes × samples)
        - `.summary` with per-sample assignment counts

- `sed`
    - Replaces any path ending with `.../SRRNNNNNN_sorted.bam` in header columns with just `SRRNNNNNN` (keeps only the SRR identifier). 
    - _output_
        - `.txt` inplace modification of the input count file

- `multiqc`
    - obtain the multiqc report for the `.summary` file

_Documentation_
- featureCounts
    - https://subread.sourceforge.net/featureCounts.html
    - https://rnnh.github.io/bioinfo-notebook/docs/featureCounts.html


## 4. Exploratory data analysis
Do DESeq2 and get a general overview of the data composition with PCAs after normalizing the variation.


## 5. Differential expression analysis
Choose comparisons to answer the research question (WT contr v cases, DKO contr v cases, WT cases v DKO cases)

In order to do so extract the pairwise comparison results using `DESeq::results()` analyse them and plot them with heatmap or volcano plot.

Checking adjusted p-value and logFC allows us to find the most relevant DE genes and understand how much they are under/over-expressed. The plots helps us visualize them:

- Heatmap (chosen for the report)
- Volcano (plots version present in the DEanalysis_support.Rmd - not used in the report)

Get the genes of interest and plot the boxplots for VST and test statistics for comparisons of interest.

## 6. Overexpression analysis
Using GO, find what are the enriched BP for the DE genes to have an overview of what is going on inside the cells under different conditions.
