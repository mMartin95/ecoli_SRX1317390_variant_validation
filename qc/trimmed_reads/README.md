# Quality check of trimmed reads
This directory contains quality control reports for the paired-end *E. coli* REL606 reads (SRR2584863) after adapter removal and low-quality base trimming.

Reads were processed using `fastp`

The qualisty was checked using FastQC

This depository includes:
* fastqc.html reports for both reads
* multiqc_report.html – Aggregated MultiQC report for both trimmed paired reads.
* fastp.html / fastp.json – Detailed execution log and filtering metrics from fastp.

Opening interactive files:
* Reads_1_trimmed FastQC report: https://htmlpreview.github.io/?https://htmlpreview.github.io/?https://github.com/mMartin95/ecoli_SRX1317390_variant_validation/blob/main/qc/trimmed_reads/SRR2584863_1_trimmed_fastqc.html
* Reads_2_trimmed FastQC report: https://htmlpreview.github.io/?https://htmlpreview.github.io/?https://github.com/mMartin95/ecoli_SRX1317390_variant_validation/blob/main/qc/trimmed_reads/SRR2584863_2_trimmed_fastqc.html
* MultiQC report for obth reads: https://htmlpreview.github.io/?https://htmlpreview.github.io/?https://github.com/mMartin95/ecoli_SRX1317390_variant_validation/blob/main/qc/trimmed_reads/trimmed_data_multiqc_report.html
* FastP report: https://htmlpreview.github.io/?https://htmlpreview.github.io/?https://github.com/mMartin95/ecoli_SRX1317390_variant_validation/blob/main/qc/trimmed_reads/SRR2584863_fastp.html
