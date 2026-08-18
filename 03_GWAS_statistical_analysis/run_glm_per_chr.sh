#!/usr/bin/env bash
# =============================================================================
# GWAS: additive logistic regression on imputed allelic dosages (PLINK v2.0)
# =============================================================================
# Command flags taken verbatim from the retained run logs (see logs/,
# "Options in effect" of each chromosome .log file). The analysis was run
# per chromosome (chr1-22) and per half-sample (left/right; 586 individuals
# removed from each half for internal replication), using --glm with
# covariates: sex, age, recruitment site and top 5 PCs.
# =============================================================================

DOSE_DIR=/path/to/dosage/vcf        # original: /home/lilab/zhangchuyi/0.claude/0.depression_GWAS/dosage_genotype
PHENO=Merge_FuDan_6021MDD_7318ctrl.indqc.snpqc.hg38.R2_03.snpqc.rmUnmap.rm-misCHR.rmDup.hg19.phenotype.txt
COVAR=left.SEX.sigPC.AGE.Source.covar.txt
KEEP=region_removed_586_left.list     # or region_removed_586_right.list

for chr in {1..22}; do
    plink2 \
        --vcf ${DOSE_DIR}/Han_mdd_6021MDD_7318ctrl.indqc.snpqc.hg38.chr${chr}.dose.R2_03.newID.vcf.gz dosage=DS \
        --pheno ${PHENO} \
        --covar ${COVAR} \
        --covar-variance-standardize \
        --keep ${KEEP} \
        --glm hide-covar \
        --out region_removed_586_left.hg38.dosage.covar.SEX.sigPC.AGE.Source.chr${chr}
done
