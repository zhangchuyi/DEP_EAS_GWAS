df = read.table("MTAG_each_trait.forPlot.credibleGene.loci.txt",header = T)
# assume df is your data.frame with columns: SNP, trait, OR, se, replicated
attach(df)
library(ggplot2)
library(grid)   # for unit()

# Make sure Trait is a factor in the right order:
df$Trait <- factor(
  df$Trait,
  levels = c("MTAG", "DEP", "SZ", "BD", "INSO")
)
# Order SNPs by chromosome (1-22) and base-pair position,
# then reverse so chr1 appears at the top and chr22 at the bottom:
snp_order <- df[order(df$CHR, df$BP), ]
df$SNP <- factor(df$SNP, levels = rev(unique(snp_order$SNP)))

ggplot(df, aes(x = OR, y = SNP, color = Trait)) +
  geom_point(aes(shape = Significant), size = 3) +
  geom_errorbarh(aes(
    xmin = OR - 1.96 * se,
    xmax = OR + 1.96 * se
  ),
  height = 0,
  alpha = 0.9
  ) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  facet_wrap(~ Trait, scales = "free_x", nrow = 1) +
  scale_color_manual(values = c(
    MTAG       = "#479ad6",
    DEP = "#812f34",
    SZ         = "#cf176e",
    BD         = "#f6bd39",
    INSO    = "#4b5029"
  )) +
  scale_shape_manual(values = c(`Yes` = 16, `No` = 1)) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major    = element_blank(),
    panel.grid.minor    = element_blank(),
    panel.border        = element_rect(color = "black", fill = NA),
    strip.text          = element_text(face = "bold"),
    axis.title.y        = element_blank(),
    axis.ticks          = element_line(color = "black"),
    axis.ticks.length   = unit(0.15, "cm")
  ) +
  labs(
    x     = "Risk allele OR",
    color = "Trait",
    shape = "Significant"
  )
