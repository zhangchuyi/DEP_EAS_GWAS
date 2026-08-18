#!/usr/bin/env bash
# =============================================================================
# GWAS: additive logistic regression on imputed allelic dosages (PLINK v2.0)
# =============================================================================
# Command flags as used in the study (PLINK v2.0 --glm). This is the only
# PLINK analysis performed with PLINK v2.0 (dosage-based association); all
# other PLINK analyses used v1.9. Covariates: sex, age, recruitment site
# and top 5 PCs.
# =============================================================================

DOSE_DIR={path_to_dosage_vcf}
PHENO=phenotype.txt
COVAR=covariates_SEX_age_site_PC1-5.txt

for chr in {1..22}; do
    plink2 \
        --vcf ${DOSE_DIR}/chr${chr}.dose.vcf.gz dosage=DS \
        --pheno ${PHENO} \
        --covar ${COVAR} \
        --covar-variance-standardize \
        --glm hide-covar \
        --out chr${chr}.glm
done
