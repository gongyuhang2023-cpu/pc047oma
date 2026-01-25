# ==============================================================================
# DAA Effect Size Visualization for PPT
# 01分析 - ALDEx2显著差异物种
# ==============================================================================

library(ggplot2)
library(dplyr)
library(here)

# 1. 从 CSV 读取数据（确保数据准确）
daa_data <- read.csv(
  here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
             "20_daa_aldex2_significant_species.csv")
)

# 按effect排序，处理FDR值（wi.eBH = 0 视为 < 0.001）
daa_data <- daa_data |>
  dplyr::rename(species = taxon, q_value = wi.eBH) |>
  dplyr::mutate(
    species = factor(species, levels = species[order(effect)]),
    direction = ifelse(effect < 0, "Depleted in CagA+", "Enriched in CagA+"),
    sig_label = dplyr::case_when(
      q_value < 0.001 ~ "***",
      q_value < 0.01 ~ "**",
      q_value < 0.05 ~ "*",
      TRUE ~ ""
    )
  )

# 2. 绘图
p_daa <- ggplot(daa_data, aes(x = effect, y = species, fill = direction)) +
  geom_col(width = 0.7, alpha = 0.85) +
  geom_vline(xintercept = 0, linetype = "solid", color = "gray30", linewidth = 0.5) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "gray50", linewidth = 0.3) +
  geom_text(aes(label = sig_label, x = effect),
            hjust = 1.1,  # 右对齐，紧贴柱子末端左侧
            vjust = 0.5,
            size = 4, color = "black") +
  scale_fill_manual(values = c("Depleted in CagA+" = "#3498db",
                                "Enriched in CagA+" = "#e74c3c")) +
  scale_x_continuous(limits = c(-2.5, 0.5), breaks = seq(-2.5, 0.5, 0.5)) +
  labs(
    title = "Differentially Abundant Species (ALDEx2)",
    subtitle = "Core comparison: ApcMUT_HpWT vs ApcMUT_HpKO",
    x = "Effect Size",
    y = NULL,
    fill = "Direction",
    caption = "Dashed lines: |effect| = 1 threshold; * q < 0.05, ** q < 0.01, *** q < 0.001 (FDR-corrected)"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.y = element_text(face = "italic", size = 11),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

print(p_daa)

# 3. 保存图片
ggsave(
  filename = here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
                        "daa_aldex2_effect_size.png"),
  plot = p_daa,
  width = 8,
  height = 5,
  dpi = 300
)

cat("图片已保存至: analyses/data/01_alpha_beta_diversity_analysis/daa_aldex2_effect_size.png\n")
