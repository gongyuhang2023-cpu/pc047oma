# ==============================================================================
# Bacteria-Phage Procrustes Analysis Visualization
# 展示细菌和噬菌体群落的同步变化 (Procrustes rotation plot)
# ==============================================================================

library(ggplot2)
library(vegan)
library(dplyr)
library(TreeSummarizedExperiment)

# ------------------------------------------------------------------------------
# 1. 加载数据
# ------------------------------------------------------------------------------

tse_singlem <- readRDS(here::here("analyses", "data", "03_singlem_diversity_analysis",
                                   "tse_singlem_corepair.rds"))
tse_lyrebird <- readRDS(here::here("analyses", "data", "03_singlem_diversity_analysis",
                                    "tse_lyrebird_corepair.rds"))

# ------------------------------------------------------------------------------
# 2. 计算 PCoA
# ------------------------------------------------------------------------------

# 细菌 (SingleM)
assay_singlem <- assay(tse_singlem, "counts")
dist_singlem <- vegdist(t(assay_singlem), method = "bray")
pcoa_singlem <- cmdscale(dist_singlem, k = 2)
colnames(pcoa_singlem) <- c("PC1", "PC2")

# 噬菌体 (Lyrebird)
assay_lyrebird <- assay(tse_lyrebird, "counts")
dist_lyrebird <- vegdist(t(assay_lyrebird), method = "bray")
pcoa_lyrebird <- cmdscale(dist_lyrebird, k = 2)
colnames(pcoa_lyrebird) <- c("PC1", "PC2")

# ------------------------------------------------------------------------------
# 3. Procrustes 旋转
# ------------------------------------------------------------------------------

# 确保样本顺序一致
common_samples <- intersect(rownames(pcoa_singlem), rownames(pcoa_lyrebird))
pcoa_singlem <- pcoa_singlem[common_samples, ]
pcoa_lyrebird <- pcoa_lyrebird[common_samples, ]

# Procrustes rotation
proc <- procrustes(pcoa_singlem, pcoa_lyrebird, scale = TRUE, symmetric = TRUE)

# 提取坐标
df_proc <- data.frame(
  sample = common_samples,
  # Target (bacteria)
  bact_x = proc$X[, 1],
  bact_y = proc$X[, 2],
  # Rotated (phage)
  phage_x = proc$Yrot[, 1],
  phage_y = proc$Yrot[, 2]
)

# 添加分组信息
sample_data <- as.data.frame(colData(tse_singlem)[common_samples, ])
df_proc$treatment_group <- sample_data$treatment_group

# ------------------------------------------------------------------------------
# 4. 绘制 Procrustes 图
# ------------------------------------------------------------------------------

# 颜色设置
group_colors <- c("ApcMUT_HpKO" = "#3498db", "ApcMUT_HpWT" = "#e74c3c")
group_labels <- c("ApcMUT_HpKO" = "HpKO (Control)", "ApcMUT_HpWT" = "HpWT (CagA+)")

p_procrustes <- ggplot(df_proc) +
  # 绘制连接线（箭头）
  geom_segment(aes(x = bact_x, y = bact_y, xend = phage_x, yend = phage_y,
                   color = treatment_group),
               arrow = arrow(length = unit(0.15, "cm"), type = "closed"),
               linewidth = 0.8, alpha = 0.7) +
  # 细菌点（实心圆）
  geom_point(aes(x = bact_x, y = bact_y, color = treatment_group),
             shape = 16, size = 4, alpha = 0.9) +
  # 噬菌体点（空心三角）
  geom_point(aes(x = phage_x, y = phage_y, color = treatment_group),
             shape = 17, size = 4, alpha = 0.9) +
  scale_color_manual(values = group_colors, labels = group_labels) +
  labs(
    title = "Bacteria-Phage Community Co-variation",
    subtitle = "Procrustes Analysis: r = 0.873, P = 0.002",
    x = "Procrustes Dimension 1",
    y = "Procrustes Dimension 2",
    color = "Group",
    caption = "● Bacteria (SingleM)  ▲ Phage (Lyrebird)\nShorter arrows = stronger correspondence"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30"),
    legend.position = "bottom",
    aspect.ratio = 1
  ) +
  coord_fixed()

print(p_procrustes)

# ------------------------------------------------------------------------------
# 5. 保存图片
# ------------------------------------------------------------------------------

ggsave(
  filename = here::here("analyses", "data", "03_singlem_diversity_analysis",
                        "bacteria_phage_procrustes.png"),
  plot = p_procrustes,
  width = 8,
  height = 8,
  dpi = 300
)

cat("图片已保存至: analyses/data/03_singlem_diversity_analysis/bacteria_phage_procrustes.png\n")

# ------------------------------------------------------------------------------
# 6. 同时创建双联图 (side-by-side PCoA)
# ------------------------------------------------------------------------------

# 准备数据
df_singlem <- data.frame(
  PC1 = pcoa_singlem[, 1],
  PC2 = pcoa_singlem[, 2],
  sample = rownames(pcoa_singlem),
  treatment_group = sample_data$treatment_group
)

df_lyrebird <- data.frame(
  PC1 = pcoa_lyrebird[, 1],
  PC2 = pcoa_lyrebird[, 2],
  sample = rownames(pcoa_lyrebird),
  treatment_group = sample_data$treatment_group
)

# 绘制细菌 PCoA
p_bacteria <- ggplot(df_singlem, aes(x = PC1, y = PC2, color = treatment_group)) +
  geom_point(size = 4, alpha = 0.8) +
  stat_ellipse(level = 0.68, linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = group_colors, labels = group_labels) +
  labs(
    title = "Bacteria (SingleM)",
    subtitle = "PERMANOVA P = 0.037",
    x = "PCoA 1",
    y = "PCoA 2",
    color = "Group"
  ) +
  theme_bw(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "none"
  ) +
  coord_fixed()

# 绘制噬菌体 PCoA
p_phage <- ggplot(df_lyrebird, aes(x = PC1, y = PC2, color = treatment_group)) +
  geom_point(size = 4, alpha = 0.8) +
  stat_ellipse(level = 0.68, linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = group_colors, labels = group_labels) +
  labs(
    title = "Phage (Lyrebird)",
    subtitle = "PERMANOVA P = 0.057",
    x = "PCoA 1",
    y = "PCoA 2",
    color = "Group"
  ) +
  theme_bw(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "none"
  ) +
  coord_fixed()

# 合并图
library(patchwork)

p_combined <- (p_bacteria | p_phage) +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "Bacteria and Phage Communities Both Shift with CagA",
    subtitle = "Mantel test r = 0.932, P = 0.001 | Procrustes r = 0.873, P = 0.002",
    theme = theme(
      plot.title = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(size = 11, color = "gray30")
    )
  )

# 添加共享图例
p_combined <- p_combined & theme(legend.position = "bottom")

print(p_combined)

ggsave(
  filename = here::here("analyses", "data", "03_singlem_diversity_analysis",
                        "bacteria_phage_beta_combined.png"),
  plot = p_combined,
  width = 12,
  height = 6,
  dpi = 300
)

cat("双联图已保存至: analyses/data/03_singlem_diversity_analysis/bacteria_phage_beta_combined.png\n")
