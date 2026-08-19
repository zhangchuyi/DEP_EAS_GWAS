# 10 — SMR analysis

Corresponds to the Methods section **"SMR analysis"**.

SMR (summary-data-based Mendelian randomization, https://yanglab.westlake.edu.cn/software/smr/)
was used to pinpoint potentially functional genes for DEP in EAS populations,
with two analyses:

- **DEP-EAS GWAS** and **DEP-SZ-BD-INSO MTAG** summary statistics
- **cortex eQTL resource**: two EAS brain-cortex eQTL datasets — Chen et al.
  (N=217) and MetaBrain (N=208) — combined by standard-error-weighted
  Z-score meta-analysis (`metal.txt`)
- putatively causal SNPs from fine-mapping (95 % credible sets) as
  instrumental QTLs, tested against all probes within ±2 Mb
  (`--extract-target-snp-probe`)
- EAS LD reference panel; HEIDI test to distinguish true cis-regulatory
  effects from linkage
- dual thresholds: FDR_SMR < 0.05 and P_HEIDI > 0.01
