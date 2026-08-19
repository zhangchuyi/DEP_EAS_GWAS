# 05 — Enrichment analysis (tissue & cell-type)

Corresponds to the Methods section **"Enrichment analysis"**.

- Cell-type enrichment used single-nucleus RNA-seq data of human cortical
  development (709,372 nuclei, 169 samples; https://pre-postnatalcortex.cells.ucsc.edu,
  2023 Science), analysed with **MAGMA v1.10** and **LDSC v1.0.1** partitioned
  heritability.

## MAGMA/

| File | Description |
|---|---|
| `EWCE_generateCTD.R` | Builds the cell-type expression specificity matrix with the EWCE package: average expression per cell type, normalised across cell types, top 10 % most specific genes per cell type kept; writes MAGMA set annotations (`top10.txt`) and LDSC bed files. NOTE: the script keeps cell types with ≥ 100 cells (`min_cells <- 100`), while the Methods text says cell types with fewer than 50 cells were omitted — check which threshold corresponds to your final analysis. |
| `magma_gene_analysis.sh` | MAGMA gene-level analysis (flags as used in the study). |
| `magma_set_enrichment.sh` | MAGMA cell-type set enrichment against gene-level Z-scores (one run per cell-type class / developmental stage). |

## LDSC/

Partitioned-heritability cell-type enrichment, following the standard LDSC
cell-type pipeline:

| File | Description |
|---|---|
| `get_annotation_ldscores_tissue_v2.*.sh` | Intersect the top-10 % gene bed files with the 1000G Phase 3 EAS baseline annotations (all baseline categories), then compute per-chromosome annotation LD scores (1 cM windows, HapMap3 SNPs). One script per cell-type class / developmental stage. |
| `get_partitioned_h2_tissue_v2.*.sh` | Partitioned heritability regression (`--h2 ... --ref-ld-chr baseline.,<annotation>.`) with EAS regression weights excluding the MHC region. |

Dependencies: bedtools (`intersectBed`), the LDSC cell-type scripts
(`fast_match2_minimal.pl`, from https://github.com/bulik/ldsc/wiki/Cell-type-specific-analyses),
and the 1000 Genomes Phase 3 EAS baseline LD reference
(`1000G_Phase3_EAS_baselineLD_v2.2`). Absolute paths in the scripts reflect
the original computing environment — adjust to your setup.
