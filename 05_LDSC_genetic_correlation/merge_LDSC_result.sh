# 2023-11-23

## 从log文件中提取出最后genetic correlation结果
ls *rg.log > name.txt
sed -i -e 's/_rg.log//g' name.txt

for i in `cat name.txt`
do
	awk '{if(NR == 55 || NR == 56 || NR == 57)print $0}' ${i}_rg.log | sed 's/Genetic Correlation: //g' | sed 's/Z-score: //g' | sed 's/P: //g' | sed 's/ (/,/g' | sed 's/)//g' > ${i}_rg.result
done

## 合并所有表型结果 直接paste正好就是按照name.txt文件的顺序来的
ls *_rg.result > name.txt
sed -i -e "s/_rg.result//g" name.txt
paste *_rg.result > merge_LDSC.txt
## 记得将SZ/BD/MDD的文件名按顺序加在name.txt的最后一列

## 将合并后的文件转置为正常格式
R
library(stringr)
a = read.table("merge_LDSC.txt",header = F,sep = "\t")
name = read.table("name.txt",header = F)
name = name$V1
names(a) = name
rownames(a) = c("GeneticCor","Zscore","P")
ta = as.data.frame(t(a))
sort = ta[order(ta[,3]),]
sort$Pheno = rownames(sort)
rownames(sort) = 1:dim(sort)[1]
sort[,c("GeneticCor","SE")] = str_split_fixed(sort$GeneticCor,",",2)
sort = sort[,c(4,1,2,3,5)]
write.table(sort,"/home/lilab/reference/GWAS_resource/EAS_GWAS_resource/LDSC/BipolarDisorder/merge_new_Han_Chinses_BD_LDSC.result.txt",quote = F,row.names = F,sep = "\t")
q()
n

