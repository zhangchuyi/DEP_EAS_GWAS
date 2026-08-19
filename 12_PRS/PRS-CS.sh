#!/usr/bin/env bash
# =============================================================================
# PRS-CS — polygenic risk score weights (Bayesian regression with continuous
# shrinkage priors)
# =============================================================================
# As used in the study: posterior SNP effect estimates are inferred from the
# DEP-Meng-TPMI training GWAS summary statistics; the EAS LD reference panel
# (based on UK Biobank data) was provided by the PRS-CS developers
# (https://github.com/getian107/PRScs).
# =============================================================================

PRSCS=/home/lilab/software/PRScs/PRScs.py
REF_DIR=/home/lilab/software/PRScsx/LD_file/UKbiobank/ldblk_ukbb_eas
BIM_PREFIX={path_to_work_dir}/Merge_FuDan_6021MDD_7318ctrl.indqc.snpqc.hg38.R2_03.snpqc.rmUnmap.rm-misCHR.rmDup.hg19
SST_FILE=sorted_meta_mdd2023diverse_EAS_TPMI-mdd.Diff-Model.I85.allele_aligned.forPRS-CS.txt
OUT_DIR={path_to_project}/compare_EAS_depression/PRS-CS/meta_DEP-Meng_TPMI-predict-Han_Chinese_DEP.PRS-CS

for i in $(seq 1 22); do
    python ${PRSCS} \
        --ref_dir=${REF_DIR} \
        --bim_prefix=${BIM_PREFIX} \
        --sst_file=${SST_FILE} \
        --n_gwas=87216 \
        --chr ${i} \
        --out_dir=${OUT_DIR}
done
