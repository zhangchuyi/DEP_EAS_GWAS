#!/usr/bin/env bash
# =============================================================================
# SMR — summary-data-based Mendelian randomization for candidate genes
# =============================================================================
# RECONSTRUCTED from the Methods section ("SMR analysis"); the original
# commands were not retained.
# MTAG, against the combined cortex eQTL resource (see smr_eqtl_meta.R).
#
#   - Putatively causal SNPs from fine-mapping (95 % credible sets) served
#     as instrumental QTLs, each tested against all probes within a
#     +/- 2 Mb window via --extract-target-snp-probe.
#   - EAS LD reference panel (e.g. 1000 Genomes EAS, bfile format).
#   - HEIDI test distinguishes true cis-regulatory effects from linkage.
#   - Dual thresholds: FDR_SMR < 0.05 and P_HEIDI > 0.01.
# =============================================================================

MDD_Han="Han_Chinese_MDD.QC.R2_08"
LDREF=/path/to/1000G_EAS_bfile          # EAS LD reference panel (PLINK bfile)
EQTL="MetaBrain_Chinese_pfc_meta"       # merged eQTL (bim/fam/besd from the meta-analysis)

# MTAG (DEP-SZ-BD-INSO)
smr_Linux \
    --bfile ${MDD_Han} \
    --gwas-summary MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD.forSMR.txt \
    --beqtl-summary ${EQTL} \
    --extract-target-snp-probe snp_probe.list \
    --diff-freq-prop 0.2 \
    --out MTAG_EAS_DEP.smr

# Note: --bfile (EAS LD reference) used for LD-based filtering and the HEIDI
# test (P_HEIDI > 0.01 retained). Significance: FDR_SMR < 0.05.
