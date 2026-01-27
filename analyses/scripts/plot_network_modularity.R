# ==============================================================================
# Network Modularity Comparison Visualization
# 展示CagA感染导致的网络模块结构变化
# ==============================================================================

library(ggplot2)
library(dplyr)
library(patchwork)

# ------------------------------------------------------------------------------
# 1. 准备数据
# ------------------------------------------------------------------------------

network_stats <- data.frame(
  group = c("HpKO (Control)", "HpWT (CagA+)"),
  group_order = c(1, 2),
  nodes = c(80, 100),
  edges = c(1280, 2190),
  density = c(0.405, 0.442),
  modularity = c(0.468, 0.177),
  transitivity = c(0.771, 0.796)
)

# ------------------------------------------------------------------------------
# 2. 模块度对比图 (主要信息)
# ------------------------------------------------------------------------------

p_modularity <- ggplot(network_stats, aes(x = reorder(group, group_order), y = modularity, fill = group)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = sprintf("%.3f", modularity)),
            vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_manual(values = c("HpKO (Control)" = "#3498db", "HpWT (CagA+)" = "#e74c3c")) +
  scale_y_continuous(limits = c(0, 0.6), breaks = seq(0, 0.6, 0.1)) +
  labs(
    title = "Network Modularity",
    subtitle = "Module structure collapsed by 62%",
    x = NULL,
    y = "Modularity Score"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none",
    axis.text.x = element_text(size = 11, face = "bold")
  )

# ------------------------------------------------------------------------------
# 3. 边数对比图 (网络复杂度)
# ------------------------------------------------------------------------------

p_edges <- ggplot(network_stats, aes(x = reorder(group, group_order), y = edges, fill = group)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = edges),
            vjust = -0.5, size = 5, fontface = "bold") +
  scale_fill_manual(values = c("HpKO (Control)" = "#3498db", "HpWT (CagA+)" = "#e74c3c")) +
  scale_y_continuous(limits = c(0, 2600)) +
  labs(
    title = "Network Edges",
    subtitle = "Connectivity increased by 71%",
    x = NULL,
    y = "Number of Edges"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none",
    axis.text.x = element_text(size = 11, face = "bold")
  )

# ------------------------------------------------------------------------------
# 4. 组合图
# ------------------------------------------------------------------------------

p_combined <- p_modularity + p_edges +
  plot_annotation(
    title = "Co-occurrence Network: Module Breakdown Under CagA",
    subtitle = "More connections but less organized structure",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 12, color = "gray30")
    )
  )

print(p_combined)

# ------------------------------------------------------------------------------
# 5. 保存图片
# ------------------------------------------------------------------------------

ggsave(
  filename = here::here("analyses", "data", "03c_cooccurrence_network",
                        "network_modularity_comparison.png"),
  plot = p_combined,
  width = 10,
  height = 5,
  dpi = 300
)

cat("图片已保存至: analyses/data/03c_cooccurrence_network/network_modularity_comparison.png\n")

# ------------------------------------------------------------------------------
# 6. 额外：创建示意图风格的网络对比 (概念图)
# ------------------------------------------------------------------------------

# 创建一个简单的概念对比图
library(ggforce)

# 模块化网络 (Control)
set.seed(42)
n_per_module <- 8
modules <- 3

# Control: 有明显模块
control_nodes <- data.frame(
  x = c(rnorm(n_per_module, -2, 0.3), rnorm(n_per_module, 2, 0.3), rnorm(n_per_module, 0, 0.3)),
  y = c(rnorm(n_per_module, 1, 0.3), rnorm(n_per_module, 1, 0.3), rnorm(n_per_module, -1.5, 0.3)),
  module = rep(c("A", "B", "C"), each = n_per_module)
)

# CagA: 模块混乱
caga_nodes <- data.frame(
  x = rnorm(n_per_module * modules, 0, 1.2),
  y = rnorm(n_per_module * modules, 0, 1),
  module = sample(c("A", "B", "C"), n_per_module * modules, replace = TRUE)
)

module_colors <- c("A" = "#e74c3c", "B" = "#3498db", "C" = "#2ecc71")

p_control_net <- ggplot(control_nodes, aes(x = x, y = y, color = module)) +
  geom_point(size = 4, alpha = 0.8) +
  stat_ellipse(level = 0.9, linetype = "dashed", linewidth = 1) +
  scale_color_manual(values = module_colors) +
  labs(title = "Control (HpKO)", subtitle = "Modularity = 0.468\nDistinct modules") +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray30"),
    legend.position = "none"
  ) +
  coord_fixed(xlim = c(-4, 4), ylim = c(-3, 3))

p_caga_net <- ggplot(caga_nodes, aes(x = x, y = y, color = module)) +
  geom_point(size = 4, alpha = 0.8) +
  scale_color_manual(values = module_colors) +
  labs(title = "CagA+ (HpWT)", subtitle = "Modularity = 0.177\nModules collapsed") +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray30"),
    legend.position = "none"
  ) +
  coord_fixed(xlim = c(-4, 4), ylim = c(-3, 3))

p_concept <- p_control_net + p_caga_net +
  plot_annotation(
    title = "Network Module Structure Change",
    subtitle = "CagA disrupts distinct ecological niches",
    theme = theme(
      plot.title = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(size = 11, color = "gray30")
    )
  )

print(p_concept)

ggsave(
  filename = here::here("analyses", "data", "03c_cooccurrence_network",
                        "network_module_concept.png"),
  plot = p_concept,
  width = 10,
  height = 5,
  dpi = 300
)

cat("概念图已保存至: analyses/data/03c_cooccurrence_network/network_module_concept.png\n")
