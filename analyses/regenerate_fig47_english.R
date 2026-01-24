# 快速重新生成英文版图47
# 运行方式: 在 RStudio 中打开此文件，Ctrl+Shift+Enter 运行全部

library(ggplot2)
library(patchwork)
library(dplyr)
library(here)

# 设置工作目录


# 读取已保存的数据
effect_summary <- read.csv(here::here("data", "01_alpha_beta_diversity_analysis",
                                       "48_part4_effect_summary.csv"))
pairwise_df <- read.csv(here::here("data", "01_alpha_beta_diversity_analysis",
                                    "46_part4_pairwise_comparisons.csv"))

# ========== 修改成对比较的中文标签为英文 ==========
pairwise_df$question <- dplyr::case_when(
  pairwise_df$question == "CagA效应@变异鼠" ~ "CagA effect @ApcMUT",
  pairwise_df$question == "CagA效应@野生型" ~ "CagA effect @ApcWT",
  pairwise_df$question == "Apc效应@CagA+感染" ~ "Apc effect @CagA+",
  pairwise_df$question == "Apc效应@CagA-感染" ~ "Apc effect @CagA-",
  pairwise_df$question == "感染效应@变异鼠(CagA+)" ~ "Infection @ApcMUT(CagA+)",
  pairwise_df$question == "感染效应@变异鼠(CagA-)" ~ "Infection @ApcMUT(CagA-)",
  TRUE ~ pairwise_df$question
)

# ========== 加载 TSE 对象以绘制 PCoA ==========
library(mia)
library(TreeSummarizedExperiment)

tse_full <- readRDS(here::here("data", "01_alpha_beta_diversity_analysis",
                                "tse_standard_species_full_factored.rds"))

# 提取 PCoA 坐标
pcoa_coords <- as.data.frame(reducedDim(tse_full, "PCoA_Bray_Full"))
colnames(pcoa_coords) <- c("PC1", "PC2")
pcoa_coords <- cbind(pcoa_coords, as.data.frame(colData(tse_full)))

# 特征值
eig_full <- attr(reducedDim(tse_full, "PCoA_Bray_Full"), "eig")
rel_eig_full <- eig_full / sum(eig_full[eig_full > 0])

# ========== 绘制三个子图 ==========

# 1. PCoA 图
p4_4_1 <- ggplot(pcoa_coords, aes(x = PC1, y = PC2,
                                   color = infection, shape = genotype)) +
  geom_point(size = 4, alpha = 0.8) +
  stat_ellipse(aes(group = treatment_group, linetype = genotype),
               level = 0.80, show.legend = FALSE) +
  theme_bw() +
  labs(title = "PCoA: All 6 Treatment Groups (Bray-Curtis)",
       x = paste0("PCoA 1 (", round(100 * rel_eig_full[1], 1), "%)"),
       y = paste0("PCoA 2 (", round(100 * rel_eig_full[2], 1), "%)")) +
  scale_color_brewer(palette = "Set1") +
  scale_shape_manual(values = c(16, 17))

# 2. 效应量柱状图
p4_8_1 <- ggplot(effect_summary, aes(x = Factor, y = R2_percent, fill = Analysis)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = paste0(R2_percent, "%")),
            position = position_dodge(width = 0.8), vjust = -0.5, size = 3) +
  theme_bw() +
  labs(title = "Part 4: Effect Sizes (R2) from PERMANOVA",
       x = "Factor", y = "Variance Explained (%)") +
  scale_fill_brewer(palette = "Set2") +
  ylim(0, max(effect_summary$R2_percent) * 1.2)

# 3. 成对比较图
pairwise_plot_data <- pairwise_df %>%
  mutate(neg_log_p = -log10(p_adj),
         label = paste0("R2=", R2, significance))

p4_8_2 <- ggplot(pairwise_plot_data, aes(x = reorder(question, neg_log_p),
                                          y = neg_log_p, fill = R2)) +
  geom_bar(stat = "identity") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "red") +
  geom_hline(yintercept = -log10(0.1), linetype = "dotted", color = "orange") +
  coord_flip() +
  theme_bw() +
  labs(title = "Pairwise Comparisons (FDR-corrected)",
       x = "Comparison", y = "-log10(adjusted P-value)") +
  scale_fill_gradient(low = "lightblue", high = "darkblue", name = "R2") +
  annotate("text", x = 0.5, y = -log10(0.05), label = "P=0.05", color = "red", hjust = 0)

# ========== 组合图 ==========
p4_8_combined <- (p4_4_1 | p4_8_1) / p4_8_2 +
  plot_annotation(title = "Part 4: Extended Analysis Summary (2x3 Factorial Design)")

# 显示
print(p4_8_combined)

# ========== 保存英文版 ==========
ggsave(here::here("data", "01_alpha_beta_diversity_analysis", "47_part4_summary_figure_EN.png"),
       plot = p4_8_combined, width = 14, height = 12, dpi = 300)

cat("\n✅ 英文版图47已保存: 47_part4_summary_figure_EN.png\n")
