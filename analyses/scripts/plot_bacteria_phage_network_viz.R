# ==============================================================================
# Bacteria vs Phage Network Visualization (2x2 grid)
# 细菌和噬菌体网络可视化对比
# ==============================================================================

library(TreeSummarizedExperiment)
library(igraph)

# ------------------------------------------------------------------------------
# 1. 加载数据
# ------------------------------------------------------------------------------

tse_bacteria <- readRDS(here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
                                    "tse_standard_species_ca_cleaned.rds"))
tse_phage <- readRDS(here::here("analyses", "data", "03_singlem_diversity_analysis",
                                 "tse_lyrebird_corepair.rds"))

# ------------------------------------------------------------------------------
# 2. 网络构建函数
# ------------------------------------------------------------------------------

build_network <- function(tse, samples, top_n = 50, cor_threshold = 0.6) {
  counts <- assay(tse, "counts")[, samples, drop = FALSE]
  grp_relab <- sweep(counts, 2, colSums(counts) + 1, "/")

  row_sds <- apply(grp_relab, 1, sd)
  grp_relab <- grp_relab[row_sds > 0, , drop = FALSE]

  n_species <- min(top_n, nrow(grp_relab))
  mean_abund <- rowMeans(grp_relab)
  top_species <- names(sort(mean_abund, decreasing = TRUE))[1:n_species]
  grp_relab <- grp_relab[top_species, , drop = FALSE]

  cor_mat <- cor(t(grp_relab), method = "spearman")
  cor_mat[is.na(cor_mat)] <- 0

  adj_mat <- abs(cor_mat) >= cor_threshold
  diag(adj_mat) <- FALSE

  g <- graph_from_adjacency_matrix(adj_mat, mode = "undirected")

  if (ecount(g) > 0) {
    comm <- cluster_louvain(g)
    V(g)$community <- membership(comm)
    mod <- modularity(comm)
  } else {
    V(g)$community <- 1
    mod <- 0
  }

  V(g)$degree <- igraph::degree(g)

  return(list(graph = g, modularity = mod, n_edges = ecount(g)))
}

# ------------------------------------------------------------------------------
# 3. 获取样本并构建网络
# ------------------------------------------------------------------------------

bact_meta <- as.data.frame(colData(tse_bacteria))
phage_meta <- as.data.frame(colData(tse_phage))

bact_hpko <- rownames(bact_meta)[bact_meta$treatment_group == "ApcMUT_HpKO"]
bact_hpwt <- rownames(bact_meta)[bact_meta$treatment_group == "ApcMUT_HpWT"]
phage_hpko <- rownames(phage_meta)[phage_meta$treatment_group == "ApcMUT_HpKO"]
phage_hpwt <- rownames(phage_meta)[phage_meta$treatment_group == "ApcMUT_HpWT"]

cat("构建网络...\n")
net_bact_hpko <- build_network(tse_bacteria, bact_hpko)
net_bact_hpwt <- build_network(tse_bacteria, bact_hpwt)
net_phage_hpko <- build_network(tse_phage, phage_hpko)
net_phage_hpwt <- build_network(tse_phage, phage_hpwt)

# ------------------------------------------------------------------------------
# 4. 绘制 2x2 网络图
# ------------------------------------------------------------------------------

# 颜色方案
get_colors <- function(n) {
  if (n <= 8) {
    return(c("#e74c3c", "#3498db", "#2ecc71", "#f39c12", "#9b59b6", "#1abc9c", "#e67e22", "#34495e")[1:n])
  } else {
    return(rainbow(n, s = 0.7, v = 0.8))
  }
}

png(here::here("analyses", "data", "03c_cooccurrence_network",
               "bacteria_phage_network_2x2.png"),
    width = 1600, height = 1600, res = 150)

par(mfrow = c(2, 2), mar = c(1, 1, 4, 1))

# 设置相同的随机种子以获得可比较的布局
set.seed(42)

# --- 细菌 Control ---
g <- net_bact_hpko$graph
n_comm <- max(V(g)$community)
colors <- get_colors(n_comm)[V(g)$community]
layout_bact <- layout_with_fr(g)

plot(g,
     layout = layout_bact,
     vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 2,
     vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3),
     edge.width = 0.5,
     main = sprintf("Bacteria - Control (HpKO)\nNodes: 50 | Edges: %d | Modularity: %.3f",
                    net_bact_hpko$n_edges, net_bact_hpko$modularity))

# --- 细菌 CagA+ ---
g <- net_bact_hpwt$graph
n_comm <- max(V(g)$community)
colors <- get_colors(n_comm)[V(g)$community]

plot(g,
     layout = layout_bact,  # 使用相同布局便于对比
     vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 2,
     vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3),
     edge.width = 0.5,
     main = sprintf("Bacteria - CagA+ (HpWT)\nNodes: 50 | Edges: %d | Modularity: %.3f",
                    net_bact_hpwt$n_edges, net_bact_hpwt$modularity))

# --- 噬菌体 Control ---
set.seed(42)
g <- net_phage_hpko$graph
n_comm <- max(V(g)$community)
colors <- get_colors(n_comm)[V(g)$community]
layout_phage <- layout_with_fr(g)

plot(g,
     layout = layout_phage,
     vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 2,
     vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3),
     edge.width = 0.5,
     main = sprintf("Phage - Control (HpKO)\nNodes: 50 | Edges: %d | Modularity: %.3f",
                    net_phage_hpko$n_edges, net_phage_hpko$modularity))

# --- 噬菌体 CagA+ ---
g <- net_phage_hpwt$graph
n_comm <- max(V(g)$community)
colors <- get_colors(n_comm)[V(g)$community]

plot(g,
     layout = layout_phage,  # 使用相同布局便于对比
     vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 2,
     vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3),
     edge.width = 0.5,
     main = sprintf("Phage - CagA+ (HpWT)\nNodes: 50 | Edges: %d | Modularity: %.3f",
                    net_phage_hpwt$n_edges, net_phage_hpwt$modularity))

dev.off()

cat("\n图片已保存: bacteria_phage_network_2x2.png\n")

# ------------------------------------------------------------------------------
# 5. 额外：1x2 横向对比图（只看modularity变化）
# ------------------------------------------------------------------------------

png(here::here("analyses", "data", "03c_cooccurrence_network",
               "bacteria_phage_network_1x4.png"),
    width = 2400, height = 600, res = 150)

par(mfrow = c(1, 4), mar = c(1, 1, 4, 1))

set.seed(42)

# 细菌 Control
g <- net_bact_hpko$graph
colors <- get_colors(max(V(g)$community))[V(g)$community]
layout_b <- layout_with_fr(g)
plot(g, layout = layout_b, vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 1.5, vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3), edge.width = 0.5,
     main = sprintf("Bacteria Control\nMod: %.3f", net_bact_hpko$modularity))

# 细菌 CagA+
g <- net_bact_hpwt$graph
colors <- get_colors(max(V(g)$community))[V(g)$community]
plot(g, layout = layout_b, vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 1.5, vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3), edge.width = 0.5,
     main = sprintf("Bacteria CagA+\nMod: %.3f (-63%%)", net_bact_hpwt$modularity))

set.seed(42)
# 噬菌体 Control
g <- net_phage_hpko$graph
colors <- get_colors(max(V(g)$community))[V(g)$community]
layout_p <- layout_with_fr(g)
plot(g, layout = layout_p, vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 1.5, vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3), edge.width = 0.5,
     main = sprintf("Phage Control\nMod: %.3f", net_phage_hpko$modularity))

# 噬菌体 CagA+
g <- net_phage_hpwt$graph
colors <- get_colors(max(V(g)$community))[V(g)$community]
plot(g, layout = layout_p, vertex.color = colors,
     vertex.size = 3 + sqrt(V(g)$degree) * 1.5, vertex.label = NA,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3), edge.width = 0.5,
     main = sprintf("Phage CagA+\nMod: %.3f (-30%%)", net_phage_hpwt$modularity))

dev.off()

cat("图片已保存: bacteria_phage_network_1x4.png\n")
