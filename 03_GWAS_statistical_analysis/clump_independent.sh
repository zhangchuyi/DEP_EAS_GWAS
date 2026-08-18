#!/usr/bin/env bash
# =============================================================================
# Definition of genome-wide significant independent loci (PLINK 1.9 --clump)
# =============================================================================
# Command flags taken verbatim from the retained clump logs (see logs/
# *independent.log). LD reference: the study's imputed MDD-Han dataset
# (7,174,013 SNPs, 13,339 individuals).
#
# DEP-EAS GWAS (and clinical-MDD subset): P <= 5e-6 (the stricter 5e-8
# threshold yielded no results in the primary GWAS; see Methods).
# MTAG results: P <= 5e-8.
# =============================================================================

BFILE=/path/to/Merge_FuDan_6021MDD_7318ctrl.indqc.snpqc.hg38.R2_03.snpqc.rmUnmap.rm-misCHR.rmDup.hg19

# Primary DEP-EAS meta-analysis
plink --bfile ${BFILE} \
      --clump sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.meta \
      --clump-field P --clump-snp-field SNP \
      --clump-p1 5e-6 --clump-kb 500 --clump-r2 0.1 \
      --out sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.independent

# Clinical-MDD subset meta-analysis
plink --bfile ${BFILE} \
      --clump sorted_meta_mdd2023diverse_EAS_clinicalMD_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.meta \
      --clump-field P --clump-snp-field SNP \
      --clump-p1 5e-6 --clump-kb 500 --clump-r2 0.1 \
      --out sorted_meta_mdd2023diverse_EAS_clinicalMD_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.independent

# MTAG (DEP-SZ-BD-INSO) results use --clump-p1 5e-8:
plink --bfile ${BFILE} \
      --clump MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.txt \
      --clump-field mtag_pval --clump-snp-field SNP \
      --clump-p1 5e-8 --clump-kb 500 --clump-r2 0.1 \
      --out MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD.independent
