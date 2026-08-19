# 2025-07-03

library(dplyr)
library(data.table)
ref = fread("Han_Chinese_MDD.QC.R2_08.bim")
ref = ref[,c(2,5,6)]
names(ref)[1] = "SNP"

name = read.table("{path_to_work_dir}/compare_Other_traits/MTAG/name.txt",header = F)
for(i in name){
    a = fread(paste0(i,".zscore.N.txt"),header = T)
    a = left_join(a,ref)
    same = subset(a,A1 == V5 & A2 == V6)
    diff = subset(a,A1 == V6 & A2 == V5)
    diff$Z = -diff$Z
    a = rbind(same,diff)
    a = a[,c("CHR","BP","SNP","V5","V6","Z","N")]
    names(a)[4:5] = c("A1","A2")
    a = a[!duplicated(a[,3]),]
    sub = a[,c(1,2,4,5)]
    fwrite(a,paste0(i,".allele-match-LD.zscore.N.txt"),quote = F,row.names = F,sep = " ")
    fwrite(sub,paste0(i,".forPolyfun.txt"),quote = F,row.names = F,sep = " ")
}

conda activate polyfun
# for i in `cat {path_to_work_dir}/compare_Other_traits/MTAG/name.txt`; do  python /home/lilab/software/polyfun/extract_snpvar.py --sumstats ${i}.forPolyfun.txt --allow-missing --out ${i}.Polyfun.snps_with_var; done

file = read.table("{path_to_work_dir}/compare_Other_traits/MTAG/name.txt",header = F)

library(dplyr)
library(data.table)
file = name$V1
for(name in file){
a = fread(paste0(name,".Polyfun.snps_with_var"),header = T)
a = a[,c("CHR","BP","SNPVAR")] 
b = fread(paste0(name,".allele-match-LD.zscore.N.txt"),header = T)
m = left_join(a,b)
m = m[!is.na(m$Z),]
fwrite(m,paste0(name,".finemap_sumstats.addSNPVAR.txt"),quote=F, row.names=F, sep="\t")
}
