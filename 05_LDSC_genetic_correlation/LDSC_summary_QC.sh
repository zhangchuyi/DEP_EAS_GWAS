# name.txt: list of trait file stems (one per line), e.g. "mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd"
# Each input is sorted_<name>.Diff-Model.I${i}.meta with columns CHR BP SNP A1 A2 ... (see 03_GWAS_statistical_analysis)
for name in `cat name.txt`
do
        awk '!($1 == 6 && $2 > 25000000 && $2 < 35000000) {print $0}' sorted_$name.Diff-Model.I${i}.meta | awk '!( ($4=="A" && $5=="T") || \
                ($4=="T" && $5=="A") || \
                ($4=="G" && $5=="C") || \
                ($4=="C" && $5=="G")) {print $0}' > sorted_$name.Diff-Model.I${i}.forLDSC.txt
        munge_sumstats.py --sumstats sorted_$name.Diff-Model.I${i}.forLDSC.txt --out sorted_$name.Diff-Model.I${i}.LDSC
