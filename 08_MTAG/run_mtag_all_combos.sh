#!/usr/bin/env bash
# =============================================================================
# MTAG — Multi-Trait Analysis of GWAS (DEP + 3 of 5 ancillary traits)
# =============================================================================
# RECONSTRUCTED: wraps the actual mtag.py invocation over all C(5,3)=10
# four-trait combinations listed in all_combo.txt, as described in the
# Methods. maxFDR was computed for DEP in each run (mtag.py --fdr); the
# model with the lowest maxFDR (DEP-SZ-BD-INSO) was selected as the
# primary model.
#
# Ancillary traits (EAS): anxiety disorder, insomnia, bipolar disorder,
# schizophrenia, suicide. Study-specific effective sample sizes (N) and
# Z-scores are required for all input files.
# =============================================================================

MTAG=/path/to/mtag-master/mtag.py
LD_REF=/path/to/mtag-master/ld_ref_panel/eas_ldscores
DEP=sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.forMTAG.txt
OUT=add_TPMImdd

declare -A FILES=(
    [ANX]=Anxiety_disorders_300.saige.hg19.addrsID.forMTAG.txt
    [INSO]=insomnia_327.4.saige.hg19.addrsID.forMTAG.txt
    [BD]=bip2024_eas_no23andMe.Neff.forMTAG.txt
    [SZ]=daner_natgen_pgc_eas.Neff.forMTAG.txt
    [Suicide]=Suicide.ASN.forMTAG.txt
)

while read combo; do
    # combo format e.g. "SZ_INSO_BD"
    IFS=_ read -r A B C <<< "${combo}"
    python ${MTAG} \
        --sumstats ${DEP},${FILES[$A]},${FILES[$B]},${FILES[$C]} \
        --n_min 0.0 --incld_ambig_snps \
        --ld_ref_panel ${LD_REF}/ \
        --out ${OUT}/MTAG_EAS_DEP_NCrevision_dosage-${combo} \
        --stream_stdout --force --fdr
done < all_combo.txt

# Model diagnostics (Methods): maxFDR, mean chi^2 for DEP, lambda_GC, Q-Q
# plots and the estimated error covariance matrix (Sigma) were extracted
# from each run's *_trait_1.txt and log output; the combination with the
# lowest maxFDR for DEP was selected for downstream analyses.
