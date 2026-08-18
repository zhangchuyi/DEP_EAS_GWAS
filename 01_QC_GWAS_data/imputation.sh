#!/usr/bin/env bash
# =============================================================================
# Genotype imputation — SHAPEIT5 prephasing + Minimac4
# =============================================================================
# RECONSTRUCTED from the Online Methods section ("Genotype imputation") of
# the manuscript; the original run commands were not retained.
#
# Pipeline: genotyped SNPs were first prephased by SHAPEIT5 and then
# imputed with Minimac4 using the PGGHan2 (N = 20,823) Han Chinese
# reference panel. Post-imputation filters: R2 > 0.8, MAF > 1 %,
# call rate > 95 %, HWE P > 1e-5 (in controls).
#
# Input : QC'd genotyping data (output of plink_qc.sh, e.g.
#         Han_Chinese_MDD.QC.final; 436,828 autosomal SNPs,
#         5,221 cases / 7,317 controls)
# Output: "MDD-Han GWAS" dataset (5,737,278 SNPs) and per-chromosome
#         dosage VCFs (imputed.chrN.dose.vcf.gz) used by
#         ../03_GWAS_statistical_analysis/run_glm_per_chr.sh
#
# Genome build: hg38 for imputation (PGGHan2 panel); if downstream analyses
# require hg19, lift over afterwards (see final optional step).
# =============================================================================

STUDY=Han_Chinese_MDD.QC.final            # QC'd genotypes (PLINK binary fileset)
REFDIR={path_to_PGGHan2}                  # PGGHan2 Han Chinese reference panel (N = 20,823), phased VCF/BCF per chromosome
OUTDIR=imputation
THREADS=8

mkdir -p ${OUTDIR}

# =============================================================================
# Step 0 — One-off: compress the reference panel to MVCF format for Minimac4
# (reference VCF/BCF files phased haplotypes, one per chromosome)
# =============================================================================
# minimac4 --compress-reference ${REFDIR}/PGGHan2.vcf.gz > ${OUTDIR}/PGGHan2.msav

# =============================================================================
# Step 1 — Per-chromosome: prepare VCF -> SHAPEIT5 prephasing -> Minimac4
# =============================================================================
for chr in {1..22}; do

    # ---------- 1a. Export QC'd genotypes of one chromosome to VCF ----------
    plink --bfile ${STUDY} \
          --chr ${chr} \
          --recode vcf bgz \
          --out ${OUTDIR}/study.chr${chr}

    # ---------- 1b. Fill AC/AN tags and index (required by SHAPEIT5) -------
    bcftools +fill-tags ${OUTDIR}/study.chr${chr}.vcf.gz -Oz \
             -o ${OUTDIR}/study.chr${chr}.filltags.vcf.gz -- -t AN,AC
    bcftools sort ${OUTDIR}/study.chr${chr}.filltags.vcf.gz -Oz \
             -o ${OUTDIR}/study.chr${chr}.sorted.vcf.gz
    tabix -p vcf ${OUTDIR}/study.chr${chr}.sorted.vcf.gz

    # ---------- 1c. Prephasing with SHAPEIT5 (reference-aware) --------------
    # Adjust the chromosome coding to the reference panel ("chr1" vs "1").
    SHAPEIT5_phase_common \
        --input ${OUTDIR}/study.chr${chr}.sorted.vcf.gz \
        --reference ${REFDIR}/PGGHan2.chr${chr}.vcf.gz \
        --region chr${chr} \
        --output ${OUTDIR}/phased.chr${chr}.bcf \
        --thread ${THREADS}

    # ---------- 1d. Imputation with Minimac4 --------------------------------
    minimac4 ${OUTDIR}/PGGHan2.msav \
        ${OUTDIR}/phased.chr${chr}.bcf \
        -o ${OUTDIR}/imputed.chr${chr}.dose.vcf.gz

done

# =============================================================================
# Step 2 — Post-imputation QC and merging
#   R2 > 0.8 (Minimac4 INFO/R2 field, PLINK v2.0 for INFO-based filtering),
#   then MAF > 1 %, call rate > 95 %, HWE P > 1e-5 in controls (PLINK v1.9)
# =============================================================================
for chr in {1..22}; do

    # 2a. Keep variants with imputation R2 > 0.8 and convert to PLINK bed
    plink2 --vcf ${OUTDIR}/imputed.chr${chr}.dose.vcf.gz dosage=DS \
           --extract-if-info "INFO/R2 > 0.8" \
           --make-bed \
           --out ${OUTDIR}/MDD_Han.chr${chr}.R2_08

    # 2b. MAF, call rate and HWE filters (PLINK v1.9; HWE tested in controls)
    plink --bfile ${OUTDIR}/MDD_Han.chr${chr}.R2_08 \
          --geno 0.05 \
          --maf 0.01 \
          --hwe 1e-5 \
          --make-bed \
          --out ${OUTDIR}/MDD_Han.chr${chr}.R2_08.qc

done

# 2c. Merge chromosomes
ls ${OUTDIR}/MDD_Han.chr*.R2_08.qc.bed | sed 's/.bed$//' > ${OUTDIR}/mergelist.txt
plink --merge-list ${OUTDIR}/mergelist.txt \
      --make-bed \
      --out ${OUTDIR}/MDD_Han_GWAS

# -----------------------------------------------------------------------------
# Result: "MDD-Han GWAS" — 5,737,278 autosomal biallelic SNPs in
#         5,221 cases / 7,317 controls
# -----------------------------------------------------------------------------

# =============================================================================
# Optional — Liftover hg38 -> hg19 (if downstream analyses use hg19)
#   Picard LiftoverVcf, or plink2 --set-all-var-ids + --update-chr + --update-map
#   with the hg38ToHg19.over.chain file.
# =============================================================================
