library(RColorBrewer)
library(pheatmap)
library(gridExtra)

mag = read.csv("MAGMA_DEP_EAS_GWAS_cell_type_enrichment.wide.csv",row.names = 1)
ldsc = read.csv("LDSC_DEP_EAS_GWAS_cell_type_enrichment.wide.csv",row.names = 1)
mag = as.matrix(mag)
ldsc=as.matrix(ldsc)

# Generate the heatmaps (silent = TRUE to return objects)
p1 <- pheatmap(ldsc,
               cluster_rows = FALSE,
               cluster_cols = FALSE,
               color = colorRampPalette(brewer.pal(9, "OrRd"))(60),
               fontsize = 10,
               cellwidth = 15,
               cellheight = 15,
               legend = TRUE,
               angle_col = 45,
               legend_title = "-log10(Pvalue)",
               silent = TRUE)
p1
p2 <- pheatmap(mag,
               cluster_rows = FALSE,
               cluster_cols = FALSE,
               color = colorRampPalette(brewer.pal(9, "GnBu"))(60),
               fontsize = 10,
               cellwidth = 15,
               cellheight = 15,
               legend = TRUE,
               angle_col = 45,
               legend_title = "-log10(Pvalue)",
               silent = TRUE)
p2
# Arrange vertically
grid.arrange(p1$gtable, p2$gtable, ncol = 1, heights = c(14, 14))

