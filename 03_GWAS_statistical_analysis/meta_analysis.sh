#!/usr/bin/env bash
# =============================================================================
# Meta-analysis across GWAS sample sets (inverse-variance weighted, PLINK v1.9)
# =============================================================================
# The resulting .meta files carry the columns:
#   CHR BP SNP A1 A2 Ncohort P OR I Ncase Ncontrol Neff MAF SE
# where "I" is the Higgins & Thompson I^2 heterogeneity index and
# Ncohort is the number of cohorts contributing to the variant.
#
# RECONSTRUCTED: the exact invocation was not retained in a log. The commands
# below reproduce the inverse-variance-weighted meta-analyses of the three
# contributing cohorts (PLINK v1.9 --meta-analysis; input format: SNP, A1,
# A2, OR/BETA, SE or P, N/Neff). The fixed-/random-effect selection on I^2
# is implemented in meta_I85.sh.
# =============================================================================

MDD_HAN=mdd_han_5221Ca_7317Con.Neff.tsv
EAS_ALL=mdd2023diverse_EAS_Neff.tsv
EAS_CLINICAL=mdd2023diverse_EAS_clinicalMD_Neff.tsv
TPMI=mdd_296.22_EAS_TPMI_7393Ca_267396Con.hg19.txt

# Primary meta-analysis (all DEP cases)
plink --meta-analysis ${MDD_HAN} ${EAS_ALL} ${TPMI} \
      --out meta_all_EAS.meta

# Clinical-MDD subset meta-analysis
plink --meta-analysis ${MDD_HAN} ${EAS_CLINICAL} ${TPMI} \
      --out meta_clinicalMD_EAS.meta

# Then apply the I^2-based fixed-/random-effect model selection:
#   bash meta_I85.sh   (see meta_I85.sh; i=85, n=3)
