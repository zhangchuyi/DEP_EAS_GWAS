# =============================================================================
# PRS association in the Han Chinese target samples
# =============================================================================
# Case-control status is regressed on the Z-score-standardised PRS by logistic 
# regression (R glm, family = binomial(logit)) with the same covariates as in
# the MDD-Han GWAS. R2 is converted to Nagelkerke pseudo-R2 (fmsb) and then to 
# liability-scaled Nagelkerke pseudo-R2, assuming DEP prevalence of 5-20%.
# =============================================================================

## PRS association
library(boot)
library(fmsb)
library(dplyr)
targetGWAS_path="/path/to/file"
c = read.table(paste0(targetGWAS_path,"MDD-Han.covar.SEX.sigPC.txt"),header = T)
p = read.table(paste0(targetGWAS_path,"MDD-Han.sample.list"),header = F)
p = p[,c(1,2,6)]
names(p) = c("FID","IID","P")
cp = left_join(p,c)
cp$P = cp$P - 1
head(cp)

prs.result <- NULL
prev = c(0.05,0.1,0.15,0.2)

for(K in prev){
        ncase = 5221
	nctrl = 7317
	nt = ncase+nctrl
        P = ncase/(ncase+nctrl)
        thd = -qnorm(K,0,1)
        zv = dnorm(thd)
        mv = zv/K

        theta = mv*(P-K)/(1-K)*(mv*(P-K)/(1-K)-thd)
        cv = K*(1-K)/zv^2*K*(1-K)/(P*(1-P))

        null.model = glm(P~., data=cp[,!colnames(cp)%in%c("FID","IID")], family=binomial(logit))
        null.R2 = as.numeric(NagelkerkeR2(null.model)$R2)

	name="Final_Sample_MDD_Han-predict-by-DEP-Meng-TPMI"
	prs <- read.table(paste0(name,".profile"), header=T)
        prs$z = (prs$SCORE-mean(prs$SCORE))/sd(prs$SCORE)
        prs$SCORE = prs$z ## PRS rawScore Standardization
        pheno.prs <- merge(cp, prs[,c("FID","IID","SCORE")], by=c("FID", "IID"))
        pheno.prs = pheno.prs[,c(1,2,3,dim(pheno.prs)[2],4:(dim(pheno.prs)[2]-1))]
        model = glm(P~., data=pheno.prs[,!colnames(pheno.prs)%in%c("FID","IID")], family=binomial(logit))
        model.R2 = as.numeric(NagelkerkeR2(model)$R2) ## generate NagelkerkeR2
        prs.r2 <- model.R2-null.R2
        R2 = prs.r2*cv/(1 + prs.r2*theta*cv) ## liability transformation
        prs.coef <- summary(model)$coef["SCORE",]
        prs.beta <- as.numeric(prs.coef[1])
        prs.se <- as.numeric(prs.coef[2])
        prs.z <-  as.numeric(prs.coef[3])
        prs.p <- as.numeric(prs.coef[4])
        prs.result <- rbind(prs.result, data.frame(Prev = K,R2=R2, P=prs.p, BETA=prs.beta, Zscore = prs.z, SE=prs.se))
        write.table(prs.result,paste0(name,".liability.NagelkerkeR2.PRS.result"),quote = F,row.names = F)
}
