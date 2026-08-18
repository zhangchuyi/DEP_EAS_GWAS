library(CMplot)
library(data.table)

a = fread("MTAG_EAS_DEP_NCrevision_dosage_add_TPMImdd-SZ_INSO_BD_trait_1.R2_08.allSNP.forManhattan.txt",header = T)
an = read.table("mtag_sig.loci",header = T)
an = an$SNP

par(mar=c(3,5,0.4,3)) 
CMplot(a, plot.type="m",col = c("grey70"),multracks = FALSE,threshold = 5e-8,
       threshold.lwd=2, threshold.col="red", amplify = F,bin.size=1e6,
       chr.den.col=NULL, signal.col=NULL,
       highlight = an,highlight.cex = 1,highlight.pch = 18,highlight.col = "#A31D1D",
       cex = 0.5,dpi=300,file.output=F,verbose=TRUE,
       points.alpha=100)
