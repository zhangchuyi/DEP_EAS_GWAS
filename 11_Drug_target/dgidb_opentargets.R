#!/usr/bin/env Rscript
# =============================================================================
# Drug target analyses — DGIdb v5.0 interactions + Open Targets druggability
# =============================================================================
# RECONSTRUCTED from the Methods section ("Drug target analyses"); the
# original query scripts were not retained.
#
#   - Drug-gene interactions: DGIdb v5.0 API (https://dgidb.org/api),
#     integrating DrugBank, PharmGKB, ChEMBL and Drug Target Commons.
#   - Druggability: Open Targets platform small-molecule tractability.
#     A gene was classified as druggable if it had at least one of:
#       "Structure with Ligand", "High-Quality Ligand", "High-Quality Pocket",
#       "Med-Quality Pocket", "Druggable Family" membership, or
#       "Phase 1 Clinical" status (recorded as "TRUE").
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite)
  library(data.table)
})

args   <- commandArgs(trailingOnly = TRUE)
genes  <- args[1]                            # credible risk genes (ENSEMBL IDs)
outdir <- if (length(args) > 1) args[2] else "."

gene_list <- fread(genes, header = FALSE)$V1
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

# ---------- 1. DGIdb v5.0 drug-gene interactions ----------------------------
for (g in gene_list) {
  url <- paste0("https://dgidb.org/api/v2/interactions.json?genes=", g)
  res <- tryCatch(fromJSON(url), error = function(e) NULL)
  if (is.null(res)) next
  inter <- res$matchedTerms$interactions
  if (!is.null(inter) && length(inter) > 0) {
    df <- data.table(
      gene         = g,
      drug         = inter$drugName,
      interaction  = unlist(lapply(inter$interactionTypes, function(x)
                       paste(x$interactionType, collapse = ";"))),
      sources      = unlist(lapply(inter$sources, function(x)
                       paste(x$sourceName, collapse = ";")))
    )
    fwrite(df, file.path(outdir, paste0(g, ".dgidb.tsv")), sep = "\t", quote = FALSE)
  }
}

# ---------- 2. Open Targets druggability (small molecule tractability) ------
# One GraphQL query per gene against https://api.platform.opentargets.org/api/v4/graphql
# Field of interest: tractability.smallmolecule, bucket definitions as above.
query_ot <- function(g) {
  q <- sprintf('query { target(ensemblId: "%s") {
      id approvedSymbol
      tractability {
        label modality value
      }
    } }', g)
  r <- POST("https://api.platform.opentargets.org/api/v4/graphql",
            body = toJSON(list(query = q), auto_unbox = TRUE),
            encode = "json", content_type_json())
  fromJSON(content(r, as = "text", encoding = "UTF-8"))$data$target
}

# NOTE: this snippet requires httr::POST; substitute with your HTTP client of
# choice. Only records with label == "SM" (small molecule) and value == TRUE
# for any of the qualifying buckets were considered druggable.
