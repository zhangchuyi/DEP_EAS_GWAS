library(qqman)
clinical = read.table("sorted_meta_mdd2023diverse_EAS_clinicalMD_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.allSNP.forManhattan.txt",header = T)
depress = read.table("sorted_meta_mdd2023diverse_EAS_Neff-ourHan_l-r_dosage_allCovar-TPMI_mdd.Diff-Model.I85.R2_08.allSNP.forManhattan.txt",header = T)
an = read.table("highlight.txt",header = T)
an = an$SNP

par(mfrow=c(2,1))
par(mar=c(1,5,1,3))

layout(matrix(1:2, ncol = 1), heights = c(15, 15))

# mirrored

manhattan(depress,ylim=c(0,10),font.axis=2,
          cex.axis=1,
	  highlight = an,
          las=1,font=5,suggestiveline = F,xlab="",xaxt="n",
          col = c("#423D77","#468C8D"))

par(mar=c(3,5,0.4,3)) 
manhattan(clinical,ylim=c(10,0),
          font.axis=2,
          cex.axis=1,las=1,font = 5,
          highlight = an,
          suggestiveline = F,
          col = c("#999999","#CC6600"))
