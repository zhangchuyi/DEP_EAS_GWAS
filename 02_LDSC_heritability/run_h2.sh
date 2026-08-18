#!/usr/bin/env bash
# =============================================================================
# LDSC v1.0.1 SNP-based heritability estimation (liability scale)
# =============================================================================
# Command flags taken from the retained run logs (see logs/). EAS LD scores
# (HapMap3 SNPs) from https://data.broadinstitute.org/alkesgroup/LDSCORE/.
#
# Preprocessing (shared with genetic correlation analysis, see
# ../05_LDSC_genetic_correlation/LDSC_summary_QC.sh):
#   - remove MHC region (hg19, chr6:25-35 Mb)
#   - remove ambiguous A/T and G/C SNPs
#   - munge_sumstats.py (HapMap3 SNPs only)
#
# The analysis was run with --pop-prev 0.08 / 0.1 / 0.15 / 0.2
# (assumed lifetime DEP prevalence) and --samp-prev = sample prevalence.
# =============================================================================

REF_LDSC=/path/to/ldsc/reference/eas_ldscores     # EAS LD scores (original: /home/lilab/zhangchuyi/1.GWAS/ref/ldsc/1000G_Phase3_LDSC/eas_ldscores/)
SUMSTATS=sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.LDSC.sumstats.gz
SAMP_PREV=0.05

for POP_PREV in 0.08 0.1 0.15 0.2; do
    ldsc.py \
        --h2 ${SUMSTATS} \
        --ref-ld-chr ${REF_LDSC}/ \
        --out $(basename ${SUMSTATS} .sumstats.gz).prev${POP_PREV}.h2 \
        --pop-prev ${POP_PREV} \
        --samp-prev ${SAMP_PREV} \
        --w-ld-chr ${REF_LDSC}/
done
