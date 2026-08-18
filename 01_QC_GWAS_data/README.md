# 01 — Quality control for GWAS data

Corresponds to the Methods sections **"Quality control for GWAS data"** and
**"Genotype imputation"**.

| File | Description |
|---|---|
| `plink_qc.sh` | Sample- and variant-level QC with PLINK v1.9 (sex check, missingness, heterozygosity, IBD, PCA outliers, call rate, MAF, HWE, differential missingness). **Reconstructed from the Methods description** — the original run logs were not retained; edit paths/thresholds to match your data. |
| `imputation.sh` | Genotype imputation: SHAPEIT5 prephasing + Minimac4 with the PGGHan2 (N = 20,823) Han Chinese reference panel, then post-imputation filtering (R² > 0.8, MAF > 1 %, call rate > 95 %, HWE P > 1×10⁻⁵ in controls). **Reconstructed from the Methods description**. |
| `eigstrat_pca.sh` | EIGENSTRAT v7.1.2 PCA wrapper (`convertf` + `smartpca.perl`, 20 PCs, `numoutlieriter 0`). |
| `params_NAME.txt` | `convertf` parameter file; copy to `params_<name>.txt` and replace `NAME` with your fileset stem. |

## Workflow

1. Run `plink_qc.sh` step by step (each step's removals were applied
   sequentially in the study).
2. Run EIGENSTRAT PCA on the LD-pruned set (186,199 SNPs,
   `--indep-pairwise 50 5 0.2`, high-LD regions excluded), inspect the
   PC1-vs-PC2 plot and remove visual outliers.
3. Imputation (`imputation.sh`): prephasing with **SHAPEIT5**, imputation with
   **Minimac4** using the **PGGHan2** (N=20,823) Han Chinese reference panel.
   Post-imputation filters: R² > 0.8, MAF > 1 %, call rate > 95 %,
   HWE P > 1×10⁻⁵ in controls → "MDD-Han GWAS" dataset (5,737,278 SNPs).

## Dependencies

- PLINK 1.9 (https://www.cog-genomics.org/plink/) and PLINK 2.0 (for the INFO/R² filter)
- EIGENSTRAT v7.1.2 (https://github.com/DReichLab/EIG)
- SHAPEIT5 (https://github.com/odelaneau/shapeit5), Minimac4 (https://github.com/statgen/Minimac4)
- bcftools + tabix (https://samtools.github.io/bcftools/)
- PGGHan2 reference panel (Han Chinese, N = 20,823; phased haplotypes in VCF/BCF)
- `high-LD-regions.txt`: regions of extensive high LD from Anderson et al.
  (Nat Protoc. 2010;5:1564-73)
