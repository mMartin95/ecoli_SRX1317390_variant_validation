# Data included in this directory

| File Name | Format | Description |
| :--- | :--- | :--- |
| `NC_012967.1.fna` | FASTA | *E. coli* REL606 reference genome sequence (NCBI RefSeq). |
| `chr_map.txt` | TSV | Chromosome header translation map (`NC_012967.1` $\rightarrow$ `Chromosome`) for SnpEff database compatibility. |
| `mini_bam/test_mini.bam` | BAM | Subsampled test alignment file containing reads mapped to region `NC_012967.1:1000000-1050000` for rapid pipeline verification and IGV snapshot testing. |
| `mini_bam/test_mini.bam.bai` | BAI | Index file for `test_mini.bam` generated via `samtools index`. |

The raw data of fastq.gz files are EXCLUDED due to size limits on GitHub, but you can download them from the link I included in the README.md ecoli_SRX1317390_variant_validation
