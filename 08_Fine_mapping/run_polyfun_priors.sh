#!/usr/bin/env bash
# =============================================================================
# PolyFun — functional prior computation (PolyFun + SuSiE fine-mapping)
# =============================================================================
# RECONSTRUCTED: chains the standard PolyFun pipeline steps referenced in
# polyfun_format.R with the actual file naming used in this study.
# The final per-locus fine-mapping step is polyfun.sh (finemapper.py, SuSiE,
# max 5 causal variants per locus); locus coordinates in polyfun.input.
# Reference panel: 1000 Genomes EAS ancestry.
# =============================================================================

NAME=MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd_Neff-SZ_INSO_BD

# 1. Format sumstats: allele-match to LD reference, compute/align Z-scores
#    (or use the interactive version polyfun_format.R)
Rscript format_polyfun_sumstats.R \
    step=1 \
    input=${NAME}_trait_1.txt \
    ref=Merge_FuDan_6021MDD_7318ctrl.indqc.snpqc.hg38.R2_03.snpqc.rmUnmap.rm-misCHR.rmDup.hg19.bim \
    prefix=${NAME}

# 2. Compute per-SNP prior variances (PolyFun)
python /path/to/polyfun/extract_snpvar.py \
    --sumstats ${NAME}.forPolyfun.txt \
    --allow-missing \
    --out ${NAME}.Polyfun.snps_with_var

# 3. Merge SNPVAR back into the sumstats (by CHR & BP)
Rscript format_polyfun_sumstats.R \
    step=2 \
    prefix=${NAME}

# 4. Munge the functional annotations to the LD reference
python /path/to/polyfun/munge_polyfun_ldsc.py \
    --out ${NAME}.parquet \
    --sumstats ${NAME}.finemap_sumstats.addSNPVAR.txt

# 5. Compute the priors
python /path/to/polyfun/polyfun.py \
    --compute-h2-L2 \
    --output-prefix ${NAME} \
    --sumstats ${NAME}.finemap_sumstats.addSNPVAR.txt \
    --ref-ld-chr /path/to/baselineLF2.2.UKB/ \
    --w-ld-chr /path/to/weights.UKB./
