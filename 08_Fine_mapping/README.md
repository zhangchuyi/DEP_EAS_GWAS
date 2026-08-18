# 08 — Fine-mapping analysis (PolyFun + SuSiE)

Corresponds to the Methods section **"Fine-mapping analysis"**.

Target loci: independent GWS loci from DEP-EAS GWAS and DEP-SZ-BD-INSO MTAG
(PLINK clumping, LD r² < 0.1, 500-kb window — see `../03_GWAS_statistical_analysis/`).
Reference panel: 1000 Genomes EAS ancestry.

| File | Description |
|---|---|
| `polyfun.input` | Locus list for `finemapper.py` (chr, start, end, output) — MTAG loci. |
| `format_polyfun_sumstats.R` | Stand-alone R script (arg-parsed): step 1 = allele-matching of GWAS/MTAG summary statistics against the LD reference .bim (flips Z for strand-flipped SNPs, drops ambiguous), writes PolyFun input; step 2 = merges PolyFun `SNPVAR` back by CHR+BP. |
| `polyfun_format.R` | Original interactive version of the same formatting steps (kept as the raw record). |
| `run_polyfun_priors.sh` | **Reconstructed** chain: `extract_snpvar.py` → merge → `munge_polyfun_ldsc.py` → `polyfun.py --compute-h2-L2`. |
| `polyfun.sh` | Per-locus fine-mapping with `finemapper.py` (`--method susie --max-num-causal 5`); 95 % credible sets = smallest set of SNPs with cumulative PIP > 0.95. |

Downstream: the highest-PIP SNP of each credible set was annotated with
**FUMA v1.6.4 SNP2GENE** (positional mapping within 10 kb + adult brain
cortex Hi-C from Giusti-Rodriguez et al. and PsychENCODE) via the web
platform — no local code.

Dependencies: PolyFun (https://github.com/omerwe/polyfun), SuSiE
(https://github.com/stephenslab/susieR), Python ≥3.8, R packages
`data.table` / `dplyr`.
