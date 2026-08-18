# Code availability — DEP-EAS GWAS

Analysis code for the manuscript:

> **[Insert manuscript title here]**  
> *(add authors, journal, DOI when available)*

This repository contains the scripts used for the genome-wide association
study (GWAS) of depression (DEP) in East Asian (EAS) populations and all
downstream analyses described in the Online Methods. The folders are numbered
in the order the analyses appear in the Methods section.

## Repository structure

| Folder | Methods section | Main software |
|---|---|---|
| [`01_QC_GWAS_data/`](01_QC_GWAS_data/) | Quality control for GWAS data; Genotype imputation | PLINK v2.0, EIGENSTRAT v7.1.2 (SHAPEIT5 / Minimac4 not retained) |
| [`02_LDSC_heritability/`](02_LDSC_heritability/) | LD score regression heritability estimation | LDSC v1.0.1 |
| [`03_GWAS_statistical_analysis/`](03_GWAS_statistical_analysis/) | Statistical analysis in GWAS samples | PLINK v2.0, PLINK v1.90b6.20, locuszoomr v0.3.8 |
| [`04_CellType_enrichment/`](04_CellType_enrichment/) | Enrichment analysis (tissue & cell type) | MAGMA v1.10, LDSC v1.0.1, EWCE, FUMA (web) |
| [`05_LDSC_genetic_correlation/`](05_LDSC_genetic_correlation/) | Genome-wide genetic correlations | LDSC v1.0.1 |
| [`06_MiXeR/`](06_MiXeR/) | Polygenic overlap analysis | MiXeR v1.3 |
| [`07_MTAG/`](07_MTAG/) | Multi-Trait Analysis of GWAS | MTAG |
| [`08_Fine_mapping/`](08_Fine_mapping/) | Fine-mapping analysis | PolyFun + SuSiE, FUMA v1.6.4 SNP2GENE (web) |
| [`09_SMR/`](09_SMR/) | SMR analysis | SMR |
| [`10_Credible_gene_prioritization/`](10_Credible_gene_prioritization/) | Credible gene prioritization | MAGMA v1.10, PoPS |
| [`11_Drug_target/`](11_Drug_target/) | Drug target analyses | DGIdb v5.0 API, Open Targets |
| [`Figure/`](Figure/) | Figures (Manhattan, regional, heatmaps, forest plots, etc.) | R (qqman, locuszoomr, pheatmap, CMplot, meta, …) |

Retained run logs (which record the exact command flags) are kept in
`logs/` subfolders where available.

## Data

GWAS summary statistics: **[insert download location / DOI — e.g. Zenodo,
GWAS Catalog accession]**.

Raw genotype data contain individual-level information and are available
under controlled access (**[insert access route]**).

## Notes on provenance

- Scripts with header comment **`RECONSTRUCTED`** were rewritten from the
  Methods description because the original files/logs were not retained:
  the PLINK QC pipeline (`01_QC_GWAS_data/plink_qc.sh`), the meta-analysis
  invocation (`03_GWAS_statistical_analysis/meta_analysis.sh`), the PolyFun
  prior pipeline (`08_Fine_mapping/run_polyfun_priors.sh`), the MTAG
  10-combination wrapper (`07_MTAG/run_mtag_all_combos.sh`), the SMR scripts
  (`09_SMR/`) and the drug-target queries (`11_Drug_target/`). The commands
  marked `taken verbatim from the retained logs` reproduce the exact flags
  used in the study.
- Absolute file paths in the scripts reflect the original computing
  environment (local HPC clusters); adjust them to your setup.
- Credentials/API tokens that appeared in the original working copies have
  been removed before publication.

## License

[MIT](LICENSE) unless stated otherwise. (Change to your preferred license if
needed — e.g. GPL-3.0 if you must retain copyleft.)
