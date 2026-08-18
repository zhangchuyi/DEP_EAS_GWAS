# 2024-11-04

# Munge features
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

nohup python /home/lilab/software/pops-master/pops.py --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt --feature_mat_prefix /home/lilab/software/pops-master/features_munged/PoPS.features.munged --num_feature_chunks 116 --magma_prefix /me4012/zcy/1.GWAS/11.ALL_ASA_MDD_CTRL/FuDan_imputation/Final_Sample_forNHB_202509/NC_revision/MAGMA_PoPS/MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD.MergePoPS-annot --control_features_path /home/lilab/software/pops-master/example/data/utils/features_jul17_control.txt --out_prefix MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD.PoPS  > MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD.PoPS.log 2>&1 &
nohup python /home/lilab/software/pops-master/pops.py --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt --feature_mat_prefix /home/lilab/software/pops-master/features_munged/PoPS.features.munged --num_feature_chunks 116 --magma_prefix /me4012/zcy/1.GWAS/11.ALL_ASA_MDD_CTRL/FuDan_imputation/Final_Sample_forNHB_202509/NC_revision/MAGMA_PoPS/MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd_Neff-SZ_INSO_BD.MergePoPS-annot --control_features_path /home/lilab/software/pops-master/example/data/utils/features_jul17_control.txt --out_prefix MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd_Neff-SZ_INSO_BD.PoPS  > MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd_Neff-SZ_INSO_BD.PoPS.log 2>&1 &
nohup python /home/lilab/software/pops-master/pops.py --gene_annot_path /home/lilab/software/pops-master/example/data/utils/gene_annot_jun10.txt --feature_mat_prefix /home/lilab/software/pops-master/features_munged/PoPS.features.munged --num_feature_chunks 116 --magma_prefix sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.MergePoPS-annot --control_features_path /home/lilab/software/pops-master/example/data/utils/features_jul17_control.txt --out_prefix  sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.PoPS >  sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.PoPS.log 2>&1 &
