# 20250728

path_name="/me4012/zcy/1.GWAS/11.ALL_ASA_MDD_CTRL/FuDan_imputation/Final_Sample_forNHB_202509/cellType_LDSC"
all_snps="/home/lilab/software/ldsc/reference/1000G_Phase3_EAS_baselineLD_v2.2/all_EAS.snps"
all_annotations="/home/lilab/software/ldsc/reference/1000G_Phase3_EAS_baselineLD_v2.2"
plink_file="/home/lilab/software/ldsc/reference/1000G_Phase3_EAS_plinkfiles"
hapmap_snps="/home/lilab/software/ldsc/reference/1000G_Phase3_EAS_baselineLD_v2.2/print_snps"

cd $path_name
# for k in `cat filename.txt`
# do
k="Mean_SubCellType"    
cd ${path_name}/${k}
for f in *.bed
do
        echo $f
        intersectBed -c -a $all_snps -b $f > $f".1000genomes.intersect"
        awk '{if($5!=0) print $4}' $f".1000genomes.intersect" > $f".1000genomes.intersect.snp"
        mkdir $f"_tissue_dir"
        rm $f".1000genomes.intersect"
        cd $f"_tissue_dir"
        for j in $all_annotations/baseline.*.annot
        do
            echo $j
            file_name=`basename $j`
            perl $path_name/fast_match2_minimal.pl ../$f".1000genomes.intersect.snp" $f $j > $file_name
        done
        gzip *annot
        for i in {1..22}
        do
            ldsc.py --l2 --bfile $plink_file/1000G.EAS.QC.$i   --ld-wind-cm 1 --print-snps $hapmap_snps --annot baseline.$i.annot.gz --out baseline.$i
        done
        cd ..
        rm $f".1000genomes.intersect.snp"
done
# done
