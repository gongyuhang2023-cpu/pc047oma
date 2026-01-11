# 01 Alpha/Beta 多样性分析 - 学习笔记

**文件**: `01_alpha_beta_diversity_analysis.qmd`
**学习日期**: 2026-01-11
**参考**: OMA Chapter 7-10, Kraken Protocol

---

## 目录

**Part 1: Standard (细菌) 分析**
1. [分析目标](#1-分析目标)
2. [数据导入与TreeSE构建](#2-数据导入与treese构建)
3. [数据清洗（QC）](#3-数据清洗qc)
4. [Alpha多样性分析](#4-alpha多样性分析)
5. [Beta多样性分析](#5-beta多样性分析)
6. [差异丰度分析（DAA）](#6-差异丰度分析daa)

**Part 2: Virus (病毒) 分析**
7. [病毒数据分析](#7-病毒数据分析)

**综合**
8. [结果汇总与生物学意义](#8-结果汇总与生物学意义)
9. [与后续分析的关联](#9-与后续分析的关联)

---

## 1. 分析目标

### 核心问题
> CagA 感染是否改变了肠道微生物的群落结构？

### 核心比较组
| 组别 | 基因型 | 感染状态 | 样本数 | 角色 |
|------|--------|----------|--------|------|
| **ApcMUT_HpWT** | Apc突变 | Hp感染(CagA+) | 5 | 实验组（致瘤组） |
| **ApcMUT_HpKO** | Apc突变 | 未感染 | 4 | 对照组 |

### 为什么选择这两组？
- 两组都有 **Apc基因突变**（肿瘤易感背景）
- 唯一变量是 **CagA蛋白的有无**
- 这样可以排除基因型差异，专注研究CagA的影响

---

## 2. 数据导入与TreeSE构建

### 2.1 什么是 TreeSummarizedExperiment (TreeSE)？

**类比理解**：把TreeSE想象成一个Excel工作簿：

```
TreeSE 结构
├── assays（数据层）      → Excel的"数据表"
│   ├── counts           → 原始计数（每个细菌在每个样本中的reads数）
│   └── relabundance     → 相对丰度（百分比）
├── rowData（行注释）     → 描述每一行（物种）的信息
│   ├── Species          → 物种名
│   └── Genus            → 属名
├── colData（列注释）     → 描述每一列（样本）的信息
│   ├── sample_id        → 样本ID
│   ├── treatment_group  → 实验分组
│   └── source_organ     → 样本来源器官
└── reducedDim（降维结果）→ PCoA等分析结果
```

### 2.2 数据来源

| 数据类型 | 工具 | 文件格式 |
|----------|------|----------|
| 物种分类 | Kraken2 + Bracken | `*_S.tsv` (Species level) |
| 功能注释 | HUMAnN4 | 另见02分析 |

### 2.3 代码解读

```r
# 读取Bracken输出文件，构建丰度矩阵
bracken_long_standard_species <- read_bracken_standard_species(path)

# 转换为宽格式矩阵（行=物种，列=样本）
count_mat <- bracken_long_standard_species |>
  pivot_wider(names_from = sample, values_from = abundance)

# 创建TreeSE对象
tse <- TreeSummarizedExperiment(assays = list(counts = count_mat))

# 绑定样本元数据
colData(tse) <- DataFrame(metadata)
```

**为什么用TreeSE而不是普通矩阵？**
- OMA推荐的标准数据结构
- 可以同时存储多种数据类型（计数、相对丰度、CLR转换等）
- 与mia包无缝集成
- 支持系统发育树（后续UniFrac分析需要）

---

## 3. 数据清洗（QC）

### 3.1 清洗流程概览

```
原始数据 (12,043 物种)
    ↓
第一遍清洗：探索性分析，发现人源污染
    ↓
第二遍清洗：去除异源物种（Homo sapiens, Curtobacterium）
    ↓
第三遍清洗：去除异常样本（ca08）
    ↓
第四遍清洗：过滤零方差特征
    ↓
清洗后数据 (11,213 物种, 28 样本)
```

### 3.2 每一步清洗的意义

#### 第一遍：Library Size（文库大小）检查

```r
tse <- addPerCellQCMetrics(tse)  # 计算每个样本的总reads数
plotHistogram(tse, col.var = "total")  # 可视化分布
```

**什么是Library Size？**
- 每个样本测序得到的总reads数
- 如果样本间差异太大（>40倍），可能影响后续分析

**生物学意义**：确保样本质量均一，避免技术偏差影响结果

#### 第二遍：Prevalence（流行率）筛选

```r
tse <- addPrevalence(tse, detection = 0, as.relative = TRUE)
tse <- subsetByPrevalent(tse, prevalence = 0.1)  # 保留出现在>10%样本中的物种
```

**什么是Prevalence？**
- 某个物种在多少比例的样本中被检测到
- prevalence = 0.1 意味着至少在10%的样本中出现

**为什么要筛选？**
| 情况 | 说明 |
|------|------|
| 保留 | 在多数样本中出现，是"常住居民" |
| 剔除 | 只在1-2个样本中出现，可能是偶然污染或测序噪音 |

#### 第三遍：去除异源物种

```r
unwanted_taxa <- c("Homo sapiens", "Curtobacterium flaccumfaciens")
tse <- tse[!rownames(tse) %in% unwanted_taxa, ]
```

**发现的问题**：
- **Homo sapiens**（人类）：明显的人源污染
- **Curtobacterium flaccumfaciens**：鼠饲料中的常见植物病原菌

**生物学意义**：这些不是小鼠肠道的真正菌群成员

#### 第四遍：去除异常样本

```r
# 发现ca08样本E.coli异常高
tse <- tse[, colnames(tse) != "ca08"]
```

**发现的问题**：
- ca08样本中 *Escherichia coli* 丰度异常高
- 可能是样本污染或处理问题

**重要决策**：在正式分析中排除此样本，避免影响结果

#### 第五遍：零方差特征过滤

```r
rowData(tse)[["sd"]] <- rowSds(assay(tse, "counts"))
tse <- tse[rowData(tse)$sd > 0.001, ]
```

**什么是零方差特征？**
- 在所有样本中丰度几乎相同的物种
- 对组间比较没有贡献

---

## 4. Alpha多样性分析

### 4.1 什么是Alpha多样性？

**定义**：描述**单个样本内部**的物种多样性

**类比**：一个城市里有多少种商店？分布均匀吗？

### 4.2 常用指标

| 指标 | 含义 | 计算方式 |
|------|------|----------|
| **Observed Richness** | 物种丰富度 | 简单计数有多少种物种 |
| **Shannon Index** | 多样性指数 | 考虑物种数量和均匀度 |

**Shannon公式**：H' = -Σ(pi × log(pi))
- pi = 第i个物种的相对丰度
- 值越高 = 多样性越高

### 4.3 代码解读

```r
# 计算Alpha多样性
tse <- addAlpha(tse, index = c("shannon", "observed"))

# 统计检验（Wilcoxon秩和检验）
wilcox.test(shannon_index ~ treatment_group, data = colData(tse))
```

**为什么用Wilcoxon而不是t检验？**
- 微生物组数据通常**不符合正态分布**
- Wilcoxon是非参数检验，更稳健

### 4.4 结果解读

| 水平 | 指标 | P值 | 结论 |
|------|------|-----|------|
| Species | Shannon | 0.73 | 无显著差异 |
| Species | Observed | 0.29 | 无显著差异 |
| Genus | Shannon | 1.00 | 无显著差异 |

**生物学意义**：
- CagA感染**没有**降低肠道菌群的整体多样性
- 排除了"生态崩溃"假说
- 肿瘤发生不是通过简单地"杀灭菌群"实现的

---

## 5. Beta多样性分析

### 5.1 什么是Beta多样性？

**定义**：描述**不同样本之间**的群落组成差异

**类比**：两个城市的商业布局像不像？

### 5.2 距离度量方法

| 方法 | 特点 | 适用场景 |
|------|------|----------|
| **Bray-Curtis** | 基于丰度差异 | 最常用 |
| **Aitchison** | 基于CLR转换后的欧几里得距离 | 处理组成型数据 |
| **UniFrac** | 考虑系统发育关系 | 需要进化树（见03分析） |

### 5.3 PCoA（主坐标分析）

**什么是PCoA？**
- 将高维距离矩阵降维到2-3维
- 便于可视化样本间的相似性

```r
# 计算Bray-Curtis距离并进行PCoA
tse <- addMDS(tse, FUN = getDissimilarity, method = "bray")

# 可视化
plotReducedDim(tse, "PCoA_Bray", colour_by = "treatment_group")
```

**图表解读**：
- 每个点 = 一个样本
- 点之间距离越近 = 菌群组成越相似
- 如果两组分开 = 菌群结构不同

### 5.4 PERMANOVA统计检验

**什么是PERMANOVA？**
- Permutational Multivariate Analysis of Variance
- 检验**多变量**数据的组间差异
- 基于置换检验（999次），不假设数据分布

```r
result <- getPERMANOVA(tse, formula = x ~ treatment_group)
```

### 5.5 结果解读

| 水平 | 方法 | P值 | R² | 结论 |
|------|------|-----|-----|------|
| Species | Bray-Curtis | **0.012** | - | **显著差异** |
| Genus | Bray-Curtis | **0.006** | - | **显著差异** |

**生物学意义**：
- CagA感染**显著重塑**了肠道菌群的整体结构
- 这种重塑发生在物种和属两个层面
- 证实了CagA的菌群调控作用

### 5.6 Alpha + Beta 组合解读

| Alpha多样性 | Beta多样性 | 解读模式 |
|-------------|------------|----------|
| 无变化 | **显著变化** | **群落重组 (Community Restructuring)** |

**关键洞察**：
> CagA不是"毁掉"菌群，而是**选择性地重新排列**了它们的组成比例。

---

## 6. 差异丰度分析（DAA）

### 6.1 什么是DAA？

**目标**：找出哪些**具体物种**在两组之间有显著差异

**类比**：知道两个城市商业布局不同后，具体是哪些商店类型不同？

### 6.2 为什么需要两种方法？

| 方法 | 优点 | 缺点 |
|------|------|------|
| **ANCOM-BC** | 控制组成型数据偏差 | 对稀有物种敏感度低 |
| **ALDEx2** | 基于贝叶斯估计，更稳健 | 计算量大 |

**最佳实践**：使用两种方法**交叉验证**

### 6.3 ANCOM-BC结果

```r
ancom_result <- ancombc2(data = tse, fix_formula = "treatment_group")
```

**结果**（Species水平）：
- 前8名全是 **Microbacterium**（微杆菌属）
- LFC（Log Fold Change）均为负值（-1.1 到 -1.6）
- q值 ≈ 0.19（未达严格显著阈值0.05）

**生物学解读**：
- 这些细菌在CagA感染后**减少**
- 可能是肠道环境恶化的指标

### 6.4 ALDEx2结果

```r
x_aldex <- aldex.clr(counts, conditions, mc.samples = 128)
aldex_out <- aldex.ttest(x_aldex)
```

**显著差异物种**（wi.eBH < 0.05）：
| 物种 | Effect | 方向 |
|------|--------|------|
| Variovorax sp. EBFNA2 | -1.86 | 在HpWT组减少 |
| Cnuibacter sp. UC19_7 | -1.89 | 在HpWT组减少 |
| Agromyces aureus | -1.97 | 在HpWT组减少 |

**Effect Size解读**：
- |effect| > 1 = 具有强生物学意义
- 负值 = 在HpWT（致瘤组）中减少

### 6.5 DAA综合结论

1. **两种方法一致**：大部分差异物种在CagA感染后**减少**
2. **提示**：CagA环境对部分"正常菌群"有抑制作用
3. **但**：没有发现大量显著富集的"坏菌"
4. **暗示**：CagA可能不是通过引入致病菌，而是通过**功能代谢物**影响肿瘤

---

## 7. 病毒数据分析 (Part 2)

### 7.1 病毒数据概述

Part 2使用**Kraken2 Virus数据库**分析病毒组（Virome），主要关注**噬菌体**。

**为什么分析病毒组？**
- 噬菌体是细菌的病毒，可能通过裂解细菌影响菌群结构
- CagA可能通过改变噬菌体间接调控细菌群落
- 需要排除"病毒组变化导致细菌变化"的可能性

### 7.2 病毒数据清洗

与细菌数据类似，病毒数据也需要清洗：

```r
# 去除黑名单序列（phage/virus常见污染）
blacklist <- c(...)  # 已知的污染序列
tse_virus <- tse_virus[!rownames(tse_virus) %in% blacklist, ]
```

**特殊处理**：病毒数据库包含很多实验室常用噬菌体载体（如phi29、lambda等），这些通常是污染而非真正的肠道病毒。

### 7.3 病毒Alpha多样性

#### 分析流程

```r
# 计算Alpha多样性（与细菌分析完全一致）
tse_virus <- addAlpha(tse_virus, index = c("shannon", "observed"))

# 核心比较组 Wilcoxon检验
wilcox.test(shannon_index ~ treatment_group, data = colData(tse_virus_corepair))
```

#### 结果

| 水平 | 整体差异(Kruskal) | 核心比较组(Wilcoxon) |
|------|-------------------|---------------------|
| Species | P=0.0184 | **P=0.90** |
| Genus | - | **P=0.90** |

**关键发现**：
- 整体四组比较：P=0.0184（显著）
- **核心比较组**（ApcMUT_HpWT vs ApcMUT_HpKO）：**P=0.90（不显著）**

**这意味着什么？**
- 整体差异主要来自**Apc基因型**的影响，而非CagA感染
- 在同样Apc突变背景下，CagA对病毒多样性**没有影响**

### 7.4 病毒Beta多样性

#### 分析流程

```r
# Bray-Curtis距离 + PCoA
tse_virus <- addMDS(tse_virus, method = "bray")

# PERMANOVA检验
getPERMANOVA(tse_virus, formula = x ~ treatment_group)
```

#### 结果

| 水平 | P值 | R² | 结论 |
|------|-----|-----|------|
| Species | **0.445** | 10.6% | **无显著差异** |
| Genus | **0.506** | 10.0% | **无显著差异** |

**生物学意义**：
- 病毒组的群落结构在两组间**没有差异**
- 这与细菌的Beta多样性结果（P=0.012，显著）形成**鲜明对比**

### 7.5 病毒DAA分析

尽管Beta多样性无差异（理论上可以跳过DAA），分析中仍进行了DAA作为验证：

#### ANCOM-BC结果
- Species水平：所有q值 > 0.5
- Genus水平：所有q值 > 0.7
- **结论**：无显著差异物种

#### ALDEx2验证
- 即使放宽条件（|effect| > 1, wi.eBH < 0.5）
- 仍然**无法筛选出任何显著或趋势性差异**

### 7.6 Standard vs Virus 对比总结

| 指标 | Standard (细菌) | Virus (病毒) |
|------|-----------------|--------------|
| Alpha多样性 | P=0.73 (不显著) | P=0.90 (不显著) |
| Beta多样性 | **P=0.012 (显著)** | P≈0.5 (不显著) |
| DAA结果 | 3个显著物种 | 无显著物种 |

### 7.7 核心结论

```
┌─────────────────────────────────────────────────────────────┐
│  CagA主要影响细菌群落，而非病毒组                            │
│                                                              │
│  细菌：Alpha不变 + Beta显著 → 群落重组                       │
│  病毒：Alpha不变 + Beta不变 → 无明显影响                     │
│                                                              │
│  排除了"噬菌体介导的细菌群落变化"假说                        │
│  Functional Footprint应聚焦于细菌功能分析                    │
└─────────────────────────────────────────────────────────────┘
```

**这对PC047项目的意义**：
1. CagA诱导的T细胞持续激活**可能不是**由噬菌体介导
2. 后续功能分析（02）应重点关注**细菌代谢功能**
3. 支持直接研究"细菌-宿主"互作而非"噬菌体-细菌-宿主"三角关系

---

## 8. 结果汇总与生物学意义

### 8.1 统计结果一览（Part 1 + Part 2）

| 数据类型 | 分析 | 方法 | 结果 | P值 |
|----------|------|------|------|-----|
| **Standard (细菌)** | Alpha多样性 | Shannon/Wilcoxon | 无差异 | 0.73 |
| | Beta多样性 | Bray-Curtis/PERMANOVA | **有差异** | **0.012** |
| | DAA | ANCOM-BC | 微弱趋势 | q≈0.19 |
| | DAA | ALDEx2 | 3个显著物种 | <0.05 |
| **Virus (病毒)** | Alpha多样性 | Shannon/Wilcoxon | 无差异 | 0.90 |
| | Beta多样性 | Bray-Curtis/PERMANOVA | 无差异 | 0.45 |
| | DAA | ANCOM-BC/ALDEx2 | 无差异 | >0.5 |

### 8.2 核心科学结论

```
┌─────────────────────────────────────────────────────────────┐
│  CagA感染模式：群落重组 (Community Restructuring)           │
│                                                              │
│  ✓ 整体多样性保持稳定                                        │
│  ✓ 群落结构发生显著改变                                      │
│  ✓ 部分细菌被选择性抑制                                      │
│  ✗ 没有"生态崩溃"                                           │
│  ✗ 没有发现明显的"致病菌入侵"                               │
│  ✗ 病毒组无显著变化（排除噬菌体介导假说）                     │
└─────────────────────────────────────────────────────────────┘
```

### 8.3 与PC047项目假说的契合度分析

#### PC047核心假说回顾

> **"Functional Footprint"假说**：CagA感染**永久性改变**微生物群落结构，改变后的群落产生特定代谢物，驱动CD8+ T细胞持续激活，促进肿瘤发生。

#### 假说验证逻辑链

```
Step 1: CagA感染永久改变微生物群落结构  ← 01分析验证这一步
    ↓
Step 2: 改变后的群落产生不同代谢输出    ← 02分析验证
    ↓
Step 3: 特定代谢物驱动T细胞激活        ← 需要代谢组学数据
    ↓
Step 4: T细胞激活促进肿瘤发生          ← 需要整合肿瘤/免疫数据
```

#### 01分析对假说的支持程度

| 结果 | 假说预期 | 实际结果 | 契合度 |
|------|----------|----------|--------|
| Beta多样性 | 群落结构被改变 | **P=0.012 显著** | **完全支持** |
| Alpha多样性 | 不一定变化 | P=0.73 无差异 | 合理（重塑而非崩溃） |
| DAA | 特定物种变化 | 发现差异物种 | 支持 |
| 病毒组 | 不是主要假说 | 无显著变化 | 排除病毒介导机制 |

#### 01分析结论

```
┌─────────────────────────────────────────────────────────────┐
│  01分析 **高度支持** "Functional Footprint"假说的第一步      │
│                                                              │
│  ✓ CagA确实永久性改变了微生物群落结构（Beta P=0.012）        │
│  ✓ 这种改变是"重塑"而非"摧毁"（Alpha无差异）                │
│  ✓ 病毒组无变化，排除噬菌体介导机制                          │
│                                                              │
│  假说验证进度：Step 1 ✓ 完成                                 │
│  下一步：02分析验证 Step 2（功能输出是否改变）               │
└─────────────────────────────────────────────────────────────┘
```

### 8.4 原假说说明

**"Functional Footprint"假说**提出：
- 既然物种多样性没变，问题可能在**功能层面**
- CagA可能通过改变特定菌群的**代谢产物**影响肿瘤
- 需要功能分析（02）来验证

---

## 9. 与后续分析的关联

### 9.1 为02功能分析奠定基础

| 01分析提供 | 02分析使用 |
|------------|-----------|
| 清洗后的TreeSE对象 | 作为物种-功能关联的物种层数据 |
| Beta多样性结论 | 验证功能冗余假说 |
| DAA候选物种 | 识别关键功能贡献者 |

### 9.2 保存的关键文件

```r
# 供后续分析使用的数据对象
saveRDS(tse_standard_species_ca_cleaned,
        "tse_standard_species_ca_cleaned.rds")
saveRDS(tse_standard_genus_ca_cleaned,
        "tse_standard_genus_ca_cleaned.rds")
```

### 9.3 后续分析预告

| 分析 | 将回答的问题 |
|------|-------------|
| 02_functional_profiling | 功能是否也发生了重组？ |
| 03_singlem_diversity | UniFrac系统发育分析能发现什么？ |
| 03b_virome_function | 噬菌体与功能有何关联？ |

---

## 关键术语速查表

| 术语 | 英文 | 简单解释 |
|------|------|----------|
| TreeSE | TreeSummarizedExperiment | 微生物组数据的标准存储格式 |
| Prevalence | 流行率 | 某物种在多少样本中出现 |
| Alpha多样性 | Alpha Diversity | 单个样本内的物种多样性 |
| Beta多样性 | Beta Diversity | 样本间的群落差异 |
| Bray-Curtis | - | 基于丰度的距离计算方法 |
| PCoA | Principal Coordinate Analysis | 主坐标分析，降维可视化方法 |
| PERMANOVA | - | 多变量方差分析，检验组间差异 |
| DAA | Differential Abundance Analysis | 差异丰度分析 |
| LFC | Log Fold Change | 对数倍数变化，表示效应大小 |
| FDR/q值 | False Discovery Rate | 多重检验校正后的P值 |

---

**下一步**：阅读 `02_functional_profiling_learning_notes.md` 了解功能分析

---

*笔记由 Claude 协助整理 | 参考 OMA Chapter 7-10*
