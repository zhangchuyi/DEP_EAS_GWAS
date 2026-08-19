# 2024-03-13
# MiXeR v1.3 polygenic overlap analysis (https://github.com/precimed/mixer)
# NOTE: absolute paths reflect the original computing environment; adjust to your setup.
# NOTE: the original file-transfer (rayfile) commands have been removed before publication
#       because they contained credentials; the qc'ed csv.gz files they produced were the
#       inputs to the analyses below.

#### 1. Prepare GWAS summary statistics for MiXeR
# python_convert (sumstats.py): convert .meta to csv with Z-scores,
# then QC: remove MHC region (chr6: 26-34 Mb)

Sumstats=/home/lilab/software/mixer-master/python_convert-master/sumstats.py

name="sorted_EAS_mdd2023diverse_EAS-meta-Han_Chinese_5221mdd_7318ctrl.Diff-Model.I80"
name="sorted_EAS_mdd2023diverse_EAS-meta-Han_Chinese_5221mdd_7318ctrl.rmI70_75.Diff-Model.I70"
name="sorted_EAS_mdd2023diverse_EAS-meta-Han_Chinese_5221mdd_7318ctrl.Diff-Model.I65"
$Sumstats csv --sumstats ${name}.meta --out ${name}.csv --force --auto --head 5 --bp BP --or OR --pval P --n Neff
$Sumstats zscore --sumstats ${name}.csv | $Sumstats qc --exclude-ranges 6:26000000-34000000 --out ${name}_qc.csv --force
gzip ${name}_qc.csv

#### 2. MiXeR Univariate analysis

mkdir MiXeR_fit1 MiXeR_fit2

name="Red_blood_cell+GCST90278667"
name="Hematocrit+GCST90278662"
for i in {1..20}
do
        python3 /home/lilab/software/mixer-master/precimed/mixer.py fit1 \
                --trait1-file ${name}_qc.csv.gz \
                --out ./MiXeR_fit1/${name}.fit.rep${i} \
                --extract /home/lilab/software/mixer-master/1000G_EAS_Phase3_plink/1000G_Phase3_EAS.SameAs.EURref.prune_maf0p05_rand2M_r2p8.rep${i}.snps \
                --bim-file /home/lilab/software/mixer-master/1000G_EAS_Phase3_plink/1000G_Phase3_EAS.SameAs.EURref.@.bim \
                --ld-file /home/lilab/software/mixer-master/1000G_EAS_Phase3_plink/1000G_Phase3_EAS.SameAs.EURref.@.run4.ld \
                --lib /home/lilab/software/mixer-master/src/build/lib/libbgmg.so
        python3 /home/lilab/software/mixer-master/precimed/mixer.py test1 \
                --trait1-file ${name}_qc.csv.gz \
                --out ./MiXeR_fit1/${name}.test.rep${i} \
                --load-params-file ./MiXeR_fit1/${name}.fit.rep${i}.json \
                --bim-file /home/lilab/software/mixer-master/1000G_EAS_Phase3_plink/1000G_Phase3_EAS.SameAs.EURref.@.bim \
                --ld-file /home/lilab/software/mixer-master/1000G_EAS_Phase3_plink/1000G_Phase3_EAS.SameAs.EURref.@.run4.ld \
                --lib /home/lilab/software/mixer-master/src/build/lib/libbgmg.so
done

python3 /home/lilab/software/mixer-master/precimed/mixer_figures.py combine --json ./MiXeR_fit1/${name}.fit.rep@.json --out ./results/${name}.fit
python3 /home/lilab/software/mixer-master/precimed/mixer_figures.py one --json ./results/${name}.fit.json --out ./results/${name} --statistic mean std --ext svg

#### 3. MiXeR Bivariate (cross-trait) analysis

name1="sorted_meta_allASA_imputed_JAMA-ASA-NewSample_rmHX_GSA-all.Diff-Model.I50"
name2="Red_blood_cell+GCST90278667"
sname1="Han_Chinese_BD"
sname2="Red_Blood_Cell_counts"
refpath="/home/lilab/software/mixer-master/1000G_EAS_Phase3_plink"

name1="sorted_meta_allASA_imputed_JAMA-ASA-NewSample_rmHX_GSA-all.Diff-Model.I50"
name2="Suicide_daner_isgc_mvp_ASN_062821"
sname1="Han_Chinese_BD"
sname2="Suicide_ASN"
refpath="/home/lilab/software/mixer-master/1000G_EAS_Phase3_plink"

for i in $(seq 1 20)
do
        python3 /home/lilab/software/mixer-master/precimed/mixer.py fit2 \
                --trait1-file ${name1}_qc.csv.gz \
                --trait2-file ${name2}_qc.csv.gz \
                --trait1-params-file ./MiXeR_fit1/${name1}.fit.rep${i}.json \
                --trait2-params-file ./MiXeR_fit1/${name2}.fit.rep${i}.json \
                --out ./MiXeR_fit2/${sname1}_${sname2}.fit.rep${i} \
                --extract ${refpath}/1000G_Phase3_EAS.SameAs.EURref.prune_maf0p05_rand2M_r2p8.rep${i}.snps \
                --bim-file ${refpath}/1000G_Phase3_EAS.SameAs.EURref.@.bim \
                --ld-file ${refpath}/1000G_Phase3_EAS.SameAs.EURref.@.run4.ld \
                --lib /home/lilab/software/mixer-master/src/build/lib/libbgmg.so
        python3 /home/lilab/software/mixer-master/precimed/mixer.py test2 \
                --trait1-file ${name1}_qc.csv.gz \
                --trait2-file ${name2}_qc.csv.gz \
                --load-params-file ./MiXeR_fit2/${sname1}_${sname2}.fit.rep${i}.json \
                --out ./MiXeR_fit2/${sname1}_${sname2}.test.rep${i} \
                --bim-file ${refpath}/1000G_Phase3_EAS.SameAs.EURref.@.bim \
                --ld-file ${refpath}/1000G_Phase3_EAS.SameAs.EURref.@.run4.ld \
                --lib /home/lilab/software/mixer-master/src/build/lib/libbgmg.so
done

python3 /home/lilab/software/mixer-master/precimed/mixer_figures.py combine --json ./MiXeR_fit2/${sname1}_${sname2}.fit.rep@.json --out ./results/${sname1}_${sname2}.fit
python3 /home/lilab/software/mixer-master/precimed/mixer_figures.py combine --json ./MiXeR_fit2/${sname1}_${sname2}.test.rep@.json --out ./results/${sname1}_${sname2}.test
python3 /home/lilab/software/mixer-master/precimed/mixer_figures.py two --json ./results/${sname1}_${sname2}.fit.json --out ./results/${sname1}_${sname2}_Venn --statistic mean std
python3 /home/lilab/software/mixer-master/precimed/mixer_figures.py two --json-fit ./results/${sname1}_${sname2}.fit.json --json-test ./results/${sname1}_${sname2}.test.json --out ./results/${sname1}_${sname2} --statistic mean std --ext svg
