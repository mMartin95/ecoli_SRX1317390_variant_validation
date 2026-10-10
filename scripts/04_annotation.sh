#!/usr/bin/env bash
# =============================================================================
# Script: 04_annotation.sh
# Description: Chromosome renaming, Quality Hard-filtering, and SnpEff Annotation
# =============================================================================

set -e 

# 1. CONFIGURATION & VARIABLES 
SAMPLE="SRR2584863"
VAR_DIR="data/variants"

SNPEFF_DB="Escherichia_coli_str_k_12_substr_rel606"

RAW_BCF="${VAR_DIR}/${SAMPLE}_raw_variants.bcf"
RENAMED_VCF="${VAR_DIR}/${SAMPLE}_renamed.vcf"
FILTERED_VCF="${VAR_DIR}/${SAMPLE}_filtered.vcf"
ANNOTATED_VCF="${VAR_DIR}/${SAMPLE}_final_annotated.vcf"
CHR_MAP="data/reference/chr_map.txt"

# 2. INPUT CHECK 
if [ ! -f "${RAW_BCF}" ]; then
    echo "[ERROR] Raw BCF file was not found in the directory: ${RAW_BCF}"
    exit 1
fi

mkdir -p "${VAR_DIR}"

# 3. STEP 1: RENAME CHROMOSOMES FOR SNPEFF COMPATIBILITY 
echo "[1/3] Renaming chromosomes for SnpEff compatibility"
# Changing of NC_012967.1 -> Chromosome due to functional annotation 
    echo "NC_012967.1 Chromosome" > "${CHR_MAP}"
fi

bcftools annotate --rename-chrs "${CHR_MAP}" "${RAW_BCF}" -O v -o "${RENAMED_VCF}"

# 4. STEP 2: QUALITY HARD-FILTERING
echo "[2/3] Quality Hard-Filtering (QUAL > 30, FMT/DP >= 10, MQ > 30)"
bcftools filter -i 'QUAL > 30 && DP >= 10 && MQ > 30 && (DP4[2] + DP4[3]) / (DP4[0] + DP4[1] + DP4[2] + DP4[3]) >= 0.85' "${RENAMED_VCF}" -O v -o "${FILTERED_VCF}"

PASSED_COUNT=$(bcftools view -H "${FILTERED_VCF}" | wc -l)
echo "High-quality variants remaining: ${PASSED_COUNT}"

# --- 5. STEP 3: FUNCTIONAL ANNOTATION (SnpEff) ---
echo "[3/3] Functional Variant Annotation (SnpEff)"
snpEff -v "${SNPEFF_DB}" "${FILTERED_VCF}" > "${ANNOTATED_VCF}"

rm "${RENAMED_VCF}"

echo "[SUCCESS] Pipeline finished! Final output: ${ANNOTATED_VCF}"