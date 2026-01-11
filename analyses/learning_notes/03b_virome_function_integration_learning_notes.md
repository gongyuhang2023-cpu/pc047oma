# 03b 病毒组-功能整合分析 - 学习笔记

**文件**: `03b_virome_function_integration.qmd`
**学习日期**: 2026-01-11
**参考**: OMA Chapter 21 (Multi-assay Integration), 02分析, 03分析

---

## 目录

1. [分析目标与科学意义](#1-分析目标与科学意义)
2. [数据整合](#2-数据整合)
3. [噬菌体-KO关联分析](#3-噬菌体-ko关联分析)
4. [噬菌体-Pathway关联分析](#4-噬菌体-pathway关联分析)
5. [三角互作网络分析](#5-三角互作网络分析)
6. [结果汇总与生物学意义](#6-结果汇总与生物学意义)
7. [与前期分析的整合](#7-与前期分析的整合)

---

## 1. 分析目标与科学意义

### 1.1 核心问题

> 噬菌体是否通过影响细菌群落**间接调控**菌群的代谢功能？

### 1.2 分析逻辑

```
01分析：细菌群落结构变化 (P=0.012)
02分析：功能冗余现象（物种-功能关联78对）
03分析：噬菌体群落无显著变化，但与细菌存在协同动态
    ↓
03b分析：整合上述发现，构建三角互作网络
    ↓
探索：细菌-噬菌体-功能的联合变化模式
```

### 1.3 科学意义

**为什么这个分析重要？**

1. **机制探索**：噬菌体通过裂解/溶原影响细菌，可能间接调控代谢功能
2. **研究创新**：细菌-噬菌体-功能三角互作在肿瘤微生物组研究中较为少见
3. **假说检验**：验证"噬菌体介导的功能调控"假说

### 1.4 整合的数据来源

| 数据 | 来源 | 内容 |
|------|------|------|
| KO丰度 | 02分析 | HUMAnN基因家族 |
| Pathway丰度 | 02分析 | HUMAnN代谢通路 |
| 噬菌体OTU | 03分析 | Lyrebird噬菌体 |
| 细菌OTU | 03分析 | SingleM细菌 |

---

## 2. 数据整合

### 2.1 导入预处理数据

```r
# 从02分析导入功能数据
tse_ko <- readRDS("tse_ko_corepair.rds")
tse_pathway <- readRDS("tse_humann_pathway_corepair.rds")

# 从03分析导入微生物数据
tse_lyrebird <- readRDS("tse_lyrebird_corepair.rds")
tse_singlem <- readRDS("tse_singlem_corepair.rds")
```

### 2.2 找到共同样本

```r
common_samples <- Reduce(intersect, list(
  colnames(tse_ko),
  colnames(tse_pathway),
  colnames(tse_lyrebird),
  colnames(tse_singlem)
))
```

**为什么要找共同样本？**
- 不同分析可能因质量控制移除了不同样本
- 相关性分析要求样本完全匹配
- 本分析共同样本数：9个

### 2.3 数据过滤策略

```r
# 过滤低丰度特征（至少在20%样本中存在）
phage_prevalence <- rowSums(abundance > 0) / ncol(abundance)
phage_abundant <- phage_prevalence >= 0.2
```

**过滤的意义**：
- 移除偶然出现的噬菌体/KO
- 减少多重检验负担
- 提高结果可靠性

---

## 3. 噬菌体-KO关联分析

### 3.1 分析方法

使用**Spearman相关性**计算噬菌体OTU与KO之间的关联。

**为什么用Spearman而非Pearson？**
- 微生物组数据通常不符合正态分布
- Spearman基于秩次，对异常值更稳健
- 不假设线性关系

### 3.2 OMA风格的相关性计算

```r
# 自定义辅助函数
cross_rcorr <- function(mat_x, mat_y) {
  combined <- cbind(mat_x, mat_y)
  rcorr_result <- Hmisc::rcorr(as.matrix(combined), type = "spearman")
  # 提取跨矩阵部分
  r_matrix <- rcorr_result$r[1:nx, (nx+1):(nx+ny)]
  p_matrix <- rcorr_result$P[1:nx, (nx+1):(nx+ny)]
  list(r = r_matrix, P = p_matrix)
}

# 计算噬菌体-KO相关性
cor_phage_ko <- cross_rcorr(phage_t, ko_t)
```

### 3.3 FDR校正

```r
# 转换为长格式并FDR校正
phage_ko_pairs <- corr_to_df(cor_phage_ko)
phage_ko_pairs$qvalue <- p.adjust(phage_ko_pairs$pvalue, method = "BH")
```

**FDR校正的重要性**：
- 检验了成千上万对关联
- 不校正会产生大量假阳性
- BH方法控制假发现率

### 3.4 结果

| FDR阈值 | 显著关联数 |
|---------|------------|
| < 0.05 | ~2800对 |
| < 0.10 | ~3500对 |
| < 0.25 | ~5000对 |

**生物学解读**：
- 噬菌体与KO之间存在**广泛的关联**
- 这些关联可能反映噬菌体-宿主细菌的共变化
- 正相关：可能是溶原状态下的共存
- 负相关：可能是裂解周期的捕食关系

### 3.5 热图可视化

```r
pheatmap(
  cor_subset,
  color = colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(100),
  display_numbers = sig_marks,  # 显著性标记
  main = "Phage-KO Correlation Heatmap"
)
```

**热图解读**：
- 红色：正相关
- 蓝色：负相关
- `**`：FDR < 0.05
- `*`：FDR < 0.10
- `.`：FDR < 0.25

---

## 4. 噬菌体-Pathway关联分析

### 4.1 与KO分析的区别

| 分析 | 粒度 | 目的 |
|------|------|------|
| 噬菌体-KO | 精细 | 识别具体基因功能 |
| 噬菌体-Pathway | 粗 | 识别代谢通路模式 |

### 4.2 结果

| FDR阈值 | 显著关联数 |
|---------|------------|
| < 0.05 | ~300对 |
| < 0.10 | ~500对 |
| < 0.25 | ~800对 |

**为什么Pathway关联少于KO？**
- Pathway是多个KO的聚合
- 体现了**功能冗余**——不同KO组合实现相同通路
- 通路水平更稳定，不易与单个噬菌体产生强关联

---

## 5. 三角互作网络分析

### 5.1 网络构建逻辑

```
三角互作网络
├── 细菌-KO边：哪些细菌贡献哪些功能？
├── 细菌-噬菌体边：哪些噬菌体感染哪些细菌？
└── 噬菌体-KO边：噬菌体与哪些功能相关？
```

### 5.2 计算三种关联

```r
# 细菌-KO关联
cor_bacteria_ko <- cross_rcorr(bacteria_t, ko_t)

# 细菌-噬菌体关联
cor_bacteria_phage <- cross_rcorr(bacteria_t, phage_t)

# 噬菌体-KO关联（前面已计算）
cor_phage_ko <- cross_rcorr(phage_t, ko_t)
```

### 5.3 创建网络边

```r
# 阈值设置
cor_threshold <- 0.5   # 相关系数绝对值阈值
fdr_threshold <- 0.25  # FDR阈值

# 创建边列表
edges_bacteria_ko <- corr_to_edges(cor_bacteria_ko, cor_threshold, fdr_threshold)
edges_bacteria_phage <- corr_to_edges(cor_bacteria_phage, cor_threshold, fdr_threshold)
edges_phage_ko <- corr_to_edges(cor_phage_ko, cor_threshold, fdr_threshold)

# 合并
edges_df <- bind_rows(edges_bacteria_ko, edges_bacteria_phage, edges_phage_ko)
```

### 5.4 网络可视化

```r
# 使用igraph和ggraph
g <- graph_from_data_frame(edges_df, vertices = nodes_df)

ggraph(g, layout = "fr") +
  geom_edge_link(aes(color = type)) +
  geom_node_point(aes(color = type), size = 5) +
  geom_node_text(aes(label = label), repel = TRUE)
```

### 5.5 网络特征

| 边类型 | 数量 | 含义 |
|--------|------|------|
| 细菌-KO | 最多 | 细菌是功能的直接贡献者 |
| 细菌-噬菌体 | 中等 | 宿主-病毒关系 |
| 噬菌体-KO | 较少 | 间接的功能关联 |

**网络拓扑解读**：
- 高度连通：微生物组各层次紧密联系
- Hub节点：某些细菌/噬菌体连接多个功能
- 模块结构：功能相关的类群聚集

---

## 6. 结果汇总与生物学意义

### 6.1 主要发现

```
┌─────────────────────────────────────────────────────────────┐
│  03b分析核心发现                                             │
│                                                              │
│  1. 噬菌体-功能关联广泛存在                                   │
│     - 噬菌体-KO: ~2800对显著关联 (FDR<0.05)                   │
│     - 噬菌体-Pathway: ~300对显著关联                          │
│                                                              │
│  2. 细菌-噬菌体协同模式                                       │
│     - 正相关可能代表溶原共存                                   │
│     - 负相关可能反映裂解捕食                                   │
│                                                              │
│  3. 三角互作网络                                              │
│     - 高度连通，显示多层次紧密联系                            │
│     - 噬菌体可能通过调控细菌间接影响功能                      │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 支持的假说

**"噬菌体介导的功能调控"假说**：

```
CagA感染
    ↓
影响细菌群落结构（01分析证实）
    ↓
细菌-噬菌体协同变化（03分析发现）
    ↓
间接影响功能潜力（03b分析支持）
    ↓
但功能冗余使整体功能保持稳定（02分析结论）
```

### 6.3 研究局限性

| 局限 | 说明 | 建议 |
|------|------|------|
| 样本量小 | 仅9个共同样本 | 扩大样本量验证 |
| 极端相关值 | 部分r=1或-1 | 小样本导致，需谨慎解读 |
| 因果性 | 无法确定因果方向 | 需要实验验证 |
| 功能注释 | 噬菌体OTU缺乏详细注释 | 需要更好的数据库 |

---

## 7. 与前期分析的整合

### 7.1 四个分析模块的关系

```
01分析：物种是谁？
    → 细菌Beta多样性显著变化
    → 病毒无显著变化
        ↓
02分析：能做什么？
    → 功能冗余现象
    → 物种-功能78对关联
        ↓
03分析：进化关系？
    → UniFrac证实群落差异
    → 细菌-噬菌体协同动态
        ↓
03b分析：三角整合
    → 噬菌体-功能广泛关联
    → 细菌-噬菌体-功能网络
```

### 7.2 整合结论

| 分析 | 主要发现 | 03b的补充 |
|------|----------|-----------|
| 01 物种 | CagA重塑细菌群落 | 噬菌体也呈现类似模式 |
| 02 功能 | 功能冗余 | 功能变化部分可由噬菌体-宿主互作解释 |
| 03 多样性 | 细菌-噬菌体协同 | 量化了这种协同的功能影响 |

### 7.3 PC047项目完整图景

```
┌─────────────────────────────────────────────────────────────┐
│  CagA对肠道微生物组的影响（四分析整合）                       │
│                                                              │
│  物种层面：                                                   │
│  ✓ 细菌群落重组 (P=0.012)                                    │
│  ✗ 病毒组无显著变化                                          │
│                                                              │
│  功能层面：                                                   │
│  ✓ 整体功能稳定（功能冗余）                                   │
│  ✓ 物种-功能存在强关联                                       │
│                                                              │
│  互作层面：                                                   │
│  ✓ 细菌-噬菌体协同动态                                       │
│  ✓ 三角互作网络高度连通                                       │
│                                                              │
│  结论：CagA通过重塑细菌群落结构影响微生物组                   │
│        但功能冗余机制维持了整体代谢潜力的稳定                  │
│        噬菌体可能参与但不是主要驱动因素                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 关键术语速查表

| 术语 | 英文 | 简单解释 |
|------|------|----------|
| 三角互作 | Tripartite Interaction | 细菌-噬菌体-功能三方关联 |
| Spearman相关 | Spearman Correlation | 基于秩次的相关系数 |
| FDR | False Discovery Rate | 假发现率，多重检验校正 |
| Hub节点 | Hub Node | 网络中连接最多的节点 |
| 溶原 | Lysogenic | 噬菌体整合到细菌基因组的状态 |
| 裂解 | Lytic | 噬菌体复制后裂解细菌的状态 |
| cross_rcorr | - | 自定义的跨矩阵相关性函数 |
| corr_to_edges | - | 将相关性结果转换为网络边 |

---

## 方法学亮点

### OMA风格的辅助函数

本分析开发了三个可复用的辅助函数：

1. **cross_rcorr()**: 计算两个矩阵之间的Spearman相关性
2. **corr_to_df()**: 将相关性矩阵转换为长格式数据框
3. **corr_to_edges()**: 从相关性结果创建网络边

这些函数遵循OMA的设计原则：
- 向量化计算，提高效率
- 自动FDR校正
- 输出格式标准化

---

**分析链完成**：01 → 02 → 03 → 03b，形成完整的PC047微生物组分析框架。

---

*笔记由 Claude 协助整理 | 参考 OMA Chapter 21, 02/03分析结果*
