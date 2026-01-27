# ==============================================================================
# Bacteria vs Phage Network Comparison
# 细菌和噬菌体共现网络的并排对比 (只比较 ApcMUT_HpKO vs ApcMUT_HpWT)
# ==============================================================================

library(TreeSummarizedExperiment)
library(igraph)
library(ggplot2)
library(dplyr)
library(patchwork)

# ------------------------------------------------------------------------------
# 1. 加载数据
# ------------------------------------------------------------------------------

# 细菌数据 (Bracken)
tse_bacteria <- readRDS(here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
                                    "tse_standard_species_ca_cleaned.rds"))

# 噬菌体数据 (Lyrebird)
tse_phage <- readRDS(here::here("analyses", "data", "03_singlem_diversity_analysis",
                                 "tse_lyrebird_corepair.rds"))

cat("细菌物种数:", nrow(tse_bacteria), "\n")
cat("噬菌体OTU数:", nrow(tse_phage), "\n")

# 检查分组
cat("\n细菌数据分组:\n")
print(table(colData(tse_bacteria)$treatment_group))
cat("\n噬菌体数据分组:\n")
print(table(colData(tse_phage)$treatment_group))

# ------------------------------------------------------------------------------
# 2. 定义网络构建函数
# ------------------------------------------------------------------------------

build_network_for_group <- function(tse, samples, top_n = 50, cor_threshold = 0.6) {
  counts <- assay(tse, "counts")[, samples, drop = FALSE]

  # 计算相对丰度
  grp_relab <- sweep(counts, 2, colSums(counts) + 1, "/")

  # 过滤低变异物种
  row_sds <- apply(grp_relab, 1, sd)
  grp_relab <- grp_relab[row_sds > 0, , drop = FALSE]

  # 取Top N
  n_species <- min(top_n, nrow(grp_relab))
  mean_abund <- rowMeans(grp_relab)
  top_species <- names(sort(mean_abund, decreasing = TRUE))[1:n_species]
  grp_relab <- grp_relab[top_species, , drop = FALSE]

  # 计算相关性
  cor_mat <- cor(t(grp_relab), method = "spearman")
  cor_mat[is.na(cor_mat)] <- 0

  # 构建邻接矩阵
  adj_mat <- abs(cor_mat) >= cor_threshold
  diag(adj_mat) <- FALSE

  # 构建igraph
  g <- graph_from_adjacency_matrix(adj_mat, mode = "undirected")

  # 计算模块度
  if (ecount(g) > 0) {
    comm <- cluster_louvain(g)
    mod <- modularity(comm)
  } else {
    mod <- 0
  }

  return(list(
    n_nodes = vcount(g),
    n_edges = ecount(g),
    modularity = mod,
    graph = g
  ))
}

# ------------------------------------------------------------------------------
# 3. 获取样本分组
# ------------------------------------------------------------------------------

# 细菌数据的分组
bact_meta <- as.data.frame(colData(tse_bacteria))
bact_hpko <- rownames(bact_meta)[bact_meta$treatment_group == "ApcMUT_HpKO"]
bact_hpwt <- rownames(bact_meta)[bact_meta$treatment_group == "ApcMUT_HpWT"]

# 噬菌体数据的分组
phage_meta <- as.data.frame(colData(tse_phage))
phage_hpko <- rownames(phage_meta)[phage_meta$treatment_group == "ApcMUT_HpKO"]
phage_hpwt <- rownames(phage_meta)[phage_meta$treatment_group == "ApcMUT_HpWT"]

cat("\n细菌 HpKO样本:", length(bact_hpko), "\n")
cat("细菌 HpWT样本:", length(bact_hpwt), "\n")
cat("噬菌体 HpKO样本:", length(phage_hpko), "\n")
cat("噬菌体 HpWT样本:", length(phage_hpwt), "\n")

# ------------------------------------------------------------------------------
# 4. 构建网络
# ------------------------------------------------------------------------------

cat("\n构建细菌网络...\n")
bact_net_hpko <- build_network_for_group(tse_bacteria, bact_hpko)
bact_net_hpwt <- build_network_for_group(tse_bacteria, bact_hpwt)

cat("构建噬菌体网络...\n")
phage_net_hpko <- build_network_for_group(tse_phage, phage_hpko)
phage_net_hpwt <- build_network_for_group(tse_phage, phage_hpwt)

# ------------------------------------------------------------------------------
# 5. 汇总统计
# ------------------------------------------------------------------------------

stats_df <- data.frame(
  data_type = c("Bacteria", "Bacteria", "Phage", "Phage"),
  group = c("Control (HpKO)", "CagA+ (HpWT)", "Control (HpKO)", "CagA+ (HpWT)"),
  group_short = c("Control", "CagA+", "Control", "CagA+"),
  nodes = c(bact_net_hpko$n_nodes, bact_net_hpwt$n_nodes,
            phage_net_hpko$n_nodes, phage_net_hpwt$n_nodes),
  edges = c(bact_net_hpko$n_edges, bact_net_hpwt$n_edges,
            phage_net_hpko$n_edges, phage_net_hpwt$n_edges),
  modularity = c(bact_net_hpko$modularity, bact_net_hpwt$modularity,
                 phage_net_hpko$modularity, phage_net_hpwt$modularity)
)

print(stats_df)

# 计算变化百分比
bact_mod_change <- (bact_net_hpwt$modularity - bact_net_hpko$modularity) /
                   bact_net_hpko$modularity * 100

phage_mod_change <- (phage_net_hpwt$modularity - phage_net_hpko$modularity) /
                    phage_net_hpko$modularity * 100

cat("\n细菌网络模块度变化:", round(bact_mod_change, 1), "%\n")
cat("噬菌体网络模块度变化:", round(phage_mod_change, 1), "%\n")

# ------------------------------------------------------------------------------
# 6. 绘制模块度对比图
# ------------------------------------------------------------------------------

stats_df$group_short <- factor(stats_df$group_short, levels = c("Control", "CagA+"))
stats_df$data_type <- factor(stats_df$data_type, levels = c("Bacteria", "Phage"))

p_modularity <- ggplot(stats_df, aes(x = group_short, y = modularity, fill = group_short)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = sprintf("%.3f", modularity)), vjust = -0.5, size = 4.5, fontface = "bold") +
  facet_wrap(~data_type) +
  scale_fill_manual(values = c("Control" = "#3498db", "CagA+" = "#e74c3c")) +
  scale_y_continuous(limits = c(0, max(stats_df$modularity) * 1.2)) +
  labs(
    title = "Network Modularity: Bacteria vs Phage",
    subtitle = sprintf("Both show decrease under CagA (Bacteria: %.0f%%, Phage: %.0f%%)",
                       bact_mod_change, phage_mod_change),
    x = NULL,
    y = "Modularity",
    fill = "Group"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30"),
    legend.position = "none",
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold", size = 12)
  )

print(p_modularity)

ggsave(
  filename = here::here("analyses", "data", "03c_cooccurrence_network",
                        "bacteria_phage_modularity_comparison.png"),
  plot = p_modularity,
  width = 8,
  height = 5,
  dpi = 300
)

# ------------------------------------------------------------------------------
# 7. 绘制边数对比图
# ------------------------------------------------------------------------------

p_edges <- ggplot(stats_df, aes(x = group_short, y = edges, fill = group_short)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = edges), vjust = -0.5, size = 4.5, fontface = "bold") +
  facet_wrap(~data_type) +
  scale_fill_manual(values = c("Control" = "#3498db", "CagA+" = "#e74c3c")) +
  scale_y_continuous(limits = c(0, max(stats_df$edges) * 1.15)) +
  labs(
    title = "Network Connectivity: Bacteria vs Phage",
    x = NULL,
    y = "Number of Edges",
    fill = "Group"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none",
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold", size = 12)
  )

# ------------------------------------------------------------------------------
# 8. 组合图
# ------------------------------------------------------------------------------

p_combined <- p_modularity / p_edges +
  plot_annotation(
    title = "Co-occurrence Network: Bacteria and Phage Both Restructure Under CagA",
    theme = theme(plot.title = element_text(face = "bold", size = 15))
  )

print(p_combined)

ggsave(
  filename = here::here("analyses", "data", "03c_cooccurrence_network",
                        "bacteria_phage_network_combined.png"),
  plot = p_combined,
  width = 9,
  height = 8,
  dpi = 300
)

cat("\n图片已保存至: analyses/data/03c_cooccurrence_network/\n")
cat("  - bacteria_phage_modularity_comparison.png\n")
cat("  - bacteria_phage_network_combined.png\n")

# ------------------------------------------------------------------------------
# 9. 保存统计结果
# ------------------------------------------------------------------------------

write.csv(stats_df,
          file = here::here("analyses", "data", "03c_cooccurrence_network",
                            "bacteria_phage_network_stats.csv"),
          row.names = FALSE)

cat("  - bacteria_phage_network_stats.csv\n")
