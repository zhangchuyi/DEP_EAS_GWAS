# Actual mtag.py invocation for one four-trait combination (DEP + BD + ANX + Suicide).
# All 10 combinations (all_combo.txt) were run analogously via run_mtag_all_combos.sh;
# the combination with the lowest maxFDR for DEP was selected as the primary model.
# NOTE: absolute paths reflect the original computing environment.
python /home/lilab/software/mtag-master/mtag.py --sumstats sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.forMTAG.txt,bip2024_eas_no23andMe.Neff.forMTAG.txt,Anxiety_disorders_300.saige.hg19.addrsID.forMTAG.txt,Suicide.ASN.forMTAG.txt  --n_min 0.0 --incld_ambig_snps --ld_ref_panel /home/lilab/software/mtag-master/ld_ref_panel/eas_ldscores/ --out add_TPMImdd/MTAG_EAS_DEP_NCrevision_dosage-BD_ANX_Suicide --stream_stdout --force --fdr
