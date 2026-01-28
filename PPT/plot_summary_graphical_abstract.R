# ==============================================================================
# PC047 Graphical Abstract - Summary Figure
# 整合所有分析发现和后续计划的总结图
# ==============================================================================

library(ggplot2)
library(patchwork)
library(grid)
library(gridExtra)

# ------------------------------------------------------------------------------
# 创建总结图
# ------------------------------------------------------------------------------

# 使用 ggplot2 创建一个信息图风格的总结

# 1. 主标题区域
p_title <- ggplot() +
 annotate("text", x = 0.5, y = 0.7,
          label = "CagA Reshapes Gut Microbiome Architecture",
          size = 8, fontface = "bold", hjust = 0.5) +
 annotate("text", x = 0.5, y = 0.3,
          label = "ApcMUT_HpWT (CagA+, n=5) vs ApcMUT_HpKO (Control, n=4)",
          size = 4, color = "gray40", hjust = 0.5) +
 xlim(0, 1) + ylim(0, 1) +
 theme_void()

# 2. 核心发现区域 - 三个主要发现
create_finding_box <- function(number, title, stats, color) {
 ggplot() +
   # 背景框
   annotate("rect", xmin = 0.05, xmax = 0.95, ymin = 0.1, ymax = 0.9,
            fill = color, alpha = 0.15, color = color, linewidth = 1.5) +
   # 编号
   annotate("text", x = 0.5, y = 0.78, label = number,
            size = 8, fontface = "bold", color = color) +
   # 标题
   annotate("text", x = 0.5, y = 0.55, label = title,
            size = 3.5, fontface = "bold", hjust = 0.5) +
   # 统计数据
   annotate("text", x = 0.5, y = 0.3, label = stats,
            size = 2.8, color = "gray30", hjust = 0.5) +
   xlim(0, 1) + ylim(0, 1) +
   theme_void()
}

p_finding1 <- create_finding_box(
 "1",
 "Composition\nChanged",
 "Beta P=0.012\n5 species depleted",
 "#3498db"
)

p_finding2 <- create_finding_box(
 "2",
 "Function\nStable",
 "Redundancy\nDriver shift",
 "#2ecc71"
)

p_finding3 <- create_finding_box(
 "3",
 "Network\nCollapsed",
 "Bacteria -63%\nPhage -30%",
 "#e74c3c"
)

# 3. Bacteria-Phage 协同区域
p_coupling <- ggplot() +
 annotate("rect", xmin = 0.05, xmax = 0.95, ymin = 0.15, ymax = 0.85,
          fill = "#9b59b6", alpha = 0.1, color = "#9b59b6", linewidth = 1.2) +
 annotate("text", x = 0.5, y = 0.65,
          label = "Bacteria-Phage Coupling",
          size = 4, fontface = "bold", color = "#9b59b6") +
 annotate("text", x = 0.5, y = 0.4,
          label = "Mantel r = 0.932 ***",
          size = 3.5, color = "gray30") +
 xlim(0, 1) + ylim(0, 1) +
 theme_void()

# 4. 假说区域
p_hypothesis <- ggplot() +
 annotate("rect", xmin = 0.02, xmax = 0.98, ymin = 0.1, ymax = 0.9,
          fill = "#f39c12", alpha = 0.1, color = "#f39c12",
          linewidth = 1, linetype = "dashed") +
 annotate("text", x = 0.5, y = 0.7,
          label = "Hypothesis",
          size = 4, fontface = "bold.italic", color = "#f39c12") +
 annotate("text", x = 0.5, y = 0.4,
          label = "Persistent CD8+ T-cell activation driven by\nCagA-reshaped microbiome (molecular mimicry?)",
          size = 2.8, color = "gray30", hjust = 0.5, lineheight = 1.2) +
 xlim(0, 1) + ylim(0, 1) +
 theme_void()

# 5. Next Steps 区域
p_next <- ggplot() +
 # 标题
 annotate("text", x = 0.5, y = 0.92, label = "Next Steps",
          size = 5, fontface = "bold", hjust = 0.5) +
 # 三个优先级
 annotate("rect", xmin = 0.02, xmax = 0.32, ymin = 0.1, ymax = 0.8,
          fill = "#e74c3c", alpha = 0.15) +
 annotate("text", x = 0.17, y = 0.7, label = "Immediate",
          size = 3, fontface = "bold", color = "#e74c3c") +
 annotate("text", x = 0.17, y = 0.45,
          label = "Integrate\nimmune/tumor\nphenotype data",
          size = 2.3, color = "gray30", hjust = 0.5, lineheight = 1.1) +

 annotate("rect", xmin = 0.35, xmax = 0.65, ymin = 0.1, ymax = 0.8,
          fill = "#f39c12", alpha = 0.15) +
 annotate("text", x = 0.5, y = 0.7, label = "Short-term",
          size = 3, fontface = "bold", color = "#f39c12") +
 annotate("text", x = 0.5, y = 0.45,
          label = "Metabolomics\n(SCFA, LPS)\nMetatranscriptomics",
          size = 2.3, color = "gray30", hjust = 0.5, lineheight = 1.1) +

 annotate("rect", xmin = 0.68, xmax = 0.98, ymin = 0.1, ymax = 0.8,
          fill = "#3498db", alpha = 0.15) +
 annotate("text", x = 0.83, y = 0.7, label = "Long-term",
          size = 3, fontface = "bold", color = "#3498db") +
 annotate("text", x = 0.83, y = 0.45,
          label = "Epitope analysis\nDriver species\nvalidation",
          size = 2.3, color = "gray30", hjust = 0.5, lineheight = 1.1) +

 xlim(0, 1) + ylim(0, 1) +
 theme_void()

# 6. 箭头连接图
p_arrow <- ggplot() +
 annotate("segment", x = 0.5, xend = 0.5, y = 0.8, yend = 0.2,
          arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
          linewidth = 1.5, color = "gray50") +
 xlim(0, 1) + ylim(0, 1) +
 theme_void()

p_arrow_h <- ggplot() +
 annotate("segment", x = 0.1, xend = 0.9, y = 0.5, yend = 0.5,
          arrow = arrow(length = unit(0.2, "cm"), type = "closed", ends = "both"),
          linewidth = 1, color = "gray50") +
 xlim(0, 1) + ylim(0, 1) +
 theme_void()

# ------------------------------------------------------------------------------
# 组装完整图形
# ------------------------------------------------------------------------------

# 使用 patchwork 布局
layout <- "
AAAAAAAAAA
AAAAAAAAAA
BBBBBBBBBB
CCCDDDEEEF
CCCDDDEEEF
GGGGGGGGGG
GGGGGGGGGG
HHHHHHHHHH
IIIIIIIIII
IIIIIIIIII
IIIIIIIIII
"

p_spacer <- ggplot() + theme_void()

p_combined <- p_title +                    # A - 标题
 p_spacer +                                # B - 间隔
 p_finding1 + p_finding2 + p_finding3 +    # C, D, E - 三个发现
 p_spacer +                                # F - 间隔
 p_coupling +                              # G - Bacteria-Phage
 p_hypothesis +                            # H - 假说
 p_next +                                  # I - Next Steps
 plot_layout(design = layout)

# 保存
ggsave(
 filename = here::here("analyses", "data", "summary_graphical_abstract.png"),
 plot = p_combined,
 width = 10,
 height = 12,
 dpi = 300,
 bg = "white"
)

cat("图片已保存: analyses/data/summary_graphical_abstract.png\n")

# ------------------------------------------------------------------------------
# 备选：更简洁的横版布局
# ------------------------------------------------------------------------------

p_horizontal <- ggplot() +
 # 背景
 theme_void() +

 # ===== 顶部标题 =====
 annotate("text", x = 0.5, y = 0.95,
          label = "CagA Reshapes Gut Microbiome: Summary & Next Steps",
          size = 6, fontface = "bold", hjust = 0.5) +
 annotate("text", x = 0.5, y = 0.90,
          label = "ApcMUT_HpWT (n=5) vs ApcMUT_HpKO (n=4)",
          size = 3.5, color = "gray50", hjust = 0.5) +

 # ===== 左侧：Key Findings =====
 annotate("text", x = 0.15, y = 0.82, label = "Key Findings",
          size = 5, fontface = "bold") +

 # Finding 1
 annotate("rect", xmin = 0.02, xmax = 0.28, ymin = 0.62, ymax = 0.78,
          fill = "#3498db", alpha = 0.15, color = "#3498db", linewidth = 1) +
 annotate("text", x = 0.15, y = 0.73, label = "1. Composition Changed",
          size = 3.2, fontface = "bold", color = "#3498db") +
 annotate("text", x = 0.15, y = 0.67, label = "Beta diversity P = 0.012",
          size = 2.8, color = "gray40") +

 # Finding 2
 annotate("rect", xmin = 0.02, xmax = 0.28, ymin = 0.44, ymax = 0.60,
          fill = "#2ecc71", alpha = 0.15, color = "#2ecc71", linewidth = 1) +
 annotate("text", x = 0.15, y = 0.55, label = "2. Function Stable",
          size = 3.2, fontface = "bold", color = "#2ecc71") +
 annotate("text", x = 0.15, y = 0.49, label = "Redundancy + Driver shift",
          size = 2.8, color = "gray40") +

 # Finding 3
 annotate("rect", xmin = 0.02, xmax = 0.28, ymin = 0.26, ymax = 0.42,
          fill = "#e74c3c", alpha = 0.15, color = "#e74c3c", linewidth = 1) +
 annotate("text", x = 0.15, y = 0.37, label = "3. Network Collapsed",
          size = 3.2, fontface = "bold", color = "#e74c3c") +
 annotate("text", x = 0.15, y = 0.31, label = "Modularity: -63% / -30%",
          size = 2.8, color = "gray40") +

 # Finding 4
 annotate("rect", xmin = 0.02, xmax = 0.28, ymin = 0.08, ymax = 0.24,
          fill = "#9b59b6", alpha = 0.15, color = "#9b59b6", linewidth = 1) +
 annotate("text", x = 0.15, y = 0.19, label = "4. Bacteria-Phage Coupled",
          size = 3.2, fontface = "bold", color = "#9b59b6") +
 annotate("text", x = 0.15, y = 0.13, label = "Mantel r = 0.932, P = 0.001",
          size = 2.8, color = "gray40") +

 # ===== 中间：箭头和假说 =====
 annotate("segment", x = 0.32, xend = 0.38, y = 0.45, yend = 0.45,
          arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
          linewidth = 1.5, color = "gray50") +

 # 假说框
 annotate("rect", xmin = 0.38, xmax = 0.62, ymin = 0.30, ymax = 0.60,
          fill = "#f39c12", alpha = 0.1, color = "#f39c12",
          linewidth = 1.5, linetype = "dashed") +
 annotate("text", x = 0.5, y = 0.55, label = "Hypothesis",
          size = 4, fontface = "bold.italic", color = "#f39c12") +
 annotate("text", x = 0.5, y = 0.45,
          label = "Persistent CD8+ T-cell\nactivation driven by\nreshaped microbiome\n(molecular mimicry?)",
          size = 3, color = "gray30", hjust = 0.5, lineheight = 1.1) +

 # ===== 右侧：Next Steps =====
 annotate("segment", x = 0.62, xend = 0.68, y = 0.45, yend = 0.45,
          arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
          linewidth = 1.5, color = "gray50") +

 annotate("text", x = 0.84, y = 0.82, label = "Next Steps",
          size = 5, fontface = "bold") +

 # Step 1: Immediate
 annotate("rect", xmin = 0.70, xmax = 0.98, ymin = 0.62, ymax = 0.78,
          fill = "#e74c3c", alpha = 0.12) +
 annotate("text", x = 0.72, y = 0.73, label = "1",
          size = 4, fontface = "bold", color = "#e74c3c", hjust = 0) +
 annotate("text", x = 0.76, y = 0.73, label = "Integrate immune/tumor phenotype",
          size = 2.8, color = "gray30", hjust = 0) +
 annotate("text", x = 0.76, y = 0.67, label = "(Bioinformatics)",
          size = 2.5, color = "gray50", hjust = 0, fontface = "italic") +

 # Step 2: Short-term
 annotate("rect", xmin = 0.70, xmax = 0.98, ymin = 0.44, ymax = 0.60,
          fill = "#f39c12", alpha = 0.12) +
 annotate("text", x = 0.72, y = 0.55, label = "2",
          size = 4, fontface = "bold", color = "#f39c12", hjust = 0) +
 annotate("text", x = 0.76, y = 0.55, label = "Metabolomics validation",
          size = 2.8, color = "gray30", hjust = 0) +
 annotate("text", x = 0.76, y = 0.49, label = "(SCFA, LPS + Metatranscriptomics)",
          size = 2.5, color = "gray50", hjust = 0, fontface = "italic") +

 # Step 3: Long-term
 annotate("rect", xmin = 0.70, xmax = 0.98, ymin = 0.26, ymax = 0.42,
          fill = "#3498db", alpha = 0.12) +
 annotate("text", x = 0.72, y = 0.37, label = "3",
          size = 4, fontface = "bold", color = "#3498db", hjust = 0) +
 annotate("text", x = 0.76, y = 0.37, label = "Mechanistic validation",
          size = 2.8, color = "gray30", hjust = 0) +
 annotate("text", x = 0.76, y = 0.31, label = "(Epitope analysis, Driver isolation)",
          size = 2.5, color = "gray50", hjust = 0, fontface = "italic") +

 # 底部脚注
 annotate("text", x = 0.5, y = 0.02,
          label = "PC047 vCagAepitope | Deng Lab | 2026-01",
          size = 2.5, color = "gray60", hjust = 0.5) +

 xlim(0, 1) + ylim(0, 1) +
 coord_fixed(ratio = 0.6)

ggsave(
 filename = here::here("analyses", "data", "summary_graphical_abstract_horizontal.png"),
 plot = p_horizontal,
 width = 14,
 height = 8,
 dpi = 300,
 bg = "white"
)

cat("横版图片已保存: analyses/data/summary_graphical_abstract_horizontal.png\n")
