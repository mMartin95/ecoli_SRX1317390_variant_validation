#!/usr/bin/env python3
"""
Automated IGV Snapshot Generator with Context-Aware Window Sizing,
Strand Flip, and Intergenic Region Annotation.

Author: BioinfoMentor Student Portfolio
Usage:
    python3 make_igv_snapshots.py
"""

import os
import re

# =============================================================================
# 1. KONFIGURACE A CESTY K SOUBORŮM
# =============================================================================
CHROMOSOME = "NC_012967.1"

# Vstupní datové soubory
REF_FASTA = "reference.fna"                        # Případně reference_rel606.fasta
VCF_FILE = "fixed_variants_for_igv_FINAL.vcf"     # Tůj opravený VCF soubor
BAM_FILE = "SRR2584863_final.bam"
GFF_FILE = "reference_rel606_fixed.gff"

# Výstupní složka a generovaný IGV batch skript
OUTPUT_DIR = "igv_snapshots"
BATCH_SCRIPT_OUT = "auto_snapshots.igv"

# Okna pro zobrazení (bp od pozice mutace na každou stranu)
CODING_WINDOW = 150      # Celkem 300 bp výřez pro kódující mutace
INTERGENIC_WINDOW = 400  # Celkem 800 bp výřez pro spolehlivý záber sousedních genů


# =============================================================================
# 2. POMOCNÉ FUNKCE PRO PRÁCI S GFF3 A VCF
# =============================================================================

def parse_gff_genes(gff_path):
    """
    Načte GFF3 soubor a vrátí seřazený seznam genů s jejich souřadnicemi.
    Každý záznam: (start, end, gene_name, strand)
    """
    genes = []
    if not os.path.exists(gff_path):
        print(f"[VAROVÁNÍ] GFF soubor '{gff_path}' nenalezen.")
        return genes

    with open(gff_path, "r") as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue
            parts = line.strip().split("\t")
            if len(parts) < 9:
                continue

            feature_type = parts[2]
            # Hledáme hlavní kódující prvky nebo geny
            if feature_type in ["gene", "CDS"]:
                try:
                    start = int(parts[3])
                    end = int(parts[4])
                except ValueError:
                    continue

                strand = parts[6]
                attributes = parts[8]

                # Extrakce jména genu podle priority atributů
                gene_name = None
                for key in ["Name=", "gene=", "gene_name=", "locus_tag=", "ID="]:
                    match = re.search(rf"{key}([^;]+)", attributes)
                    if match:
                        gene_name = match.group(1).replace("gene-", "")
                        break

                if not gene_name:
                    gene_name = f"unknown_{start}_{end}"

                genes.append((start, end, gene_name, strand))

    # Seřazení genů podle startovní pozice
    genes.sort(key=lambda x: x[0])
    return genes


def get_gene_context(pos, genes):
    """
    Určí biologický kontext pro danou genomic pozici:
    - Pokud je v genu: vrátí (gene_name, strand, is_intergenic=False)
    - Pokud je intergenní: vrátí (flanking_description, "+", is_intergenic=True)
    """
    prev_gene = None

    for start, end, gene_name, strand in genes:
        if start <= pos <= end:
            # Mutace padla přímo do kódující oblasti
            return gene_name, strand, False

        if pos < start:
            # Našli jsme první gen ZA mutací
            next_gene = gene_name
            if prev_gene:
                intergenic_label = f"intergenic_{prev_gene}_vs_{next_gene}"
            else:
                intergenic_label = f"intergenic_before_{next_gene}"
            return intergenic_label, "+", True

        prev_gene = gene_name

    # Pokud je pozice až za posledním genem v GFF
    if prev_gene:
        return f"intergenic_after_{prev_gene}", "+", True

    return "intergenic_unknown", "+", True


def extract_vcf_positions(vcf_path):
    """
    Vytáhne ze zadaného VCF souboru seznam genomic pozic.
    """
    positions = []
    if not os.path.exists(vcf_path):
        print(f"[CHYBA] VCF soubor '{vcf_path}' neexistuje!")
        return positions

    with open(vcf_path, "r") as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue
            parts = line.strip().split("\t")
            if len(parts) >= 2:
                try:
                    positions.append(int(parts[1]))
                except ValueError:
                    continue
    return positions


# =============================================================================
# 3. HLAVNÍ GENERÁTOR IGV BATCH SKRIPTU
# =============================================================================

def generate_igv_script():
    print("=" * 60)
    print("  BioinfoMentor: IGV Batch Script Generator")
    print("=" * 60)

    # 1. Kontrola a příprava adresářů
    abs_out_dir = os.path.abspath(OUTPUT_DIR)
    os.makedirs(abs_out_dir, exist_ok=True)

    # 2. Načtení dat
    print(f"[*] Načítám GFF3 anotace z: {GFF_FILE}")
    genes = parse_gff_genes(GFF_FILE)
    print(f"    -> Načteno {len(genes)} genů.")

    print(f"[*] Načítám pozice mutací z VCF: {VCF_FILE}")
    positions = extract_vcf_positions(VCF_FILE)
    print(f"    -> Nalezeno {len(positions)} pozic k vizualizaci.")

    if not positions:
        print(f"[CHYBA] Žádné pozice k zpracování ze souboru '{VCF_FILE}'. Končím.")
        return

    # 3. Zápis IGV dávkového skriptu (.igv)
    print(f"[*] Generuji dávkový skript pro IGV: {BATCH_SCRIPT_OUT}")

    abs_ref = os.path.abspath(REF_FASTA)
    abs_vcf = os.path.abspath(VCF_FILE)
    abs_bam = os.path.abspath(BAM_FILE)
    abs_gff = os.path.abspath(GFF_FILE)

    with open(BATCH_SCRIPT_OUT, "w") as f:
        # Inicializace prostředí IGV
        f.write("new\n")
        f.write(f"genome {abs_ref}\n")
        f.write(f"load {abs_vcf}\n")
        f.write(f"load {abs_bam}\n")
        f.write(f"load {abs_gff}\n")

        # Rozbalení GFF tracku pro čisté zobrazení názvů genů
        gff_basename = os.path.basename(abs_gff)
        f.write(f"expand {gff_basename}\n")

        # Nastavení výstupní složky
        f.write(f"snapshotDirectory {abs_out_dir}\n\n")

        # Generování snímků pro jednotlivé pozice
        for pos in positions:
            context_label, strand, is_intergenic = get_gene_context(pos, genes)

            # Adaptivní výřez okna
            window = INTERGENIC_WINDOW if is_intergenic else CODING_WINDOW
            start_pos = max(1, pos - window)
            end_pos = pos + window

            # Přesun na pozici
            f.write(f"goto {CHROMOSOME}:{start_pos}-{end_pos}\n")

            # Otočení podle orientace genu (pro mínus řetězec)
            if strand == "-":
                f.write("flip\n")

            # Vytvoření snímku
            snapshot_name = f"{context_label}_pos{pos}.png"
            f.write(f"snapshot {snapshot_name}\n")

            # Vrácení orientace zpět
            if strand == "-":
                f.write("flip\n")

        f.write("exit\n")

    print("\n[HOTOVO] Skript byl úspěšně vygenerován!")
    print(f"Spusť IGV a zvol: Tools -> Run Batch Script... -> Vyber '{BATCH_SCRIPT_OUT}'")
    print("=" * 60)


if __name__ == "__main__":
    generate_igv_script()