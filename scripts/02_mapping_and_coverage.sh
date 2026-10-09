#!/usr/bin/env bash
# =============================================================================
# Script: 02_mapping_and_coverage.sh
# Description: Reads alignment (BWA-MEM), BAM sorting, duplicate removal, indexing, and depth/coverage metrics evaluation.
# =============================================================================

set -e

# 1. CONFIGURATION AND VARIABLES
SAMPLE="SRR2584863"
THREADS=4

# Relative pathway
REF_DIR="data/reference"
REF_FASTA="${REF_DIR}/NC_012967.1.fasta"
TRIM_DIR="data/trimmed_fastq"
ALN_DIR="data/aligned_bam"
QC_DIR="qc"

MIN_COVERAGE=20

# 2. INPUT CHECK 
if [ ! -f "${REF_FASTA}" ]; then
    echo "[ERROR] Reference genome was not found in the directory : ${REF_FASTA}"
    echo "Download or prepare reference genome of E. coli REL606."
    exit 1
fi

if [ ! -f "${TRIM_DIR}/${SAMPLE}_1_trimmed.fastq.gz" ] || [ ! -f "${TRIM_DIR}/${SAMPLE}_2_trimmed.fastq.gz" ]; then
    echo "[ERROR] Trimmed FASTQ files were not found in the directory ${TRIM_DIR}/!"
    echo "Firstly, run the script/01_qc_and_trimming.sh."
    exit 1
fi

# Preparation of directories
mkdir -p "${ALN_DIR}" "${QC_DIR}"

echo "Starting Alignment and Coverage Pipeline for sample: ${SAMPLE}"

# 3. REFERENCE INDEXING (BWA & Samtools)
echo "[1/5] Checking Reference Genome Index"
if [ ! -f "${REF_FASTA}.bwt" ]; then
    echo "Building BWA index for reference genome..."
    bwa index "${REF_FASTA}"
else
    echo "BWA index already exists. Skipping."
fi

if [ ! -f "${REF_FASTA}.fai" ]; then
    echo "Building Samtools FASTA index (.fai)..."
    samtools faidx "${REF_FASTA}"
else
    echo "Samtools FASTA index already exists. Skipping."
fi

# 4. MAPPING, CONVERSION & COORDINATE SORTING 
echo "[2/5] Aligning reads with BWA-MEM and sorting to BAM"
bwa mem -t ${THREADS} -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" \
    "${REF_FASTA}" \
    "${TRIM_DIR}/${SAMPLE}_1_trimmed.fastq.gz" \
    "${TRIM_DIR}/${SAMPLE}_2_trimmed.fastq.gz" | \
    samtools view -u - | \
    samtools sort -@ ${THREADS} -o "${ALN_DIR}/${SAMPLE}_sorted.bam" -

# 5. MARK & REMOVE PCR DUPLICATES
echo "[3/5] Marking and Removing PCR Duplicates"
samtools collate -o "${ALN_DIR}/${SAMPLE}_collate.bam" "${ALN_DIR}/${SAMPLE}_sorted.bam"
samtools fixmate -m "${ALN_DIR}/${SAMPLE}_collate.bam" "${ALN_DIR}/${SAMPLE}_fixmate.bam"
samtools sort -@ ${THREADS} -o "${ALN_DIR}/${SAMPLE}_fixmate_sorted.bam" "${ALN_DIR}/${SAMPLE}_fixmate.bam"
samtools markdup -r -@ ${THREADS} "${ALN_DIR}/${SAMPLE}_fixmate_sorted.bam" "${ALN_DIR}/${SAMPLE}_final.bam"

# Removing of generated additional bam files
rm "${ALN_DIR}/${SAMPLE}_sorted.bam" "${ALN_DIR}/${SAMPLE}_collate.bam" "${ALN_DIR}/${SAMPLE}_fixmate.bam" "${ALN_DIR}/${SAMPLE}_fixmate_sorted.bam"

# 6. INDEXING FINAL BAM
echo "[4/5] Indexing Final BAM File"
samtools index "${ALN_DIR}/${SAMPLE}_final.bam"

# 7. COVERAGE EVALUATION & QUALITY CHECKPOINT
echo "[5/5] Calculating Coverage and Depth Metrics"
COVERAGE_REPORT="${QC_DIR}/${SAMPLE}_coverage_stats.txt"
samtools coverage "${ALN_DIR}/${SAMPLE}_final.bam" > "${COVERAGE_REPORT}"

# Extraction of average meandepth (second slope)
MEAN_DEPTH=$(awk 'NR==2 {print $7}' "${COVERAGE_REPORT}")
echo "Mean Coverage Depth: ${MEAN_DEPTH}x"

# Comparison of calculated coverage with the minimal coverage(MIN_COVERAGE)
IS_SUFFICIENT=$(awk -v depth="${MEAN_DEPTH}" -v min="${MIN_COVERAGE}" 'BEGIN {if (depth >= min) print "YES"; else print "NO"}')

if [ "${IS_SUFFICIENT}" == "YES" ]; then
    echo "[SUCCESS] Sample passed coverage checkpoint (${MEAN_DEPTH}x >= ${MIN_COVERAGE}x)."
    echo "Ready for Step 03 (Variant Calling)."
else
    echo "[WARNING] Low coverage detected (${MEAN_DEPTH}x < ${MIN_COVERAGE}x)!"
    echo "Variant calling in Step 03 may yield false positives or missing calls."
fi