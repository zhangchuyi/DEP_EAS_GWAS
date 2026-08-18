library("ggplot2")
library("dplyr")
library("scales")
library("forestplot")

a = read.table("LDSC_for_plot_DEP_EAS_GWAS.txt",header = T,sep = "\t")

######################## 点状图 #####################
a <- a %>%
  mutate(FDR_value_group = factor(case_when(
    FDR < 5e-5 ~ "FDR < 5e-5",
    FDR < 5e-3 ~ "FDR < 5e-3",
    FDR < 1e-2 ~ "FDR < 5e-2",
    TRUE ~ "FDR < 0.1",
  ), levels = c("FDR < 5e-5", "FDR < 5e-3", "FDR < 5e-2", "FDR < 0.1"), ordered = TRUE))

# 定义颜色映射

fdr_value_colors <- c("FDR < 5e-5" = "darkred",
                    "FDR < 5e-3" = "orange",
                    "FDR < 5e-2" = "darkgreen",
                    "FDR < 0.1" = "grey")


# 绘制点状图

ggplot(a, aes(x = reorder(Phenotype, GeneticCor), y = GeneticCor, ymin = lower_95_CI, ymax = upper_95_CI, color = FDR_range)) +
  geom_pointrange(size=0.5) +
  scale_color_manual(values = fdr_value_colors,
                     breaks = c("FDR < 5e-5", "FDR < 5e-3","FDR < 5e-2", "FDR < 0.1"), #### 指定图例顺序
                     guide = guide_legend(override.aes = list(shape = 16))) +
  coord_flip() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +  # 添加竖直虚线
  scale_y_continuous(limits = c(-1.5, 1.5), breaks = c(-1, -0.5, 0, 0.5, 1)) +
  labs(
    x = "Phenotype",
    y = expression(paste(Genetic~Correlation," (",r[g],")")),
    color = "FDR"
  ) +
  theme_minimal()+
  theme(panel.grid = element_blank(),  # 去除网格线
        panel.border = element_rect(color = "black", fill = NA),
        axis.text.x = element_text(color = "black"), # 设置x轴文字颜色为纯黑色
        axis.text.y = element_text(color = "black"), # 设置x轴文字颜色为纯黑色
        axis.ticks = element_line(color = "black"),  # 添加坐标轴刻度线
        axis.ticks.length = unit(0.15, "cm")    # 设置刻度线长度
  )  # 添加外侧框线


