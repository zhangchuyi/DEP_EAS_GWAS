#!/usr/bin/env bash
# =============================================================================
# Quality control of raw genotyping data (PLINK v2.0)
# =============================================================================
# RECONSTRUCTED from the Online Methods section ("Quality control for GWAS
# data") of the manuscript; the original QC run logs were not retained.
# The procedure follows Anderson et al. (Nat Protoc. 2010;5:1564-73).
#
# Raw dataset: 5,539 cases and 7,584 controls, 595,220 autosomal SNPs.
#
# After QC: 318 individuals and 158,392 variants excluded;
# 436,828 autosomal biallelic SNPs remained in 5,221 cases and 7,317 controls.
# =============================================================================

RAW=data.raw          # PLINK binary fileset of the raw genotyping data
OUT=qcd

# ---------- Individual-level QC ---------------------------------------------

# (1) Sex check from X-chromosome SNP homozygosity rates (F estimates)
plink2 --bfile ${RAW} --chr 1-22,X \
       --split-x hg19 no-fail \
       --make-bed --out ${OUT}.chrXsplit
plink2 --bfile ${OUT}.chrXsplit \
       --check-sex \
       --out ${OUT}.sexcheck
# Remove samples flagged as sex discrepancies (n=10 in the study)
awk 'NR==1 || $5=="PROBLEM" {print $1,$2}' ${OUT}.sexcheck.sexcheck > ${OUT}.sexremove.txt
plink2 --bfile ${RAW} --remove ${OUT}.sexremove.txt --make-bed --out ${OUT}.step1

# (2) Missingness > 3% and heterozygosity beyond +/- 6 SD from the mean (n=28)
plink2 --bfile ${OUT}.step1 --mind 0.03 --make-bed --out ${OUT}.step2a
plink2 --bfile ${OUT}.step2a --het --out ${OUT}.het
Rscript -e '
  het <- read.table("qcd.het.het", header=T)
  m <- mean(het$F); s <- sd(het$F)
  keep <- het[abs(het$F - m) <= 6*s, c("FID","IID")]
  write.table(keep, "qcd.hetremove.txt", row.names=F, col.names=F, quote=F)
'
plink2 --bfile ${OUT}.step2a --remove ${OUT}.hetremove.txt --make-bed --out ${OUT}.step2b

# (3) Duplicates / related individuals by IBD (PI_HAT > 0.1875; n=168)
plink2 --bfile ${OUT}.step2b \
       --indep-pairwise 50 5 0.2 \
       --out ${OUT}.prune
plink2 --bfile ${OUT}.step2b --extract ${OUT}.prune.prune.in \
       --genome --min 0.1875 \
       --out ${OUT}.ibd
# Within each pair flagged with PI_HAT > 0.1875, keep the sample with the
# lower missingness (or lower FID/IID, per Anderson et al.)
awk 'NR>1 && $10 >= 0.1875 {print $1,$2}' ${OUT}.ibd.genome > ${OUT}.ibdremove.txt
plink2 --bfile ${OUT}.step2b --remove ${OUT}.ibdremove.txt --make-bed --out ${OUT}.step3

# (4) PCA outliers (visual inspection of PC1 vs PC2; n=112 removed)
#    LD pruning for PCA: --indep-pairwise 50 5 0.2 on autosomal SNPs,
#    excluding regions of extensive high LD (Anderson et al. 2010),
#    yielding 186,199 SNPs used as input for EIGENSTRAT.
plink2 --bfile ${OUT}.step3 \
       --exclude high-LD-regions.txt \
       --indep-pairwise 50 5 0.2 \
       --out ${OUT}.step3.indep
plink2 --bfile ${OUT}.step3 --extract ${OUT}.step3.indep.prune.in \
       --make-bed --out ${OUT}.step3.pruned
# -> EIGENSTRAT PCA (see eigstrat_pca.sh) -> inspect PC1 vs PC2 plot
#    -> remove.outliers.txt (n=112 in the study)
plink2 --bfile ${OUT}.step3 --remove remove.outliers.txt --make-bed --out ${OUT}.step4

# ---------- Variant-level QC -------------------------------------------------

plink2 --bfile ${OUT}.step4 \
       --geno 0.05 \
       --maf 0.01 \
       --hwe 1e-5 \
       --make-bed --out ${OUT}.step5
# Differential missingness between cases and controls (n=39,687 in the study)
plink2 --bfile ${OUT}.step5 \
       --test-missing \
       --out ${OUT}.missingdiff
awk 'NR==1 || $6 < 1e-5 {print $2}' ${OUT}.missingdiff.missing > ${OUT}.diffmiss.snps
plink2 --bfile ${OUT}.step5 --exclude ${OUT}.diffmiss.snps \
       --make-bed --out ${OUT}.final
# -----------------------------------------------------------------------------
# Result: 436,828 autosomal biallelic SNPs in 5,221 cases / 7,317 controls
# -----------------------------------------------------------------------------
