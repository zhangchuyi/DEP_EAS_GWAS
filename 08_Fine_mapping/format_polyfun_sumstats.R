#!/usr/bin/env Rscript
#
# format_polyfun_sumstats.R
# ─────────────────────────
# Format GWAS summary statistics for PolyFun fine-mapping pipeline.
# Handles two sub-steps:
#   step=1 : Allele-matching against LD reference → write .forPolyfun.txt
#            and .allele-match-LD.zscore.N.txt
#   step=2 : Merge PolyFun output (.Polyfun.snps_with_var) back into the
#            matched sumstats → write .finemap_sumstats.addSNPVAR.txt
#
# This script is meant to be called by run_polyfun_format.sh but can also
# be used stand-alone:
#
#   Rscript format_polyfun_sumstats.R \
#       step=1 \
#       input=MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.txt \
#       ref=Merge_FuDan_6021MDD_7318ctrl.indqc.snpqc.hg38.R2_03.snpqc.rmUnmap.rm-misCHR.rmDup.hg19.bim \
#       prefix=MTAG.output \
#       chr=CHR bp=BP snp=SNP a1=A1 a2=A2 z=Z n=N
#
#   Rscript format_polyfun_sumstats.R \
#       step=2 \
#       prefix=MTAG.output
#
# Column-name arguments (chr, bp, snp, a1, a2, z, n, beta, se, frq, p)
# let you handle files with arbitrary column names.
# If z is missing but both beta and se are present, Z = BETA/SE is computed.

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
})


# ── Argument parsing ────────────────────────────────────────────────────────

args <- commandArgs(trailingOnly = TRUE)

# Convert "key=value" pairs (and --key value) into a named list
parse_args <- function(args) {
  parsed <- list()
  i <- 1
  while (i <= length(args)) {
    x <- args[i]
    if (grepl("^--", x)) {
      # --key value  (also support --key=value)
      key <- sub("^--", "", x)
      if (grepl("=", key)) {
        parts <- strsplit(key, "=")[[1]]
        key   <- parts[1]
        val   <- paste(parts[-1], collapse = "=")
        parsed[[key]] <- val
        i <- i + 1
      } else if (i < length(args) && !grepl("^--", args[i + 1])) {
        parsed[[key]] <- args[i + 1]
        i <- i + 2
      } else {
        # boolean flag
        parsed[[key]] <- TRUE
        i <- i + 1
      }
    } else if (grepl("=", x)) {
      parts <- strsplit(x, "=")[[1]]
      key   <- parts[1]
      val   <- paste(parts[-1], collapse = "=")
      parsed[[key]] <- val
      i <- i + 1
    } else {
      i <- i + 1
    }
  }
  return(parsed)
}

params <- parse_args(args)

# ── Required / default parameters ──────────────────────────────────────────

step   <- params[["step"]]
prefix <- params[["prefix"]]

# Column name mappings (GWAS file column → internal name)
# Defaults match the MTAG output format
col_map <- list(
  chr  = if (!is.null(params[["chr"]]))  params[["chr"]]  else "CHR",
  bp   = if (!is.null(params[["bp"]]))   params[["bp"]]   else "BP",
  snp  = if (!is.null(params[["snp"]]))  params[["snp"]]  else "SNP",
  a1   = if (!is.null(params[["a1"]]))   params[["a1"]]   else "A1",
  a2   = if (!is.null(params[["a2"]]))   params[["a2"]]   else "A2",
  z    = if (!is.null(params[["z"]]))    params[["z"]]    else "Z",
  n    = if (!is.null(params[["n"]]))    params[["n"]]    else "N",
  beta = if (!is.null(params[["beta"]])) params[["beta"]] else "BETA",
  se   = if (!is.null(params[["se"]]))   params[["se"]]   else "SE",
  frq  = if (!is.null(params[["frq"]]))  params[["frq"]]  else "FRQ",
  pval = if (!is.null(params[["p"]]))    params[["p"]]    else "P"
)

# ── Helper: stop with usage ────────────────────────────────────────────────

usage <- function(msg = NULL) {
  if (!is.null(msg)) cat("ERROR:", msg, "\n\n")
  cat(
    "Usage:\n",
    "  Step 1 (pre-PolyFun):\n",
    "    Rscript format_polyfun_sumstats.R step=1 input=<file> ref=<bim> prefix=<out> [chr=CHR bp=BP snp=SNP a1=A1 a2=A2 z=Z n=N beta=BETA se=SE frq=FRQ p=P]\n\n",
    "  Step 2 (post-PolyFun):\n",
    "    Rscript format_polyfun_sumstats.R step=2 prefix=<out> [polyfun_out=<file>]\n",
    sep = ""
  )
  if (!is.null(msg)) quit(status = 1)
}

if (is.null(step)) usage("'step' is required (1 or 2).")
if (!step %in% c("1", "2")) usage("step must be '1' or '2'.")
if (is.null(prefix))  usage("'prefix' is required.")


# ══════════════════════════════════════════════════════════════════════════════
# STEP 1 – Allele matching & write PolyFun input
# ══════════════════════════════════════════════════════════════════════════════

if (step == "1") {

  input_file <- params[["input"]]
  ref_file   <- params[["ref"]]

  if (is.null(input_file)) usage("step=1 requires 'input' (GWAS sumstats file).")
  if (is.null(ref_file))   usage("step=1 requires 'ref' (PLINK .bim reference file).")

  # ---------- 1a. Read GWAS sumstats -----------------------------------------

  cat("[Step 1] Reading GWAS summary statistics ...\n")
  gwas <- fread(input_file, header = TRUE, data.table = FALSE)
  cat(sprintf("  → %s rows, %d columns\n", format(nrow(gwas), big.mark=","), ncol(gwas)))

  # Map columns to standard names
  required <- c("chr", "bp", "snp", "a1", "a2", "n")
  rename_list <- list()
  for (key in required) {
    src <- col_map[[key]]
    if (!src %in% names(gwas)) stop(sprintf("Column '%s' not found in input file.", src))
    if (src != toupper(key)) rename_list[[toupper(key)]] <- src
  }

  # Optional columns: Z, BETA, SE
  has_z    <- col_map[["z"]]    %in% names(gwas)
  has_beta <- col_map[["beta"]] %in% names(gwas)
  has_se   <- col_map[["se"]]   %in% names(gwas)

  if (!has_z && !(has_beta && has_se)) {
    stop("Input must have either a Z-score column or both BETA and SE columns.")
  }

  # Rename to standard names
  for (std_name in names(rename_list)) {
    names(gwas)[names(gwas) == rename_list[[std_name]]] <- std_name
  }

  # Rename Z / BETA / SE if present
  if (has_z) {
    if (col_map[["z"]] != "Z") names(gwas)[names(gwas) == col_map[["z"]]] <- "Z"
  }
  if (has_beta) {
    if (col_map[["beta"]] != "BETA") names(gwas)[names(gwas) == col_map[["beta"]]] <- "BETA"
  }
  if (has_se) {
    if (col_map[["se"]] != "SE") names(gwas)[names(gwas) == col_map[["se"]]] <- "SE"
  }
  if (col_map[["frq"]] %in% names(gwas)) {
    if (col_map[["frq"]] != "FRQ") names(gwas)[names(gwas) == col_map[["frq"]]] <- "FRQ"
  }

  # Compute Z if missing
  if (!has_z) {
    cat("  → Computing Z = BETA / SE ...\n")
    gwas$Z <- gwas$BETA / gwas$SE
  }

  # Keep only needed columns
  keep_cols <- c("CHR", "BP", "SNP", "A1", "A2", "Z", "N")
  gwas <- gwas[, intersect(keep_cols, names(gwas)), drop = FALSE]

  # ---------- 1b. Read reference BIM & extract alleles ----------------------

  cat("[Step 1] Reading reference BIM file ...\n")
  ref <- fread(ref_file, header = FALSE, data.table = FALSE)
  ref <- ref[, c(2, 5, 6)]
  names(ref) <- c("SNP", "ref_A1", "ref_A2")
  cat(sprintf("  → %s reference SNPs loaded\n", format(nrow(ref), big.mark=",")))

  # ---------- 1c. Allele matching -------------------------------------------

  cat("[Step 1] Matching alleles to reference panel ...\n")
  merged <- left_join(gwas, ref, by = "SNP")

  # SNPs that could not be matched to reference
  n_missing_ref <- sum(is.na(merged$ref_A1))
  if (n_missing_ref > 0) {
    cat(sprintf("  → %s SNPs not found in reference BIM (will be removed)\n", format(n_missing_ref, big.mark=",")))
  }

  # Same direction: GWAS A1 == ref A1  &  GWAS A2 == ref A2
  same <- merged[!is.na(merged$ref_A1) &
                 merged$A1 == merged$ref_A1 &
                 merged$A2 == merged$ref_A2, ]
  cat(sprintf("  → %s SNPs match reference in same direction\n", format(nrow(same), big.mark=",")))

  # Flipped direction: GWAS A1 == ref A2  &  GWAS A2 == ref A1  → flip Z
  diff <- merged[!is.na(merged$ref_A1) &
                 merged$A1 == merged$ref_A2 &
                 merged$A2 == merged$ref_A1, ]
  if (nrow(diff) > 0) {
    diff$Z <- -diff$Z
    cat(sprintf("  → %s SNPs match reference in flipped direction (Z sign flipped)\n", format(nrow(diff), big.mark=",")))
  }

  # Combine
  matched <- rbind(same, diff)
  cat(sprintf("  → %s SNPs with matched alleles total\n", format(nrow(matched), big.mark=",")))

  # Non-matching alleles (ambiguous or strand issues)
  n_discard <- sum(!is.na(merged$ref_A1)) - nrow(matched)
  if (n_discard > 0) {
    cat(sprintf("  → %s SNPs discarded (alleles do not match reference, e.g. strand flips or tri-allelic)\n", format(n_discard, big.mark=",")))
  }

  # Use reference alleles for output
  matched$A1 <- matched$ref_A1
  matched$A2 <- matched$ref_A2

  # ---------- 1d. Deduplicate & write outputs ------------------------------

  cat("[Step 1] Removing duplicate SNPs ...\n")
  n_before <- nrow(matched)
  matched <- matched[!duplicated(matched$SNP), ]
  cat(sprintf("  → %s duplicates removed, %s SNPs remain\n", format(n_before - nrow(matched), big.mark=","), format(nrow(matched), big.mark=",")))

  # Output 1: Full matched sumstats (CHR, BP, SNP, A1, A2, Z, N)
  out_full <- matched[, c("CHR", "BP", "SNP", "A1", "A2", "Z", "N")]
  full_path <- paste0(prefix, ".allele-match-LD.zscore.N.txt")
  fwrite(out_full, full_path, quote = FALSE, row.names = FALSE, sep = " ")
  cat(sprintf("[Step 1] Wrote: %s\n", full_path))

  # Output 2: PolyFun input (CHR, BP, A1, A2 only)
  out_polyfun <- matched[, c("CHR", "BP", "A1", "A2")]
  polyfun_path <- paste0(prefix, ".forPolyfun.txt")
  fwrite(out_polyfun, polyfun_path, quote = FALSE, row.names = FALSE, sep = " ")
  cat(sprintf("[Step 1] Wrote: %s\n", polyfun_path))

  cat("[Step 1] Done. Ready for PolyFun extract_snpvar.py.\n")
}


# ══════════════════════════════════════════════════════════════════════════════
# STEP 2 – Merge PolyFun SNPVAR back into sumstats
# ══════════════════════════════════════════════════════════════════════════════

if (step == "2") {

  polyfun_out <- params[["polyfun_out"]]
  if (is.null(polyfun_out)) {
    polyfun_out <- paste0(prefix, ".Polyfun.snps_with_var")
  }

  cat("[Step 2] Reading PolyFun output ...\n")
  if (!file.exists(polyfun_out)) {
    stop(sprintf("PolyFun output file not found: %s", polyfun_out))
  }
  snpvar <- fread(polyfun_out, header = TRUE, data.table = FALSE)
  cat(sprintf("  → %s rows loaded\n", format(nrow(snpvar), big.mark=",")))

  # PolyFun output should have CHR, BP, SNPVAR
  if (!all(c("CHR", "BP", "SNPVAR") %in% names(snpvar))) {
    stop("PolyFun output must contain columns: CHR, BP, SNPVAR")
  }
  snpvar <- snpvar[, c("CHR", "BP", "SNPVAR")]

  cat("[Step 2] Reading matched sumstats ...\n")
  sumstats_path <- paste0(prefix, ".allele-match-LD.zscore.N.txt")
  if (!file.exists(sumstats_path)) {
    stop(sprintf("Matched sumstats file not found: %s", sumstats_path))
  }
  sumstats <- fread(sumstats_path, header = TRUE, data.table = FALSE)
  cat(sprintf("  → %s rows loaded\n", format(nrow(sumstats), big.mark=",")))

  # Merge by CHR & BP (NOT by SNP ID — they may differ between GWAS and PolyFun)
  cat("[Step 2] Merging by CHR + BP ...\n")
  merged <- left_join(snpvar, sumstats, by = c("CHR", "BP"))
  merged <- merged[!is.na(merged$Z), ]
  cat(sprintf("  → %s SNPs after merge (%s lost due to missing Z)\n",
              format(nrow(merged), big.mark=","), format(nrow(snpvar) - nrow(merged), big.mark=",")))

  # Write final output
  out_path <- paste0(prefix, ".finemap_sumstats.addSNPVAR.txt")
  fwrite(merged, out_path, quote = FALSE, row.names = FALSE, sep = "\t")
  cat(sprintf("[Step 2] Wrote: %s\n", out_path))
  cat("[Step 2] Done.\n")
}


cat("All done.\n")
