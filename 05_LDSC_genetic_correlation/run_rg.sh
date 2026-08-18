#!/usr/bin/env bash
# =============================================================================
# LDSC v1.0.1 — genome-wide genetic correlations of EAS DEP with other
# phenotypes in East Asians
# =============================================================================
# Command flags taken verbatim from the retained rg logs (see logs/).
# The 46 phenotypes are listed in LDSC.pheno. Reference: 1000 Genomes EAS
# panel. Traits with FDR < 0.05 were reported as significantly correlated.
#
# Preprocessing of each trait's summary statistics:
#   bash LDSC_summary_QC.sh   (MHC removal, A/T & G/C removal, munge_sumstats)
# =============================================================================

REF_LDSC=/path/to/reference/eas_ldscores   # original: /home/lilab/reference/eas_ldscores/
DEP_SUMSTATS=sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.LDSC.sumstats.gz

while read pheno; do
    fname=$(echo "${pheno}" | tr ' ' '_')
    ldsc.py \
        --ref-ld-chr ${REF_LDSC}/ \
        --out ./${fname}.auto-DEP_EAS_ourHan_dosage_allCovar_addTPMI_rg \
        --rg ./${fname}.auto.sumstats.gz,${DEP_SUMSTATS} \
        --w-ld-chr ${REF_LDSC}/
done < LDSC.pheno

# Collect results (see merge_LDSC_result.sh for the original parsing)
