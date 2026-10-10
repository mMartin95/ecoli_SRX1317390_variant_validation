#!/usr/bin/env bash
# =============================================================================
# Script: 03_variant_calling.sh
# Description: Genotype likelihood computation (bcftools mpileup) and variant calling (bcftools call) for E. coli REL606.
# =============================================================================

set -e

# 1. CONFIGURATION & VARIABLES
SAMPLE="SRR2584863"
THREADS=4

# Relative pathways
REF_DIR="data/reference"
REF_FASTA="${REF_DIR}/NC_012967.1.fasta"
ALN_DIR="data/aligned_bam"
VAR_DIR="data/variants"

# 2. INPUT CHECK
if [ ! -f "${ALN_DIR}/${SAMPLE}_final.bam" ]; then
    echo "[ERROR] Input final BAM was not found in the directory ${ALN_DIR}/${SAMPLE}_final.bam"
    echo "Firstly run script /02_mapping_and_coverage.sh!"
    exit 1
fi

if [ ! -f "${REF_FASTA}" ]; then
    echo "[ERROR] Reference genom was not found in the directory: ${REF_FASTA}"
    exit 1
fi

mkdir -p "${VAR_DIR}"

echo "Starting Variant Calling Pipeline for sample: ${SAMPLE}"

# 3. VARIANT CALLING (BCFtools pipeline)
echo "[1/2] Computing Genotype Likelihoods & Calling Variants"

bcftools mpileup --threads ${THREADS} -f "${REF_FASTA}" "${ALN_DIR}/${SAMPLE}_final.bam" | \
bcftools call --threads ${THREADS} -m -v -Ob -o "${VAR_DIR}/${SAMPLE}_raw_variants.bcf"

echo "[2/2] Indexing Raw BCF File"
bcftools index "${VAR_DIR}/${SAMPLE}_raw_variants.bcf"

TOTAL_VARIANTS=$(bcftools view -H "${VAR_DIR}/${SAMPLE}_raw_variants.bcf" | wc -l)
echo "📊 Total raw variants detected (unfiltered): ${TOTAL_VARIANTS}"

echo "[SUCCESS] Variant calling complete! Raw variants saved to ${VAR_DIR}/${SAMPLE}_raw_variants.bcf"