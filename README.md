# Code availability — DEP-EAS GWAS

Analysis code for the manuscript:

This repository contains the scripts used for the genome-wide association
study (GWAS) of depression (DEP) in East Asian (EAS) populations and all
downstream analyses described in the Online Methods. The folders are numbered
in the order the analyses appear in the Methods section.

## Repository structure

| Folder | Methods section | Main software |
|---|---|---|
| [`01_QC_GWAS_data/`](01_QC_GWAS_data/) | Quality control for GWAS data; Genotype imputation | PLINK v1.9, EIGENSTRAT v7.1.2, SHAPEIT5, Minimac4 |
| [`02_LDSC_heritability/`](02_LDSC_heritability/) | LD score regression heritability estimation | LDSC v1.0.1 |
| [`03_GWAS_statistical_analysis/`](03_GWAS_statistical_analysis/) | Statistical analysis in GWAS samples | PLINK v2.0 (dosage-based association), PLINK v1.9 (meta-analysis, clumping), locuszoomr v0.3.8 |
| [`04_CellType_enrichment/`](04_CellType_enrichment/) | Enrichment analysis | MAGMA v1.10, LDSC v1.0.1, EWCE |
| [`05_LDSC_genetic_correlation/`](05_LDSC_genetic_correlation/) | Genome-wide genetic correlations | LDSC v1.0.1 |
| [`06_MiXeR/`](06_MiXeR/) | Polygenic overlap analysis | MiXeR v1.3 |
| [`07_MTAG/`](07_MTAG/) | Multi-Trait Analysis of GWAS | MTAG |
| [`08_Fine_mapping/`](08_Fine_mapping/) | Fine-mapping analysis | PolyFun + SuSiE |
| [`09_SMR/`](09_SMR/) | SMR analysis | SMR |
| [`10_Credible_gene_prioritization/`](10_Credible_gene_prioritization/) | Credible gene prioritization | MAGMA v1.10, PoPS |
| [`11_Drug_target/`](11_Drug_target/) | Drug target analyses | Open Targets |
| [`Figure/`](Figure/) | Figures (Manhattan, regional, heatmaps, forest plots, etc.) | R (qqman, locuszoomr, pheatmap, CMplot, meta, …) |

## Notes on provenance

- Scripts with header comment **`RECONSTRUCTED`** were rewritten from the
  Methods description because the original files/logs were not retained:
  the PLINK QC pipeline (`01_QC_GWAS_data/plink_qc.sh`), the imputation
  pipeline (`01_QC_GWAS_data/imputation.sh`), the meta-analysis
  invocation (`03_GWAS_statistical_analysis/meta_analysis.sh`), the PolyFun
  prior pipeline (`08_Fine_mapping/run_polyfun_priors.sh`), the MTAG
  10-combination wrapper (`07_MTAG/run_mtag_all_combos.sh`) and the SMR
  scripts (`09_SMR/`). The commands
  marked `taken verbatim from the retained logs` reproduce the exact flags
  used in the study. The DGIdb drug-gene interaction queries have no
  retained script (`11_Drug_target/`).
- Absolute file paths in the scripts reflect the original computing
  environment (local HPC clusters); adjust them to your setup.

## License

[MIT](LICENSE) unless stated otherwise. (Change to your preferred license if
needed — e.g. GPL-3.0 if you must retain copyleft.)
