# 04 网络分析 (Network Analysis) - 学习笔记

**文件**: `04_network_analysis.qmd`
**学习日期**: 2026-01-28
**参考**: OMA Chapter 10 (Community Ecology), igraph Documentation

---

## 目录

1. [分析目标与逻辑](#1-分析目标与逻辑)
2. [共现网络基础概念](#2-共现网络基础概念)
3. [新增分析方法](#3-新增分析方法)
4. [网络拓扑指标](#4-网络拓扑指标)
5. [分析结果解读](#5-分析结果解读)
6. [对假说的支持](#6-对假说的支持)

---

## 1. 分析目标与逻辑

### 1.1 核心问题

> **CagA感染如何改变肠道菌群物种间的相互作用模式？**

前序分析已经回答：
- 01分析：**谁在那里？** - 物种组成改变 (Beta P=0.012)
- 02分析：**它们能做什么？** - 功能冗余（整体稳定）
- 03分析：**细菌-噬菌体关系？** - 协同变化

04分析回答：
- **它们如何互动？** - 物种间的共现/互斥关系
- **网络稳定吗？** - Bootstrap稳定性验证
- **谁是关键物种？** - Zi-Pi生态角色分类
- **组成型数据问题？** - SparCC方法验证

### 1.2 分析大纲

| Part | 内容 | 新增方法 |
|------|------|----------|
| Part 1 | 数据加载 | - |
| Part 2 | 细菌网络构建 | Spearman相关 |
| Part 2.7 | **Bootstrap稳定性分析** | 1000次重采样 |
| Part 2.8 | **Zi-Pi关键物种分析** | Guimera & Amaral方法 |
| Part 2.9 | **SparCC组成型分析** | 组成型数据相关 |
| Part 3 | 跨域网络 | 细菌-噬菌体 |
| Part 4 | 网络比较 | 模块度对比 |

---

## 2. 共现网络基础概念

### 2.1 什么是共现网络？

**共现网络 (Co-occurrence Network)** 将物种间相关性可视化为图：

| 元素 | 含义 | 类比 |
|------|------|------|
| **节点 (Node)** | 物种 | 社交网络中的人 |
| **边 (Edge)** | 物种间相关性 | 人与人的关系 |
| **边权重** | 相关系数 | 关系强度 |
| **边符号** | 正/负相关 | 朋友/敌人 |

### 2.2 相关性 ≠ 因果性

共现可能是：
- 直接互作（代谢物交换）
- 间接互作（共同响应环境）
- 第三因素驱动

---

## 3. 新增分析方法

### 3.1 Bootstrap网络稳定性分析

**目的**：验证Hub物种识别的可靠性

```r
# 1000次Bootstrap重采样
n_bootstrap <- 1000
edge_stability <- matrix(0, nrow = n_species, ncol = n_species)

for (i in 1:n_bootstrap) {
  # 有放回重采样样本
  boot_samples <- sample(1:n, n, replace = TRUE)
  boot_data <- abundance[, boot_samples]

  # 计算相关性
  boot_cor <- cor(t(boot_data), method = "spearman")
  boot_adj <- abs(boot_cor) >= threshold

  # 累计边出现次数
  edge_stability <- edge_stability + boot_adj
}

# 稳定性 = 边出现频率
edge_stability <- edge_stability / n_bootstrap
```

**解读**：稳定性 > 70% 的边被认为是稳定的

### 3.2 Zi-Pi分析（Keystone物种识别）

**原理**：根据模块内连接度(Zi)和模块间参与度(Pi)分类物种角色

```r
# 模块内连接度 z-score
calculate_zi <- function(graph, membership) {
  for (node in nodes) {
    # 计算模块内度
    ki <- sum(neighbors %in% same_module_nodes)
    # 计算模块平均和标准差
    mean_k <- mean(module_degrees)
    sd_k <- sd(module_degrees)
    # Zi = (ki - mean_k) / sd_k
    zi[node] <- (ki - mean_k) / sd_k
  }
}

# 模块间参与度
calculate_pi <- function(graph, membership) {
  for (node in nodes) {
    # Pi = 1 - sum((kis/ki)^2)  # kis是到模块s的连接数
  }
}
```

**角色分类**：

| 角色 | Zi | Pi | 含义 |
|------|-----|-----|------|
| **Module hub** | >2.5 | <0.62 | 模块内核心 |
| **Network hub** | >2.5 | ≥0.62 | 全网络核心 |
| **Connector** | ≤2.5 | ≥0.62 | 模块间桥梁 |
| **Peripheral** | ≤2.5 | <0.62 | 边缘物种 |

### 3.3 SparCC组成型数据分析

**问题**：微生物组数据是相对丰度（组成型数据），传统相关系数有偏

**SparCC方法**：
- 专门为组成型数据设计
- 通过迭代排除强相关对来估计真实相关
- 对假阳性有更好的控制

```r
# SparCC相关（使用SpiecEasi包的实现）
sparcc_result <- SpiecEasi::sparcc(abundance_matrix)
sparcc_cor <- sparcc_result$Cor
```

**比较Spearman vs SparCC**：
- SparCC通常检测到更保守的相关
- 但对真实相关更准确

### 3.4 cluster_louvain负权重问题

**错误**：`Weight vector must not be negative`

**原因**：相关系数可以是负数，但Louvain算法要求正权重

**解决方案**：
```r
# 方案1：忽略权重
communities <- igraph::cluster_louvain(g, weights = NA)

# 方案2：使用绝对值（不推荐，会改变语义）
# communities <- igraph::cluster_louvain(g, weights = abs(E(g)$weight))
```

---

## 4. 网络拓扑指标

### 4.1 模块度 (Modularity)

最重要的网络结构指标：

| 模块度值 | 含义 | 生物学解读 |
|----------|------|------------|
| **高 (>0.4)** | 清晰模块结构 | 物种分化明显，各司其职 |
| **中 (0.25-0.4)** | 中等结构 | 有一定分化 |
| **低 (<0.25)** | 混合结构 | 物种间界限模糊，功能重叠 |

### 4.2 中心性指标

| 指标 | 英文 | 含义 | 识别 |
|------|------|------|------|
| **度** | Degree | 连接边数 | Hub物种 |
| **介数** | Betweenness | 最短路径数 | 桥梁物种 |
| **接近度** | Closeness | 到其他节点距离 | 核心物种 |

**命名空间冲突注意**：
```r
# igraph与ape包冲突，必须显式指定
igraph::degree(g)         # 不是 degree(g)
igraph::betweenness(g)    # 不是 betweenness(g)
```

---

## 5. 分析结果解读

### 5.1 网络拓扑比较

**表1. 细菌网络CagA效应（Top 50物种）**

| 指标 | HpKO (对照) | HpWT (CagA+) | 变化 |
|------|-------------|--------------|------|
| 边数 | 416 | 360 | -13% |
| 密度 | 0.340 | 0.294 | -0.046 |
| **模块度** | **0.393** | **0.237** | **-40%** |

### 5.2 细菌-噬菌体网络对比

**表2. 模块度变化对比**

| 数据类型 | Control | CagA+ | 降低幅度 |
|----------|---------|-------|----------|
| **细菌** | 0.433 | 0.160 | **-63%** |
| 噬菌体 | 0.365 | 0.255 | -30% |

**关键发现**：CagA对细菌网络的破坏性远大于噬菌体

### 5.3 Zi-Pi分析结果

所有物种都是Peripheral（Zi<2.5, Pi<0.62）：
- 没有检测到严格定义的Keystone物种
- 符合"模块结构瓦解"的发现
- 小样本量可能限制了统计力

### 5.4 Bootstrap稳定Hub物种

经1000次Bootstrap验证的Top 5 Hub物种：

| 物种 | 稳定度 | 功能 |
|------|--------|------|
| *Blautia parvula* | 26 | SCFA生产 |
| *Roseburia hominis* | 24 | 丁酸生产 |
| *Marvinbryantia formatexigens* | 24 | 甲酸利用 |

---

## 6. 对假说的支持

### 6.1 解释功能冗余

```
模块度降低 → 物种间界限模糊 → 生态位重叠 → 功能可互相替代
```

### 6.2 细菌主导效应

CagA主要通过破坏**细菌**群落结构影响肠道：
- 细菌模块度↓63%
- 噬菌体模块度↓30%

### 6.3 对T细胞激活的启示

| 机制 | 网络证据 | 免疫学意义 |
|------|----------|------------|
| 群落结构紊乱 | 模块度降低 | 抗原多样性改变 |
| Hub物种改变 | SCFA生产者变化 | 免疫调节改变 |
| 无Keystone物种 | 全Peripheral | 群落去中心化 |

---

## 技术要点速查

### Q1: cluster_louvain报错"Weight must not be negative"

```r
# 使用 weights = NA 忽略权重
communities <- igraph::cluster_louvain(g, weights = NA)
```

### Q2: calculate_zi中sd()返回NA

模块只有1个节点时sd()返回NA：
```r
if (!is.na(sd_k) && sd_k > 0) {
  zi <- (ki - mean_k) / sd_k
} else {
  zi <- 0
}
```

### Q3: 为什么限制Top 50物种？

- 样本数少（4-5个）时无法可靠估计大量相关性
- 聚焦高丰度物种更有生物学意义
- 计算效率考虑

---

## 输出文件

| 文件 | 内容 |
|------|------|
| `01_bacteria_network_stats.csv` | 网络拓扑统计 |
| `04_bacteria_hub_species.csv` | Hub物种指标 |
| `05_edge_stability_distribution.png` | Bootstrap稳定性分布 |
| `06_robust_hub_species.csv` | 稳定Hub物种 |
| `07_zi_pi_analysis.csv` | Zi-Pi分析结果 |
| `08_zi_pi_plot.png` | Zi-Pi散点图 |
| `12_sparcc_correlation_matrix.csv` | SparCC相关矩阵 |
| `15_bacteria_phage_network_stats.csv` | 细菌-噬菌体统计 |

---

## 关键术语速查表

| 术语 | 英文 | 简单解释 |
|------|------|----------|
| 共现网络 | Co-occurrence Network | 基于相关性的物种互作网络 |
| 模块度 | Modularity | 网络模块化程度 |
| Hub物种 | Hub Species | 高连接度核心物种 |
| Zi | Within-module degree | 模块内连接度z-score |
| Pi | Participation coefficient | 模块间参与度 |
| Keystone物种 | Keystone Species | 高Zi的关键物种 |
| SparCC | Sparse Correlations for Compositional data | 组成型数据相关方法 |
| Bootstrap | Bootstrap | 重采样验证方法 |

---

*笔记由 Claude 协助整理 | 参考 OMA Chapter 10, igraph Documentation*
