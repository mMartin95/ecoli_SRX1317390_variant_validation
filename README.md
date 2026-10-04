# ecoli_SRX1317390_variant_validation
Variant validation pipeline and IGV snapshot generation for E. coli REL606 (SRR2584863). 

## Project overview:

The project is focused on evaluation of variants of E. coli sample SRR2584863 mapped to reference E.coli strain REL606 with accession ID NC_000913.3.

The source of the experiment project E. coli strain: https://www.ebi.ac.uk/ena/browser/view/SRX1317390

The source of E. coli strain REL606 (NC_000913.3., NCBI) used for mapping: https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=413997

---

## Processing of the sample:

Only SRR2584863 reads of  E.coli sample were processed.

The samples were: 
     a.) checked using fastqc (low quality of reads at their 3' end 140 bz),
     b.) trimmed using fastp (minimal length 50 bases, and mininal quality 20),
     c.) chekced again using fastqc,
     d.) mapped to reference using bwa, resulting SAM was converted to BAM file using samtools, sorted and discarded from duplicates. The final BAM file had 100% mapped reads to reference wherein 98.2% reads were properly paired.
     e.) variants were generated using bcftools mileup | bcftools call and annotated using snpeff.   

---

## Results of Variant Calling:

According to the annotated file, the E. coli sample contained (compared to reference E. coli REL606) 30 mutations. Based on the quality (QUAL > 30), 27 mutations (except those on the positions 3742142, 3895000 and  4017761) remained. Those were filtered using bcftools filter (QUAL > 30, DP >= 10, MQ > 30, AF >= 0.85 calculated from all DP4) with 22 remained and 8 artifacts.


### Final validated Variant Set:
A total 22 fixed mutations remained:
 - 17 substitutions/SNVs
 - 5 indels (4 insertions and 1 deletion)


### Annotated and fixed variants:

Below, there is the list of 22 validated mutations in E. coli sample SRR2584863.


### Coding Region Mutations (Coding & Loss-of-Function)
| Gene Symbol | Genomic Impact / Mutation Type | Protein / Functional Impact | Functional Consequence |
| :--- | :--- | :--- | :--- |
| ybaL | c.1401_1402insGC (Frameshift)| p.Ala469fs Frameshift from aa 469 Loss-of-Function (LOF) | Cation/H+ antiporter disruption |
| yieO | c.964_965insG (Frameshift) | p.Leu322fs Frameshift from aa 332 Loss-of-Function (LOF) | Transcriptional regulator disruption |
| ytfN | c.120_121delGG (Frameshift) | p.Gly1176fs Frameshift from aa 1176| Conserved outer membrane protein alteration |
| yaaH | c.521A>C substitution | p.Asn174Thr | Missense mutation (Transport protein) |
| mrdB | c.206G>A substitution | p.Arg69His | Missense mutation (Rod shape-determining protein) |
| topA | c.2375C>A substitution | p.Thr792Lys | Missense mutation (DNA topoisomerase I) |
| pykF | c.379G>A substitution | p.Asp127Asn | Missense mutation (Pyruvate kinase I) |
| rplS | c.299T>A substitution | p.Leu100Gln | Missense mutation (50S ribosomal protein L19) |
| fis  | c.152A>C substitution | p.Tyr51Ser | Missense mutation (DNA-binding protein Fis) |
| rpsG | c.233G>T substitution | p.Arg78Leu | Missense mutation (30S ribosomal protein S7) |
| malT | c.136A>G substitution | p.Thr46Ala | Missense mutation (Maltose regulon activator) |
| glpR | c.538T>G substitution | p.Ser180Ala | Missense mutation (Glycerol-3-phosphate repressor) |
| hslU | c.1048T>C substitution | p.Ser350Pro | Missense mutation (ATP-dependent protease subunit) |
| iclR | c.602T>G substitution | p.Leu201Arg | Missense mutation (Isocitrate lyase repressor) |
| nadR | c.1010A>C substitution | p.Tyr337Ser | Missense mutation (NAD biosynthesis repressor) |

### Intergenic & Non-Coding Region Mutations
| Region / Location | Variant Details | Biological Context |
| :--- | :--- | :--- |
| Upstream yagW | c.-4924C>A substitution | Promoter / Regulatory region |
| Upstream insL-2 | c.-2580_-2579insA| Transposon / IS element insertion site |
| Downstream elaC |c.*4501_*4502insT| Terminator / 3'-UTR region |
| Upstream ypdG | c.-4865T>G | Promoter / Regulatory region |
| Upstream speC | c.-4515C>T substitution | Ornithine decarboxylase promoter region |
| Upstream 16S rRNA | n.-4653C>A substitution | Ribosomal RNA operon regulatory region |
| Upstream 16S rRNA | n.-2313G>A substitution | Ribosomal RNA operon regulatory region |

---

## IGV screening

IGV tool downloaded from IGV website: https://igv.org/doc/desktop/

The tool was used for the visualization of the detected Variants.

All 30 screenshots of variants are deposited in the repository igv_snapshots

### Reproduction of screenshots

#### Prerequisites
- Python 3.8+
- IGV Desktop Application

#### Execution
```bash
1. Clone repository
git clone [https://github.com/your-username/ecoli-rel606-igv-automation.git](https://github.com/your-username/ecoli-rel606-igv-automation.git)
cd ecoli-rel606-igv-automation

2. Generate the IGV batch script
python3 scripts/make_igv_snapshots.py

3. Execute in IGV
Open IGV -> Tools -> Run Batch Script... -> Select 'auto_snapshots.igv'
