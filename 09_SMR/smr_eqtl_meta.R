#!/usr/bin/env Rscript
# =============================================================================
# SMR eQTL meta-analysis — combine two EAS brain-cortex eQTL datasets
# =============================================================================
# RECONSTRUCTED from the Methods section ("SMR analysis"); the original
# script was not retained. Two brain cortex eQTL datasets from EAS samples
# were combined into a single "cortex eQTL" resource by standard-error-
# weighted Z-score meta-analysis:
#   - Chen et al. (N = 217)
#   - MetaBrain (N = 208)
# =============================================================================

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
chen_file  <- args[1]   # eQTL file 1: columns SNP, Probe, Beta, SE (or Z)
metab_file <- args[2]   # eQTL file 2: same columns
out_file   <- args[3]   # merged output

chen  <- fread(chen_file,  header = TRUE)
metab <- fread(metab_file, header = TRUE)

# Z-scores (compute from BETA/SE if Z not given)
to_z <- function(d) {
  if (!"Z" %in% names(d)) d[, Z := Beta / SE]
  d
}
chen  <- to_z(chen)
metab <- to_z(metab)

# SE-weighted Z-score meta-analysis (weight = 1/SE)
chen[,  W := 1 / SE^2]
metab[, W := 1 / SE^2]

m <- merge(chen, metab, by = c("SNP", "Probe"), suffixes = c("_1", "_2"))
m[, Z_meta := (Z_1 * W_1 + Z_2 * W_2) / sqrt(W_1 + W_2)]
m[, SE_meta := 1 / sqrt(W_1 + W_2)]
m[, BETA_meta := Z_meta * SE_meta]
m[, P_meta := 2 * pnorm(-abs(Z_meta))]

out <- m[, .(SNP, Probe, BETA = BETA_meta, SE = SE_meta, Z = Z_meta, P = P_meta)]
fwrite(out, out_file, sep = "\t", quote = FALSE)
