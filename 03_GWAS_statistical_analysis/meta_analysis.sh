#!/usr/bin/env bash
# =============================================================================
# Meta-analysis across GWAS sample sets (inverse-variance weighted, PLINK v2.0)
# =============================================================================
# The resulting .meta files carry the columns:
#   CHR BP SNP A1 A2 Ncohort P OR I Ncase Ncontrol Neff MAF SE
# where "I" is the Higgins & Thompson I^2 heterogeneity index and
# Ncohort is the number of cohorts contributing to the variant.
#
# RECONSTRUCTED: the exact invocation was not retained in a log. The command
# below reproduces the inverse-variance-weighted meta-analysis of the
# per-cohort GWAS summary statistics (output columns as above); the
# fixed/random-effect selection on I^2 is implemented in meta_I75.sh.
# =============================================================================

# Per-cohort GWAS outputs (plink2 --glm produces OR/SE in .glm.logistic.hybrid)
COHORTS="mdd_han.glm.gz dep_meng.glm.gz mdd_tpmi.glm.gz"

plink2 \
    --meta-analysis ${COHORTS} \
    --out merged.meta

# Then apply the I^2-based fixed-/random-effect model selection:
#   bash meta_I75.sh   (see meta_I75.sh; sets i=85, n=3 by default)
