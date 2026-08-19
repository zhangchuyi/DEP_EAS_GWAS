# 04 — Polygenic risk score (PRS) analysis

| File | Description |
|---|---|
| `PRS-CS.sh` | Infers posterior SNP effect estimates from the DEP-Meng-TPMI training GWAS summary statistics with PRS-CS (high-dimensional Bayesian regression with continuous shrinkage priors; https://github.com/getian107/PRScs), per chromosome 1-22. EAS LD reference panel based on UK Biobank data (provided by the PRS-CS developers, `ldblk_ukbb_eas`). Input sumstats: `sorted_meta_mdd2023diverse_EAS_TPMI-mdd.Diff-Model.I85.allele_aligned.forPRS-CS.txt` (allele-aligned to the reference, N = 87,216). Computes PRS for the Han Chinese target samples (5,221 cases / 7,317 controls) with PLINK v1.9 `--score` using the PRS-CS posterior effect estimates|
| `PRS_association.R` | Regresses case-control status on the Z-score-standardised PRS by logistic regression in R (`glm()`, `family = binomial(logit)`), including the same covariates as in the MDD-Han GWAS. The variance explained (R²) is converted to Nagelkerke pseudo-R² with the `fmsb` package and then to liability-scaled Nagelkerke pseudo-R² assuming DEP prevalence of 5 %-20 %. |

Dependencies: PRS-CS (Python), PLINK v1.9, R packages `boot`, `fmsb`, `dplyr`.
