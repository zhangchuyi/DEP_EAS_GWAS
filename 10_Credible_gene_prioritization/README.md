# 10 — Additional approaches in credible gene prioritization

Corresponds to the Methods section **"Additional approaches in credible gene
prioritization"**. Two complementary methods, one unit score each; genes with
three or more scores (with SMR and fine-mapping) were designated credible.

| File | Description |
|---|---|
| `MAGMA.sh` | MAGMA v1.10 gene-level association (Brown's approximation of Fisher's method; LD reference: 1000 Genomes EAS panel). Gene boundaries extended 35 kb upstream / 10 kb downstream; FDR < 0.05 significant. Inputs (final versions, filtered to imputation R² > 0.8): `sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.meta` (DEP-EAS GWAS) and `MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08.txt` (MTAG DEP-SZ-BD-INSO). |
| `PoPS.sh` | PoPS polygenic priority score (feature munging, feature subset, `pops.py`), run on the MAGMA gene results of the same two R2_08 inputs (`--magma_prefix ...MergePoPS-annot`). Genes in the top 2 % of the PoPS distribution were prioritized. |

Only significant genes located within GWS loci of the DEP-EAS GWAS /
DEP-SZ-BD-INSO MTAG were considered for prioritization.
