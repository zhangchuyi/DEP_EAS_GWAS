# 2024-11-04
# PoPS — Polygenic Priority Score (https://github.com/FinucaneLab/pops)
# Genes in the top 2 % of the PoPS distribution were prioritized.

#### 1. Munge features
cd /home/lilab/software/pops-master
python munge_feature_directory.py --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt --feature_dir /home/lilab/software/pops-master/features_raw --save_prefix /home/lilab/software/pops-master/features_munged/PoPS.features.munged --max_cols 500

# subset of features
R
library(data.table)
data = fread("PoPS.features.txt",header = T, sep = "\t")
f = read.table("/home/lilab/software/pops-master/features.filter.list")
f = f$V1
sub = data[,..f]
fwrite(sub,"PoPS-filter.features.txt",sep = "\t")
q()
n
python munge_feature_directory.py --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt --feature_dir /home/lilab/software/pops-master/features_raw/filter --save_prefix /home/lilab/software/pops-master/features_munged/PoPS-filter.features.munged --max_cols 500

#### 2. Run PoPS
# --magma_prefix points to the MAGMA gene results (R2_08 final inputs, see
# MAGMA.sh) merged with the PoPS gene annotation ("MergePoPS-annot").

# DEP-EAS GWAS
python /home/lilab/software/pops-master/pops.py \
    --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt \
    --feature_mat_prefix /home/lilab/software/pops-master/features_munged/PoPS.features.munged \
    --num_feature_chunks 116 \
    --magma_prefix {path_to_work_dir}/MAGMA_PoPS/sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.MergePoPS-annot \
    --control_features_path /home/lilab/software/pops-master/example/data/utils/features_jul17_control.txt \
    --out_prefix sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.PoPS \
    > sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.PoPS.log 2>&1

# MTAG (DEP-SZ-BD-INSO)
python /home/lilab/software/pops-master/pops.py \
    --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt \
    --feature_mat_prefix /home/lilab/software/pops-master/features_munged/PoPS.features.munged \
    --num_feature_chunks 116 \
    --magma_prefix {path_to_work_dir}/MAGMA_PoPS/MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08.MergePoPS-annot \
    --control_features_path /home/lilab/software/pops-master/example/data/utils/features_jul17_control.txt \
    --out_prefix MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08.PoPS \
    > MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08.PoPS.log 2>&1
