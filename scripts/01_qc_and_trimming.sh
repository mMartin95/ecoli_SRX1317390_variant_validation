#!/usr/bin/env bash
# =============================================================================
# Script: 01_qc_and_trimming.sh
# Description: Quality control (FastQC/MultiQC) before and after trimming of paired-end reads and adapter/quality trimming (fastp)
# =============================================================================

# Script will fail if any command fails
set -e

## 1. CONFIGURATION & VARIABLES 
SAMPLE="SRR2584863" #you can use different SAMPLE_ID, this one is for this specific sample
THREADS=4

RAW_DIR="data/raw_fastq"
TRIM_DIR="data/trimmed_fastq"
QC_DIR="qc"

## 2. INPUT CHECK
if [ ! -f "${RAW_DIR}/${SAMPLE}_1.fastq.gz" ] || [ ! -f "${RAW_DIR}/${SAMPLE}_2.fastq.gz" ]; then
    echo "[ERROR] Input files were not detected in directory ${RAW_DIR}/!"
    echo "Make sure the files ${SAMPLE}_1.fastq.gz and ${SAMPLE}_2.fastq.gz do exist."
    exit 1
fi

# Making of directories
mkdir -p "${QC_DIR}/before_trimming" "${QC_DIR}/after_trimming" "${TRIM_DIR}"

echo "Starting QC and Trimming Pipeline for sample: ${SAMPLE}"

## 3. RAW DATA QC (FastQC & MultiQC) 
echo "=== [1/4] Running FastQC on Raw Reads ==="
fastqc "${RAW_DIR}/${SAMPLE}_1.fastq.gz" "${RAW_DIR}/${SAMPLE}_2.fastq.gz" \
    -o "${QC_DIR}/before_trimming" \
    -t ${THREADS}

echo "=== [2/4] Generating MultiQC Report for Raw Reads ==="
multiqc "${QC_DIR}/before_trimming" \
    -o "${QC_DIR}" \
    -n raw_data_multiqc_report.html \
    --force

## 4. TRIMMING & FILTERING (fastp)
echo "=== [3/4] Trimming adapters and low-quality bases (fastp) ==="
# fastp automatically synchronizes R1 a R2; not synchronized R1 and R2 are removed
fastp \
    -i "${RAW_DIR}/${SAMPLE}_1.fastq.gz" \
    -I "${RAW_DIR}/${SAMPLE}_2.fastq.gz" \
    -o "${TRIM_DIR}/${SAMPLE}_1_trimmed.fastq.gz" \
    -O "${TRIM_DIR}/${SAMPLE}_2_trimmed.fastq.gz" \
    -3 -W 4 -M 20 -l 50 \
    -j "${QC_DIR}/after_trimming/fastp_${SAMPLE}.json" \
    -h "${QC_DIR}/after_trimming/fastp_${SAMPLE}.html" \
    -w ${THREADS}

## 5. TRIMMED DATA QC (FastQC & MultiQC)
echo "=== [4/4] Running FastQC & MultiQC on Trimmed Reads ==="
fastqc "${TRIM_DIR}/${SAMPLE}_1_trimmed.fastq.gz" "${TRIM_DIR}/${SAMPLE}_2_trimmed.fastq.gz" \
    -o "${QC_DIR}/after_trimming" \
    -t ${THREADS}

multiqc "${QC_DIR}/after_trimming" \
    -o "${QC_DIR}" \
    -n trimmed_data_multiqc_report.html \
    --force

echo "[SUCCESS] Quality control and trimming pipeline completed successfully!"