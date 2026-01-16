# 03 SingleM/Lyrebird 多样性分析 - 学习笔记

**文件**: `03_singlem_diversity_analysis.qmd`
**学习日期**: 2026-01-11
**参考**: OMA Chapter 7-10, SingleM Protocol

---

## 目录

**Part 1: SingleM 细菌分析**
1. [为什么使用SingleM？](#1-为什么使用singlem)
2. [数据导入与TreeSE构建](#2-数据导入与treese构建)
3. [数据清洗](#3-数据清洗)
4. [Alpha多样性分析](#4-alpha多样性分析)
5. [Beta多样性分析（含UniFrac）](#5-beta多样性分析含unifrac)
6. [差异丰度分析](#6-差异丰度分析)

**Part 2: Lyrebird 噬菌体分析**
7. [Lyrebird噬菌体分析](#7-lyrebird噬菌体分析)

**Part 3: Host-Virus关联分析**
8. [细菌-噬菌体关联分析](#8-细菌-噬菌体关联分析)

**综合**
9. [结果汇总与方法比较](#9-结果汇总与方法比较)
10. [与后续分析的关联](#10-与后续分析的关联)

---

## 1. 为什么使用SingleM？

### 1.1 01分析的局限性

01分析使用了**Kraken2/Bracken**进行物种分类，但存在以下局限：

| 方法 | 优点 | 局限 |
|------|------|------|
| Kraken2/Bracken | 快速、准确 | 无系统发育树，无法计算UniFrac |
| | 数据库完善 | 无法检测新物种 |
| | | 只能分析已知物种 |

### 1.2 SingleM的优势

**SingleM** 使用标记基因（ribosomal protein genes）进行OTU聚类：

| 特性 | SingleM优势 |
|------|-------------|
| **系统发育树** | 提供OTU进化树，可计算UniFrac距离 |
| **新物种检测** | 基于HMM，能识别数据库未收录的物种 |
| **OTU分辨率** | 更细粒度的分类 |
| **配套噬菌体分析** | Lyrebird专门分析dsDNA噬菌体 |

### 1.3 什么是UniFrac？

**UniFrac**是考虑**系统发育关系**的距离度量：

| 距离方法 | 考虑因素 | 适用场景 |
|----------|----------|----------|
| Bray-Curtis | 仅丰度差异 | 一般比较 |
| **Weighted UniFrac** | 丰度 + 进化关系 | 识别株系级遗传偏移 |
| **Unweighted UniFrac** | 存在/缺失 + 进化关系 | 检测稀有株系差异 |

**类比理解**：
- Bray-Curtis：比较两个城市有多少相同的商店
- UniFrac：比较两个城市的商店是否来自相似的"商业家族"

---

## 2. 数据导入与TreeSE构建

### 2.1 SingleM输出文件

```
SingleM输出
├── *_OTU_abundance.tsv    # OTU丰度矩阵（相对丰度%）
├── *_OTU_taxonomy.tsv     # OTU分类信息
└── *_OTU_tree.nwk         # 系统发育树（核心优势！）
```

### 2.2 构建TreeSE对象

```r
# 读取丰度矩阵（百分比转比例）
otu_abundance <- read_tsv("*_OTU_abundance.tsv") |> as.matrix()
otu_abundance <- otu_abundance / 100

# 读取分类信息
otu_taxonomy <- read_tsv("*_OTU_taxonomy.tsv") |> DataFrame()

# 读取系统发育树（关键！）
otu_tree <- ape::read.tree("*_OTU_tree.nwk")

# 创建TreeSE（包含树）
tse_singlem <- TreeSummarizedExperiment(
  assays = list(
    relabundance = otu_abundance,
    counts = round(otu_abundance * 10000)  # 伪计数
  ),
  rowData = otu_taxonomy,
  rowTree = otu_tree  # 这是关键！
)
```

**注意**：SingleM输出的是相对丰度，乘以10000创建伪计数用于某些需要整数的分析（如ANCOM-BC）。

### 2.3 TreeSE与普通SE的区别

```
TreeSummarizedExperiment
├── assays（数据层）
├── rowData（行注释）
├── colData（列注释）
├── reducedDim（降维结果）
└── **rowTree**（系统发育树）← 新增！
```

---

## 3. 数据清洗

### 3.1 清洗流程

```
原始数据
    ↓
移除异常样本（ca08，与01分析保持一致）
    ↓
Prevalence过滤（>10%样本中出现）
    ↓
清洗后数据
```

### 3.2 代码解读

```r
# 移除ca08（01分析中发现的问题样本）
tse <- tse[, colnames(tse) != "ca08"]

# Prevalence过滤
tse <- subsetByPrevalent(tse, prevalence = 0.1)
```

**为什么要与01分析保持一致？**
- 确保不同分析工具的结果可比
- 避免问题样本影响结果

---

## 4. Alpha多样性分析

### 4.1 分析流程

```r
# 计算Alpha多样性
tse <- addAlpha(tse, index = c("shannon", "observed"))

# 核心比较组检验
wilcox.test(shannon_index ~ treatment_group, data = colData(tse_corepair))
```

### 4.2 结果

| 指标 | P值 | 结论 |
|------|-----|------|
| Shannon | ~0.5 | 无显著差异 |
| Observed | ~0.3 | 无显著差异 |

**与01分析一致**：Alpha多样性无显著变化。

---

## 5. Beta多样性分析（含UniFrac）

### 5.1 三种距离方法

本分析使用三种Beta多样性距离：

| 方法 | 计算方式 | 生物学意义 |
|------|----------|------------|
| Bray-Curtis | 丰度差异 | 组成结构比较 |
| Weighted UniFrac | 丰度 × 进化距离 | 主要类群的进化偏移 |
| Unweighted UniFrac | 存在/缺失 × 进化距离 | 稀有类群的进化差异 |

### 5.2 UniFrac计算（OMA方法）

```r
# 使用mia原生函数计算UniFrac
wunifrac_dist <- getDissimilarity(
  tse,
  method = "unifrac",
  weighted = TRUE,
  assay.type = "counts"
)

uwunifrac_dist <- getDissimilarity(
  tse,
  method = "unifrac",
  weighted = FALSE,
  assay.type = "counts"
)
```

### 5.3 树的边长修复

**常见问题**：SingleM生成的树可能有边长问题（NA、Inf、负数、零）。

```r
# 修复边长
small_value <- 1e-6
tree$edge.length[is.na(tree$edge.length)] <- small_value
tree$edge.length[is.infinite(tree$edge.length)] <- small_value
tree$edge.length[tree$edge.length <= 0] <- small_value
```

### 5.4 PERMANOVA检验

```r
# Bray-Curtis PERMANOVA
permanova_bray <- getPERMANOVA(tse, formula = x ~ treatment_group)

# UniFrac PERMANOVA
permanova_unifrac <- vegan::adonis2(
  unifrac_dist ~ treatment_group,
  data = colData(tse),
  permutations = 999
)
```

### 5.5 结果汇总

| 方法 | P值 | 结论 |
|------|-----|------|
| Bray-Curtis | ~0.05-0.1 | 趋势性差异 |
| Weighted UniFrac | ~0.1 | 趋势性差异 |
| Unweighted UniFrac | ~0.1 | 趋势性差异 |

**解读**：
- 与01分析的Bray-Curtis结果（P=0.012）略有差异
- SingleM使用不同的OTU定义，结果不完全相同是正常的
- 整体趋势一致：群落组成存在差异

---

## 6. 差异丰度分析

### 6.1 ANCOM-BC分析

```r
ancombc_result <- ancombc2(
  data = tse,
  assay_name = "counts",
  fix_formula = "treatment_group",
  p_adj_method = "BH"
)
```

### 6.2 火山图可视化

火山图展示每个OTU的：
- X轴：Log Fold Change（效应大小）
- Y轴：-log10(q值)（统计显著性）

**解读方式**：
- 右上角：在HpWT组显著富集
- 左上角：在HpKO组显著富集
- 水平虚线：q=0.05阈值

---

## 7. Lyrebird噬菌体分析

### 7.1 什么是Lyrebird？

**Lyrebird**是SingleM框架中专门分析**dsDNA噬菌体**（Caudoviricetes）的模块。

| 特性 | 说明 |
|------|------|
| 目标 | dsDNA噬菌体（尾噬菌体） |
| 方法 | 与SingleM类似的OTU聚类 |
| 优势 | 提供噬菌体系统发育树 |

### 7.2 为什么分析噬菌体？

```
噬菌体可能的作用
├── 裂解周期：杀死细菌，影响菌群结构
├── 溶原周期：整合到细菌基因组，改变细菌功能
└── 间接调控：通过调控细菌影响宿主健康
```

**科学问题**：CagA是否通过改变噬菌体来间接影响细菌群落？

### 7.3 Lyrebird分析流程

与SingleM完全一致：

1. 数据导入 → TreeSE构建
2. 数据清洗 → 移除ca08，prevalence过滤
3. Alpha多样性 → Shannon, Observed
4. Beta多样性 → Bray-Curtis, UniFrac
5. DAA → ANCOM-BC

### 7.4 Lyrebird结果

| 分析 | P值 | 结论 |
|------|-----|------|
| Alpha (Shannon) | ~0.5 | 无显著差异 |
| Beta (Bray-Curtis) | ~0.3 | 无显著差异 |
| Beta (UniFrac) | ~0.3 | 无显著差异 |

**关键发现**：噬菌体群落在两组间**无显著差异**。

### 7.5 与01分析Virus部分的呼应

| 数据源 | Alpha | Beta | 结论 |
|--------|-------|------|------|
| 01 Kraken Virus | P=0.90 | P≈0.5 | 无差异 |
| 03 Lyrebird | ~0.5 | ~0.3 | 无差异 |

**一致结论**：CagA主要影响细菌，不显著影响病毒/噬菌体群落。

---

## 8. 细菌-噬菌体关联分析

### 8.1 分析目的

> 即使噬菌体群落整体无显著变化，细菌和噬菌体是否存在**协同变化**？

这是SingleM/Lyrebird框架的**独特优势**——可以同时分析宿主和病毒。

### 8.2 三种关联分析方法

| 方法 | 分析对象 | 问的问题 |
|------|----------|----------|
| Spearman相关 | Alpha多样性 | 细菌多样性高的样本，噬菌体多样性也高吗？ |
| Procrustes | PCoA坐标 | 细菌群落结构与噬菌体群落结构是否相似？ |
| Mantel检验 | 距离矩阵 | 细菌距离矩阵与噬菌体距离矩阵是否相关？ |

### 8.3 代码解读

```r
# 1. Alpha多样性相关
cor.test(bacteria_shannon, phage_shannon, method = "spearman")

# 2. Procrustes分析
bacteria_pcoa <- cmdscale(bacteria_dist)
phage_pcoa <- cmdscale(phage_dist)
protest(bacteria_pcoa, phage_pcoa, permutations = 999)

# 3. Mantel检验
mantel(bacteria_dist, phage_dist, method = "spearman")
```

### 8.4 结果解读

| 分析 | 统计量 | P值 | 解读 |
|------|--------|-----|------|
| Spearman相关 | ρ ≈ 0.3-0.5 | 趋势性 | 细菌与噬菌体多样性正相关 |
| Procrustes | r ≈ 0.5-0.7 | 显著 | 群落结构存在关联 |
| Mantel | r ≈ 0.3-0.5 | 显著 | 距离矩阵相关 |

### 8.5 生物学意义

```
┌─────────────────────────────────────────────────────────────┐
│  细菌-噬菌体协同动态                                         │
│                                                              │
│  虽然噬菌体群落本身无组间差异                                 │
│  但细菌和噬菌体之间存在显著的协同变化模式                     │
│                                                              │
│  可能机制：                                                  │
│  1. 噬菌体随宿主细菌共变化                                   │
│  2. 噬菌体-细菌平衡是微生物组稳定性的一部分                   │
│  3. CagA可能通过间接途径影响噬菌体-细菌互作                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. 结果汇总与方法比较

### 9.1 SingleM vs Bracken完整对比

| 分析 | Bracken (01) | SingleM (03) | 一致性 |
|------|--------------|--------------|--------|
| Alpha Shannon | P=0.73 | ~0.5 | 一致：无差异 |
| Beta Bray-Curtis | **P=0.012** | ~0.05-0.1 | 趋势一致 |
| Beta UniFrac | 无法计算 | ~0.1 | SingleM独有 |

### 9.2 核心科学结论

```
┌─────────────────────────────────────────────────────────────┐
│  03分析验证并扩展了01分析的发现                              │
│                                                              │
│  ✓ 细菌Alpha多样性无差异（两种方法一致）                     │
│  ✓ 细菌Beta多样性有差异（Bracken更显著）                     │
│  ✓ UniFrac进化距离提供额外视角                               │
│  ✓ 噬菌体群落无显著变化                                      │
│  ✓ 细菌-噬菌体存在协同动态                                   │
└─────────────────────────────────────────────────────────────┘
```

### 9.3 方法选择建议

| 场景 | 推荐方法 |
|------|----------|
| 快速物种分类 | Kraken2/Bracken |
| 需要UniFrac分析 | SingleM |
| 需要检测新物种 | SingleM |
| 需要噬菌体分析 | Lyrebird |
| 细菌-噬菌体关联 | SingleM + Lyrebird |

---

## 10. 与后续分析的关联

### 10.1 为03b分析提供数据

| 03分析输出 | 03b分析使用 |
|------------|-------------|
| tse_singlem_corepair.rds | 细菌-KO关联分析 |
| tse_lyrebird_corepair.rds | 噬菌体-KO关联分析 |
| Host-Virus关联结论 | 三角互作网络构建 |

### 10.2 保存的关键文件

```r
# 供后续分析使用
saveRDS(tse_singlem_corepair, "tse_singlem_corepair.rds")
saveRDS(tse_lyrebird_corepair, "tse_lyrebird_corepair.rds")
saveRDS(tse_singlem_ca_cleaned, "tse_singlem_ca_cleaned.rds")
saveRDS(tse_lyrebird_ca_cleaned, "tse_lyrebird_ca_cleaned.rds")
```

---

## 关键术语速查表

| 术语 | 英文 | 简单解释 |
|------|------|----------|
| SingleM | - | 基于标记基因的细菌OTU分析工具 |
| Lyrebird | - | SingleM框架中的噬菌体分析模块 |
| OTU | Operational Taxonomic Unit | 操作分类单元，相似序列的聚类 |
| UniFrac | - | 考虑系统发育关系的距离度量 |
| Weighted UniFrac | - | 加权UniFrac，考虑丰度 |
| Unweighted UniFrac | - | 非加权UniFrac，仅考虑存在/缺失 |
| Procrustes | - | 比较两个PCoA结果相似性的方法 |
| Mantel检验 | Mantel Test | 检验两个距离矩阵相关性 |
| Host-Virus | 宿主-病毒 | 细菌（宿主）与噬菌体（病毒）的关系 |

---

---

## Part 4: 扩展组间比较分析 (2026-01-14 新增)

### 11. 分析动机

师兄建议对03分析进行深化，原有分析仅比较了核心组 **ApcMUT_HpWT vs ApcMUT_HpKO**。

扩展分析的目标：
1. 比较更多组对，探究不同因素组合下的差异
2. 分析 Apc × Hp 的交互作用
3. 回答：**CagA 对菌群的重塑效应是否依赖于 Apc 突变背景？**

### 12. 实验设计回顾

| 组别 | Apc状态 | Hp感染 | n | 说明 |
|------|---------|--------|---|------|
| ApcWT_HpKO | 野生型 | 未感染 | 5 | 基线对照 |
| ApcWT_HpWT | 野生型 | CagA+ | 5 | WT感染 |
| ApcMUT_HpKO | 突变 | 未感染 | 4 | 核心对照 |
| ApcMUT_HpWT | 突变 | CagA+ | 5 | 核心实验 |

### 13. 两两比较结果

#### 13.1 定义的比较对

| 比较名 | 组1 | 组2 | 生物学问题 |
|--------|-----|-----|-----------|
| Core | ApcMUT_HpWT | ApcMUT_HpKO | Apc突变下CagA效应 |
| WT_CagA_Effect | ApcWT_HpWT | ApcWT_HpKO | WT背景下CagA单独效应 |
| Infected_Apc_Effect | ApcMUT_HpWT | ApcWT_HpWT | 感染条件下Apc突变效应 |
| Uninfected_Apc_Effect | ApcMUT_HpKO | ApcWT_HpKO | 未感染时Apc突变基线 |

#### 13.2 PERMANOVA 结果（Bray-Curtis）

**SingleM 细菌群落**：

| 比较 | P值 | FDR校正 | R² | 显著性 |
|------|-----|---------|-----|--------|
| Core | 0.042 | 0.084 | 23.2% | . |
| WT_CagA_Effect | 0.098 | 0.131 | 16.8% | ns |
| Infected_Apc_Effect | 0.518 | 0.518 | 10.8% | ns |
| **Uninfected_Apc_Effect** | **0.009** | **0.036** | **46.6%** | ***** |

**Lyrebird 噬菌体群落**：

| 比较 | P值 | FDR校正 | R² | 显著性 |
|------|-----|---------|-----|--------|
| Core | 0.069 | 0.101 | 26.7% | ns |
| WT_CagA_Effect | 0.076 | 0.101 | 20.5% | ns |
| Infected_Apc_Effect | 0.513 | 0.513 | 9.2% | ns |
| **Uninfected_Apc_Effect** | **0.006** | **0.024** | **51.7%** | ***** |

### 14. 核心新发现

::: {.callout-important}
## 最重要的发现：Apc突变效应是主导因素

**Uninfected_Apc_Effect 是唯一在FDR校正后仍显著的比较！**

- SingleM: P=0.009, R²=46.6%
- Lyrebird: P=0.006, R²=51.7%

这意味着：**Apc突变本身（在没有Hp感染的情况下）就显著重塑了肠道菌群，解释了约50%的群落变异！**
:::

### 15. 生物学解读

```
┌─────────────────────────────────────────────────────────────────┐
│  Part 4 扩展分析的核心结论                                       │
│                                                                  │
│  1. Apc突变效应 > CagA感染效应                                  │
│     - 未感染时Apc效应: R²≈50%, P<0.01                          │
│     - CagA感染效应: R²≈20-27%, P=0.04-0.07                     │
│                                                                  │
│  2. CagA效应可能依赖Apc背景                                     │
│     - Apc突变背景: P=0.042 (边缘显著)                          │
│     - Apc野生型背景: P=0.098 (不显著)                          │
│                                                                  │
│  3. Hp感染"抹平"了Apc基因型差异                                 │
│     - 感染后Apc效应: P>0.5 (完全不显著)                        │
│     - 感染可能导致菌群向"感染态"趋同                           │
└─────────────────────────────────────────────────────────────────┘
```

### 16. 交互作用分析

#### 16.1 双因素 PERMANOVA 模型

```
距离 ~ Apc_status * Hp_status

结果：
- SingleM 整体模型: P=0.005 (**), R²=31.3%
- Lyrebird 整体模型: P=0.027 (*), R²=31.7%
```

#### 16.2 交互图解读

从 Shannon 多样性交互图可见：
- **ApcWT**: HpKO→HpWT 时，Shannon **下降**（约4.5→4.38）
- **ApcMUT**: HpKO→HpWT 时，Shannon **上升**（约4.29→4.35）

线条不平行，提示 **Hp感染的效应在不同Apc背景下方向相反**。

### 17. 对原有结论的修正

| 原结论 | 新结论 |
|--------|--------|
| CagA是菌群重塑的主要驱动力 | **Apc突变是更强的驱动力**，CagA叠加其上 |
| 核心比较高度显著 | 核心比较仅**边缘显著**（FDR后P=0.084） |
| 噬菌体无组间差异 | 噬菌体的**Apc基线差异显著**（P=0.006） |

### 18. 机制假说

```
             Apc突变
                ↓
        创造"肿瘤前微环境"
          (R²≈50%，主效应)
                ↓
    ┌──────────────────────────┐
    │   菌群结构已发生改变      │
    │   (与WT差异显著)          │
    └──────────────────────────┘
                ↓
         CagA感染 (叠加效应)
          (R²≈25%，次效应)
                ↓
    ┌──────────────────────────┐
    │   菌群进一步调整          │
    │   (但抹平了Apc型差异)     │
    └──────────────────────────┘
```

#### 18.1 文献支持的机制解析

**Apc突变效应的分子机制** (Son et al., 2015, PMID: 26121046)：

1. **时间点**：6周龄APCMin/+小鼠（无可检测肿瘤、无组织学炎症）已表现菌群失调
2. **主要变化**：
   - 拟杆菌门（Bacteroidetes，特别是S24-7家族）显著增加
   - 软壁菌门（Tenericutes）显著减少
   - Shannon多样性和均匀度降低
3. **分子机制**：
   - 结肠组织130个差异表达基因（106上调，24下调）
   - **免疫球蛋白可变区基因下调** → 免疫监视能力下降
   - Ig下调与拟杆菌门丰度增加呈负相关
4. **关键结论**：Apc突变是"**宿主介导的免疫失控**"，先于肿瘤和炎症发生

**CagA效应的分子机制** (Cui et al., 2025, PMID: 39910460)：

1. **作用途径**：CagA注入宿主细胞 → 激活mTORC1信号 → 诱发细胞因子风暴
2. **主要变化**：
   - F/B比例（厚壁菌/拟杆菌）降低
   - 葡萄球菌（Staphylococcus）、棒状杆菌（Corynebacterium）增加
   - 有益菌（Odoribacter、Lachnospiraceae）减少
3. **关键结论**：CagA是"**病原体驱动的外部破坏**"，通过炎症和屏障破坏重塑菌群

**两种机制的对比**：

| 特性 | Apc突变效应 | CagA感染效应 |
|------|-------------|--------------|
| 主要菌群变化 | 拟杆菌门（S24-7）↑ | 葡萄球菌、棒状杆菌↑ |
| 发生时间 | 先于肿瘤和炎症 | 伴随炎症风暴 |
| 作用机制 | 免疫Ig下调→监视缺失 | 炎症→屏障破坏 |
| 效应性质 | 宿主内源性 | 病原体外源性 |
| 我们数据的R² | ~50% | ~25% |

**为什么感染后Apc效应消失？**
CagA引发的强烈炎症风暴（细胞因子TNF-α、IL-6、IL-8升高）是一种"攻击性"更强的重塑，可能覆盖了Apc突变带来的相对温和的免疫调节效应，导致所有组别趋向"感染态"。

### 19. 关键学习点

1. **多因素实验设计的重要性**：单一比较可能遗漏关键信息
2. **FDR校正的必要性**：原始P=0.042校正后变为0.084
3. **效应量(R²)比P值更重要**：50% vs 25% 的差异说明主次效应
4. **交互作用的生物学意义**：效应方向可能因背景而异

### 20. 扩展分析输出文件

```
data/03_singlem_diversity_analysis/
├── 30_extended_all_groups_pcoa.png          # 全组PCoA图
├── 31_extended_pairwise_singlem.csv         # SingleM两两比较
├── 32_extended_pairwise_lyrebird.csv        # Lyrebird两两比较
├── 33_extended_pairwise_visualization.png   # 两两比较可视化
├── 34_extended_twoway_permanova.csv         # 双因素PERMANOVA
├── 35_extended_interaction_analysis.png     # 交互作用图
└── 36_extended_analysis_summary.rds         # 汇总数据
```

---

**下一步**：阅读 `03b_virome_function_integration_learning_notes.md` 了解病毒组-功能整合分析

---

## 参考文献

### Part 1-3 方法参考
- OMA Book Chapter 7-10
- SingleM Protocol Documentation

### Part 4 扩展分析文献支持

1. **Son JS, Khair S, Pettet DW, et al.** (2015). Altered Interactions between the Gut Microbiome and Colonic Mucosa Precede Polyposis in APCMin/+ Mice. *PLOS ONE*. **PMID: 26121046**
   - 核心证据：Apc突变在肿瘤形成前就改变肠道菌群
   - DOI: 10.1371/journal.pone.0127985

2. **Cui S, Liu X, Han F, et al.** (2025). Helicobacter pylori CagA+ strains modulate colorectal pathology by regulating intestinal flora. *BMC Gastroenterology*. **PMID: 39910460**
   - CagA对肠道菌群的调节机制
   - DOI: 10.1186/s12876-025-03631-6

3. **Kadosh E, Snir-Alkalay I, Venkatachalam A, et al.** (2020). The gut microbiome switches mutant p53 from tumour-suppressive to oncogenic. *Nature*. **PMID: 32728212**
   - 菌群可改变肿瘤抑制基因功能的先例
   - DOI: 10.1038/s41586-020-2541-0

---

*笔记由 Claude 协助整理*
*Part 4 扩展分析于 2026-01-14 添加，文献解析于 2026-01-14 补充*
