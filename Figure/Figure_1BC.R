# if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
# BiocManager::install("ensembldb")
# BiocManager::install("EnsDb.Hsapiens.v75")
# install.packages("locuszoomr")

# token was generated from https://ldlink.nih.gov/?tab=apiaccess
# NOTE: The original API token has been removed before publication;
# generate your own token at https://ldlink.nih.gov/?tab=apiaccess and replace "YOUR_LDlink_TOKEN" below.

library("EnsDb.Hsapiens.v75")
library("locuszoomr")
library(data.table)
library(rtracklayer)

recomb.hg19 <- import.bw("/home/lilab/software/locuszoomr/hapMapRelease24CombinedRecombMap.bw")
# download from https://hgdownload.soe.ucsc.edu/gbdb/hg19/decode/

a = fread("sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.meta",header = T)
i="rs12638263"
pdf("Figure1B.pdf")
if (require(EnsDb.Hsapiens.v75)){
  loc <- locus(data = a,
             chrom = "CHR", pos = "BP", p = "P",
             ens_db = "EnsDb.Hsapiens.v75",
             index_snp = i, flank= 350000
  )
  loc <- link_LD(loc, pop=c("CHS","JPT","CHB"), token = "YOUR_LDlink_TOKEN")
  loc <- link_recomb(loc, recomb = recomb.hg19)
  }
locus_plot(loc,
           labels = c("index",i))
dev.off()

a = fread("sorted_meta_mdd2023diverse_EAS_clinicalMD_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.meta",header = T)
i="rs76457494"
pdf("Figure1C.pdf")
if (require(EnsDb.Hsapiens.v75)){
  loc <- locus(data = a,
             chrom = "CHR", pos = "BP", p = "P",
             ens_db = "EnsDb.Hsapiens.v75",
             index_snp = i, flank= 350000
  )
  loc <- link_LD(loc, pop=c("CHS","JPT","CHB"), token = "YOUR_LDlink_TOKEN")
  loc <- link_recomb(loc, recomb = recomb.hg19)
  }
locus_plot(loc,
           labels = c("index",i))
dev.off()

####### Forest Plot ########
library(meta)
or <- c(1.1185,1.07983,1.054242)
se <- c(0.0394420351894339,0.016,0.0195999)

logor <- log(or)
or.fem <- metagen(logor,se,sm = "OR",fixed = T,studlab=c("MDD-Han","DEP-Meng","MDD-TPMI"))
or.fem
forest(or.fem)

library(meta)
or <- c(1.0945,1.1034,1.076634)
se <- c(0.0378950809133424,0.027,0.0181874)

logor <- log(or)
or.fem <- metagen(logor,se,sm = "OR",fixed = T,studlab=c("MDD-Han","DEP-Meng","MDD-TPMI"))
or.fem
forest(or.fem)
