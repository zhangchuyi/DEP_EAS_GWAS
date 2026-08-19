# 12 — Drug target analyses

Corresponds to the Methods section **"Drug target analyses"**.

| File | Description |
|---|---|
| `Opentargets_API.R` | Queries the Open Targets GraphQL API (https://api.platform.opentargets.org/api/v4/graphql) for the small-molecule tractability of the credible risk genes (label / modality / value) and writes `tractability.tsv`. Input: `credible_gene.list` with a header row and an `ensembl` column (ENSEMBL gene IDs). Genes with at least one of "Structure with Ligand", "High-Quality Ligand", "High-Quality Pocket", "Med-Quality Pocket" or "Druggable Family" membership were classified as druggable. |

Dependencies: R packages `httr`, `jsonlite`, `dplyr`.
