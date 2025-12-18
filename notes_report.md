qc

- quality of the reads
- duplication of the reads
- Overrepresented sequences (seq that might have a lot of adapters left in it, or rRNA or contaminant (easy to trim out))
- GC content (most of the species peak around 50, but as long as you don't see crazy peaks coming out it's ok) (not sufficient to discard read if it does not impact the analysis downstream)

why is it impotant to know how many reads we sequenced?
- make sure there are not crazy different number of reads between samples 
- check the proportion of align reads over overall reads


MAPPING STEP

check on IGV:
exons
check strandness of the reads

we're still missing a score of the expression of the gene, we just have info on if a read matches and where.



Find uniquely concordantly mapped -> 
e.g., 97% overall alignment rate /data/users/iambrogetti/RNA-seq/data/sam/SRR7821918_summary.txt


## Step 4
take gtf file (directions of the exons on the genome)
use it to understand how many reads align to each gene


p-adjusted is needed since for each gene we're making a statistical test, in DEseq we're making thousands of test 
on the same value by comparing it with the others which means that by chance it is possible to have a 
significant value by chance. So the adjustment takes in consideration the sample size.



## Step 8

Overrepresentation analysis has many different names they all refer to the same thing:
- Enrichment Analysis
- Gene Enrichment Analysis
- Functional Enrichment Analysis
- Pathway Enrichment Analysis (depending on context)
- Gene Set Enrichment
- Hypergeometric Test Analysis
- Fisher’s Exact Test Enrichment
- GO Term Enrichment
- Pathway Overrepresentation Test

### Hypergeometric test

The hypergeometric test tells you whether the number of DE genes belonging to a specific pathway/GO term is 
greater than expected by random chance, based on simple combinatorics.

Suppose:
Total genes measured: N = 20,000
Genes in a GO term: K = 150
Your DE genes: n = 400
DE genes in that GO term: k = 20
You test:
Are 20 DE genes in this pathway more than expected by chance?
