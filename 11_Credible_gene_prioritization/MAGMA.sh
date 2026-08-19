#!/usr/bin/env bash
# =============================================================================
# MAGMA v1.10 — gene-level association for credible gene prioritization
# =============================================================================
# Command flags as used in the study. Final
# inputs: DEP-EAS GWAS meta-analysis and MTAG DEP-SZ-BD-INSO results,
# both filtered to imputation R2 > 0.8 (R2_08). LD reference: 1000 Genomes
# EAS panel. Gene boundaries extended 35 kb upstream / 10 kb downstream.
# =============================================================================

# DEP-EAS GWAS
magma \
    --bfile /home/lilab/reference/1000G_MAGMA_ref/g1000_eas \
    --pval sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.meta use=SNP,P ncol=Neff \
    --gene-annot /home/lilab/software/H-MAGMA/Input_Files/MAGMAdefault.genes.annot \
    --out sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08

# MTAG (DEP-SZ-BD-INSO)
magma \
    --bfile /home/lilab/reference/1000G_MAGMA_ref/g1000_eas \
    --pval MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08.txt use=SNP,P ncol=N \
    --gene-annot /home/lilab/software/H-MAGMA/Input_Files/MAGMAdefault.genes.annot \
    --out MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08
