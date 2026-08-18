#!/usr/bin/env bash
# =============================================================================
# MAGMA v1.10 — gene-level association analysis
# =============================================================================
# Command flags taken verbatim from the retained logs (see logs/).
# LD reference: 1000 Genomes EAS panel (504 individuals).
# Gene boundaries extended 35 kb upstream / 10 kb downstream
# (MAGMAdefault.genes.annot).
# =============================================================================

# DEP-EAS GWAS
magma \
    --bfile /path/to/1000G_MAGMA_ref/g1000_eas \
    --pval sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.meta use=SNP,P ncol=Neff \
    --gene-annot /path/to/H-MAGMA/Input_Files/MAGMAdefault.genes.annot \
    --out sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85

# MTAG (DEP-SZ-BD-INSO)
magma \
    --bfile /path/to/1000G_MAGMA_ref/g1000_eas \
    --pval MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.txt use=SNP,P ncol=N \
    --gene-annot /path/to/H-MAGMA/Input_Files/MAGMAdefault.genes.annot \
    --out MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD
