#!/bin/bash

mkdir -p LD_cache
mkdir -p output

while IFS=' ' read -r chr start end out; do
    python /home/lilab/software/polyfun/finemapper.py --geno Han_Chinese_MDD.QC.R2_08 --chr "$chr" --start "$start" --end "$end" --out "$out" --method susie --sumstats MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_BD_INSO.finemap_sumstats.addSNPVAR.txt --allow-missing --memory 1 --max-num-causal 5
done < polyfun.input
