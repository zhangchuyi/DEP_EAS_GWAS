# 10 — Additional approaches in credible gene prioritization

Corresponds to the Methods section **"Additional approaches in credible gene
prioritization"**. Two complementary methods, one unit score each; genes with
three or more scores (with SMR and fine-mapping) were designated credible.

| File | Description |
|---|---|
| `MAGMA.sh` | MAGMA v1.10 gene-level association (Brown's approximation of Fisher's method; the original snippet shows the EUR reference path — the retained run logs in `logs/` confirm the actual analysis used the **1000 Genomes EAS** reference `g1000_eas`; the general command template is in `../04_CellType_enrichment/MAGMA/magma_gene_analysis.sh`). Gene boundaries extended 35 kb upstream / 10 kb downstream; FDR < 0.05 significant. |
| `PoPS.sh` | PoPS polygenic priority score (feature munging, feature subset, `pops.py`). Genes in the top 2 % of the PoPS distribution were prioritized. |
| `logs/` | Retained MAGMA run logs (gene analysis for DEP-EAS I85 meta and MTAG DEP-SZ-BD-INSO). |

Only significant genes located within GWS loci of the DEP-EAS GWAS /
DEP-SZ-BD-INSO MTAG were considered for prioritization.
