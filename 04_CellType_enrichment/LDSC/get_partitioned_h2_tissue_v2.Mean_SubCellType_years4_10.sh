#!/usr/bin/env bash

#Julien Bryois 5.10.2017

sumstats=$1
gwas="DEP_EAS_2026NCrevision_I85"

path_name="/home/lilab/software/ldsc/reference/"

#Downloaded on LDSC wiki
weights="1000G_Phase3_EAS_weights_hm3_no_MHC/weights.EAS.hm3_noMHC."
frq="1000G_Phase3_EAS_plinkfiles/1000G.EAS.QC."
all_annotations="1000G_Phase3_EAS_baselineLD_v2.2"

cd /me4012/zcy/1.GWAS/11.ALL_ASA_MDD_CTRL/FuDan_imputation/Final_Sample_forNHB_202509/cellType_LDSC 
k="Mean_SubCellType_years4_10"
cd /me4012/zcy/1.GWAS/11.ALL_ASA_MDD_CTRL/FuDan_imputation/Final_Sample_forNHB_202509/cellType_LDSC/${k}
for f in *_tissue_dir 
do
	echo $f
        gwas_name=`basename $sumstats | cut -d "." -f 1`
        echo $gwas_name
        cd $f
        ldsc.py  --h2 $sumstats --ref-ld-chr $path_name$all_annotations/baseline.,baseline. --w-ld-chr $path_name$weights --overlap-annot --frqfile-chr $path_name$frq --print-coefficients --out ../${gwas}_${f}.enrichment
        cd ../
done
