#!/usr/bin/env bash
# =============================================================================
# PolyFun — functional prior computation (PolyFun + SuSiE fine-mapping)
# =============================================================================
# RECONSTRUCTED: chains the standard PolyFun pipeline steps with the actual
# file naming used in this study. The final per-locus fine-mapping step is
# polyfun.sh (finemapper.py, SuSiE, max 5 causal variants per locus); locus
# coordinates in polyfun.input. Reference panel: 1000 Genomes EAS ancestry.
# =============================================================================

NAME=MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd_Neff-SZ_INSO_BD

# 1. Format sumstats: allele-match to LD reference, align/flip Z-scores,
#    write PolyFun input (.forPolyfun.txt) and matched sumstats
#    (.allele-match-LD.zscore.N.txt) — interactive script polyfun_format.R
#    performs the same steps as they were originally run:
Rscript polyfun_format.R

# 2. Compute per-SNP prior variances (PolyFun)
python {path_to_polyfun}/extract_snpvar.py \
    --sumstats ${NAME}.forPolyfun.txt \
    --allow-missing \
    --out ${NAME}.Polyfun.snps_with_var

# 3. Merge SNPVAR back into the sumstats (by CHR & BP) — second half of
#    polyfun_format.R writes ${NAME}.finemap_sumstats.addSNPVAR.txt

# 4. Munge the functional annotations to the LD reference
python {path_to_polyfun}/munge_polyfun_ldsc.py \
    --out ${NAME}.parquet \
    --sumstats ${NAME}.finemap_sumstats.addSNPVAR.txt

# 5. Compute the priors
python {path_to_polyfun}/polyfun.py \
    --compute-h2-L2 \
    --output-prefix ${NAME} \
    --sumstats ${NAME}.finemap_sumstats.addSNPVAR.txt \
    --ref-ld-chr {path_to_baselineLF2.2.UKB}/ \
    --w-ld-chr {path_to_weights.UKB}/
