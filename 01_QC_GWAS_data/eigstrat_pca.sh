name="NAME"
convertf -p params_NAME.txt
perl smartpca.perl -i ${name}.geno -a ${name}.snp -b ${name}.ind -k 20 -o ${name}.pca -p ${name}.plot -e ${name}.eval -l ${name}.log -m 0
