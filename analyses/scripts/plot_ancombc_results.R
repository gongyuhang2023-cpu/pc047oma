# =============================================================================
# ANCOM-BC 结果可视化
# 生成与 ALDEx2 风格一致的条形图
# =============================================================================

library(tidyverse)
library(here)

# 读取 ANCOM-BC 结果
ancombc_species <- read.csv(
  here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
             "18_daa_ancombc_top10_species.csv")
)

# 查看数据结构
head(ancombc_species)

# 数据整理
ancombc_plot_data <- ancombc_species |>
  dplyr::mutate(
    taxon_short = taxon,
    # 直接显示 FDR q-value 数值
    q_label = sprintf("q=%.3f", q_treatment_groupApcMUT_HpWT),
    # 方向标记
    direction = ifelse(lfc_treatment_groupApcMUT_HpWT < 0,
                       "Depleted in CagA+", "Enriched in CagA+")
  ) |>
  # 按 LFC 排序
  dplyr::arrange(lfc_treatment_groupApcMUT_HpWT)

# 设置因子顺序（按 LFC 排序）
ancombc_plot_data$taxon_short <- factor(
  ancombc_plot_data$taxon_short,
  levels = ancombc_plot_data$taxon_short
)

# 绘制条形图
p_ancombc <- ggplot(ancombc_plot_data,
                     aes(x = lfc_treatment_groupApcMUT_HpWT,
                         y = taxon_short,
                         fill = direction)) +
  geom_col(width = 0.7) +
  geom_vline(xintercept = 0, linetype = "solid", color = "black", linewidth = 0.5) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "gray50", linewidth = 0.3) +
  # 添加显著性标记
  geom_text(aes(x = lfc_treatment_groupApcMUT_HpWT - 0.1 * sign(lfc_treatment_groupApcMUT_HpWT),
                label = sig_label),
            hjust = ifelse(ancombc_plot_data$lfc_treatment_groupApcMUT_HpWT < 0, 1, 0),
            size = 4, fontface = "bold") +
  scale_fill_manual(values = c("Depleted in CagA+" = "#5DADE2",
                                "Enriched in CagA+" = "#E74C3C")) +
  labs(
    title = "Differentially Abundant Species (ANCOM-BC)",
    subtitle = "Core comparison: ApcMUT_HpWT vs ApcMUT_HpKO\nNote: All FDR q > 0.05, showing consistent trend",
    x = "Log Fold Change (LFC)",
    y = NULL,
    fill = "Direction",
    caption = "Dashed lines: |LFC| = 1 threshold; * q < 0.05, ** q < 0.01, *** q < 0.001 (FDR-corrected)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    axis.text.y = element_text(face = "italic", size = 10),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

# 显示图形
print(p_ancombc)

# 保存图形
ggsave(
  filename = here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
                        "daa_ancombc_lfc_barplot.png"),
  plot = p_ancombc,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

cat("\n图片已保存至: analyses/data/01_alpha_beta_diversity_analysis/daa_ancombc_lfc_barplot.png\n")
