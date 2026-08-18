#!/usr/bin/env bash
# =============================================================================
# SMR — summary-data-based Mendelian randomization for candidate genes
# =============================================================================
# RECONSTRUCTED from the Methods section ("SMR analysis"); the original
# commands were not retained. Two analyses: DEP-EAS GWAS and DEP-SZ-BD-INSO
# MTAG, against the combined cortex eQTL resource (see smr_eqtl_meta.R).
#
#   - Putatively causal SNPs from fine-mapping (95 % credible sets) served
#     as instrumental QTLs, each tested against all probes within a
#     +/- 2 Mb window via --extract-target-snp-probe.
#   - EAS LD reference panel (e.g. 1000 Genomes EAS, bfile format).
#   - HEIDI test distinguishes true cis-regulatory effects from linkage.
#   - Dual thresholds: FDR_SMR < 0.05 and P_HEIDI > 0.01.
# =============================================================================

SMR=/path/to/smr-1.3.1/linux/smr-1.3.1
LDREF=/path/to/1000G_EAS_bfile          # EAS LD reference panel (PLINK bfile)
EQTL=cortex_eqtl_meta                   # merged eQTL (bim/fam/besd from the meta-analysis)
TARGET=credible_snps_from_finemap.txt   # SNP list from 95 % credible sets

# DEP-EAS GWAS
${SMR} \
    --bfile ${EQTL} \
    --gwas-summary DEP_EAS.ma \
    --beqtl-summary ${EQTL} \
    --extract-target-snp-probe ${TARGET} \
    --probe-wind 2000 \
    --ld-wind 2000 \
    --peqtl-smr 5e-8 \
    --diff-freq-prop 0.2 \
    --out DEP_EAS.smr

# MTAG (DEP-SZ-BD-INSO)
${SMR} \
    --bfile ${EQTL} \
    --gwas-summary MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.ma \
    --beqtl-summary ${EQTL} \
    --extract-target-snp-probe ${TARGET} \
    --probe-wind 2000 \
    --ld-wind 2000 \
    --peqtl-smr 5e-8 \
    --diff-freq-prop 0.2 \
    --out MTAG_EAS_DEP.smr

# Note: --bfile (EAS LD reference) used for LD-based filtering and the HEIDI
# test (P_HEIDI > 0.01 retained). Significance: FDR_SMR < 0.05.
