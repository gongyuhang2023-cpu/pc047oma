# ==============================================================================
# Next Steps 示意图 - 简洁版
# ==============================================================================

library(ggplot2)

# ------------------------------------------------------------------------------
# 创建 Next Steps 流程图
# ------------------------------------------------------------------------------

p_next_steps <- ggplot() +

  # ===== 标题 =====
  annotate("text", x = 0.5, y = 0.95,
           label = "Next Steps",
           size = 7, fontface = "bold", hjust = 0.5) +

  # ===== 三个阶段的箭头流程 =====

  # Step 1 框
  annotate("rect", xmin = 0.05, xmax = 0.30, ymin = 0.55, ymax = 0.85,
           fill = "#3498db", alpha = 0.2, color = "#3498db", linewidth = 2) +
  annotate("text", x = 0.175, y = 0.78, label = "1",
           size = 8, fontface = "bold", color = "#3498db") +
  annotate("text", x = 0.175, y = 0.68, label = "Correlate with\nImmune Phenotype",
           size = 4, fontface = "bold", hjust = 0.5, lineheight = 0.9) +
  annotate("text", x = 0.175, y = 0.58, label = "(Bioinformatics)",
           size = 3, color = "gray50", fontface = "italic") +

  # 箭头 1→2
  annotate("segment", x = 0.32, xend = 0.38, y = 0.70, yend = 0.70,
           arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
           linewidth = 2, color = "gray60") +

  # Step 2 框
  annotate("rect", xmin = 0.38, xmax = 0.63, ymin = 0.55, ymax = 0.85,
           fill = "#f39c12", alpha = 0.2, color = "#f39c12", linewidth = 2) +
  annotate("text", x = 0.505, y = 0.78, label = "2",
           size = 8, fontface = "bold", color = "#f39c12") +
  annotate("text", x = 0.505, y = 0.68, label = "Validate\nMetabolites",
           size = 4, fontface = "bold", hjust = 0.5, lineheight = 0.9) +
  annotate("text", x = 0.505, y = 0.58, label = "(SCFA, LPS)",
           size = 3, color = "gray50", fontface = "italic") +

  # 箭头 2→3
  annotate("segment", x = 0.65, xend = 0.71, y = 0.70, yend = 0.70,
           arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
           linewidth = 2, color = "gray60") +

  # Step 3 框
  annotate("rect", xmin = 0.71, xmax = 0.96, ymin = 0.55, ymax = 0.85,
           fill = "#e74c3c", alpha = 0.2, color = "#e74c3c", linewidth = 2) +
  annotate("text", x = 0.835, y = 0.78, label = "3",
           size = 8, fontface = "bold", color = "#e74c3c") +
  annotate("text", x = 0.835, y = 0.68, label = "Mechanistic\nValidation",
           size = 4, fontface = "bold", hjust = 0.5, lineheight = 0.9) +
  annotate("text", x = 0.835, y = 0.58, label = "(Epitope & Culture)",
           size = 3, color = "gray50", fontface = "italic") +

  # ===== 底部：具体内容 =====
  annotate("text", x = 0.175, y = 0.42,
           label = "• Microbiome vs CD8+ T-cell\n• Microbiome vs Tumor load",
           size = 2.8, hjust = 0.5, color = "gray30", lineheight = 1.1) +

  annotate("text", x = 0.505, y = 0.42,
           label = "• Targeted metabolomics\n• Metatranscriptomics",
           size = 2.8, hjust = 0.5, color = "gray30", lineheight = 1.1) +

  annotate("text", x = 0.835, y = 0.42,
           label = "• CagA-like epitope search\n• Driver species isolation",
           size = 2.8, hjust = 0.5, color = "gray30", lineheight = 1.1) +

  # ===== 底部标注 =====
  annotate("segment", x = 0.1, xend = 0.9, y = 0.25, yend = 0.25,
           linewidth = 0.5, color = "gray80") +

  annotate("text", x = 0.5, y = 0.18,
           label = "Goal: Link microbiome changes to persistent immune activation",
           size = 3.5, fontface = "italic", color = "gray40", hjust = 0.5) +

  # 设置

  xlim(0, 1) + ylim(0.1, 1) +
  theme_void() +
  theme(plot.margin = margin(10, 10, 10, 10))

print(p_next_steps)

# 保存
ggsave(
  filename = here::here("analyses", "data", "next_steps_diagram.png"),
  plot = p_next_steps,
  width = 10,
  height = 5,
  dpi = 300,
  bg = "white"
)

cat("Next Steps 示意图已保存: analyses/data/next_steps_diagram.png\n")
