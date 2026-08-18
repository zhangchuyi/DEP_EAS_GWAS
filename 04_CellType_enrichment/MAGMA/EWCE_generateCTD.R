library(EWCE)
library(Seurat)
name = read.table("name.txt")
region = name$V1
for(name in region){
all = readRDS(paste0("Dissection_",name,".rds"))
cluster_counts <- table(all@meta.data$supercluster_term)
min_cells <- 100
clusters_to_keep <- names(cluster_counts[cluster_counts >= min_cells])
a <- subset(all, subset = supercluster_term %in% clusters_to_keep)
ep = a@assays$RNA@data
meta = a@meta.data
meta$supercluster_term <- droplevels(meta$supercluster_term)
meta$subcluster_id <- droplevels(meta$subcluster_id)
meta = meta[,c("cell_type_ontology_term_id","tissue","development_stage","dissection","supercluster_term")]
# meta2 = meta[,c("cell_type_ontology_term_id","tissue","development_stage","dissection","supercluster_term","subcluster_id")]
meta$Cell = rownames(meta)
annotLevels <- list(level1class=meta$supercluster_term)
cellnumber = as.data.frame(table(meta$supercluster_term))
ctd <- EWCE::generate_celltype_data(exp = ep, annotLevels = annotLevels, groupName = paste0("Filter100Cellnumber_",name), savePath=getwd(),no_cores=80)
write.table(meta,paste0("meta_Filter100Cellnumber_",name,".tsv"),quote =F,row.names = F,sep = "\t")
write.table(cellnumber,paste0("Cell_number_Filter100Cellnumber_",name,".tsv"),quote =F,row.names = F,sep = "\t",col.names = F)
}

for(name in region){
	a = get(load(paste0("/home/lilab/zhangchu1/1.GWAS/MAGMA_Celltype_Enrich/Human_BrainCell_Atlas/ctd_Filter100Cellnumber_",name,".rda")))
	ep = as.data.frame(a[[1]]$mean_exp)
	ep$Gene = rownames(ep)
	ep = ep[,c(dim(ep)[2],1:(dim(ep)[2]-1))]
	write.csv(ep,paste0("/home/lilab/zhangchu1/1.GWAS/MAGMA_Celltype_Enrich/Human_BrainCell_Atlas/ctd_Filter100Cellnumber_",name,".mean_express.csv"),row.names = F,quote = F)
}


for(exp_prefix in region){
exp = read_csv(paste0("/home/lilab/zhangchu1/1.GWAS/MAGMA_Celltype_Enrich/Human_BrainCell_Atlas/ctd_Filter100Cellnumber_",exp_prefix,".mean_express.csv"))
exp <- exp %>% gather(CellType, Exp, -Gene)

gene_coordinates <- read.table("/home/lilab/zhangchu1/1.GWAS/MAGMA_Celltype_Enrich/NCBI37.3.gene.loc.extendedMHCexcluded", header=F, stringsAsFactors = F) %>%
mutate(start=ifelse(V3-100000<0,0,V3-100000),end=V4+100000,V1=as.character(V1)) %>%
select(2,start,end,1) %>%
as.tibble() %>%
rename(chr="V2", ENTREZ="V1") %>%
mutate(chr=paste0("chr",chr))

ensembl2entrez <- AnnotationDbi::toTable(org.Hs.eg.db::org.Hs.egENSEMBL2EG) %>%
  rename(Ensembl = gene_id, ENTREZ = gene_id)

exp_CT <- exp %>% rename(Lvl5=CellType, Expr_sum_mean=Exp)
dic_CT <- select(exp_CT,Lvl5) %>% unique() %>% mutate(makenames=make.names(Lvl5))
genes_to_remove <- exp_CT %>% group_by(Gene) %>% summarise(sum=sum(Expr_sum_mean)) %>% filter(sum==0)
exp_CT <- filter(exp_CT,!Gene%in%genes_to_remove$Gene)
exp_CT <- exp_CT %>% group_by(Lvl5) %>% mutate(Expr_sum_mean=Expr_sum_mean*1e6/sum(Expr_sum_mean))
exp_CT <- exp_CT %>% group_by(Gene) %>% mutate(specificity=Expr_sum_mean/sum(Expr_sum_mean))
exp_CT <- inner_join(exp_CT, ensembl2entrez, by="Gene")
exp_CT <- inner_join(exp_CT, gene_coordinates, by="ENTREZ")
n_genes <- length(unique(exp_CT$ENTREZ))
n_genes_to_keep <- (n_genes * 0.1) %>% round()
save(exp_CT, file = paste("/home/lilab/zhangchu1/1.GWAS/MAGMA_Celltype_Enrich/Human_BrainCell_Atlas/",exp_prefix,".Rdata", sep=""))

magma_top10 <- function(d,Cell_type){
    d_spe <- d %>% group_by_(Cell_type) %>% top_n(.,n_genes_to_keep,specificity)
    d_spe %>% do(write_group_magma(.,Cell_type))
}
write_group_magma  = function(df,Cell_type) {
    df <- select(df,Lvl5,Gene)
    df_name <- make.names(unique(df[1]))
    colnames(df)[2] <- df_name
    dir.create(paste0(exp_prefix,"_MAGMA/"), showWarnings = FALSE)
    select(df,2) %>% t() %>% as.data.frame() %>% rownames_to_column("Cat") %>%
    write_tsv(paste0(exp_prefix,"_MAGMA/top10.txt"),append=T)
    return(df)
}
write_group  = function(df,Cell_type) {
    df <- select(df,Lvl5,chr,start,end,Gene)
    dir.create(paste0(exp_prefix,"_LDSC/Bed"), showWarnings = FALSE,recursive = TRUE)
    write_tsv(df[-1],paste0(exp_prefix,"_LDSC/Bed/",make.names(unique(df[1])),".bed"),col_names = F)
    return(df)
}
ldsc_bedfile <- function(d,Cell_type){
    d_spe <- d %>% group_by_(Cell_type) %>% top_n(.,n_genes_to_keep,specificity)
    d_spe %>% do(write_group(.,Cell_type))
}
exp_CT %>% filter(Expr_sum_mean>1) %>% magma_top10("Lvl5")
exp_CT %>% filter(Expr_sum_mean>1) %>% ldsc_bedfile("Lvl5")
}
