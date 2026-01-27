# QMD 叙事框架模板

本文档定义了PC047项目所有分析QMD文件的标准结构。

## 核心叙事主线

**Functional Footprint假说**：H. pylori CagA来了又走了，但在肠道微生物组中留下了"功能足迹"。
这种微生物组改变可能是CagA特异性CD8+ T细胞持续活化的驱动因素。

## 标准QMD结构

```
---
title: "Part X: [分析名称]"
subtitle: "PC047 vCagAepitope - [简短描述]"
author: "[作者]"
date: today
format:
  html:
    code-fold: true
    toc: true
    toc-depth: 3
execute:
  warning: false
  message: false
---

## 1 研究问题 {#sec-question}

> **核心问题**：[本分析要回答的具体问题]
>
> **假说**：[基于functional footprint的预期]

### 1.1 分析背景

[为什么需要这个分析？与整体研究目标的关系]

### 1.2 预期发现

- [预期1]
- [预期2]

---

## 2 方法概述 {#sec-methods}

### 2.1 分析方法选择

| 分析内容 | 方法 | 选择理由 |
|---------|------|----------|
| [内容1] | [方法1] | [理由1] |

### 2.2 实验设计

**2×3 因子设计**:
- **基因型**: Apc^Min/+ vs WT
- **感染**: HpWT (CagA+) vs HpKO (CagA-) vs Mock

**核心比较组**（本研究重点）:
- ApcMUT_HpWT (n=5): CagA+ 感染
- ApcMUT_HpKO (n=4): CagA- 对照

### 2.3 统计阈值

- α = 0.05（显著性）
- FDR < 0.1（多重校正后）

---

## 3 环境设置 {#sec-setup}

### 3.1 包加载

```{r setup}
#| code-fold: false

# 数据处理
library(tidyverse)
library(here)

# [领域特定包]

# 可视化
library(ggplot2)
library(patchwork)
library(ggsci)

# 显式命名空间（避免冲突）
# dplyr::select(), dplyr::filter()
# base::intersect(), base::setdiff()
```

### 3.2 全局设置

```{r theme-setup}
# Nature标准主题
theme_publication <- function(base_size = 14) {
  theme_bw(base_size = base_size) +
  theme(
    text = element_text(family = "Helvetica"),
    plot.title = element_text(size = rel(1.0), face = "bold"),
    axis.title = element_text(size = rel(0.9)),
    axis.text = element_text(size = rel(0.8)),
    legend.title = element_text(size = rel(0.85)),
    legend.text = element_text(size = rel(0.75)),
    panel.grid.minor = element_blank()
  )
}

theme_set(theme_publication())

# 配色
npg_colors <- ggsci::pal_npg("nrc")(10)
```

### 3.3 数据加载

```{r load-data}
# 从上游分析加载清洗后的数据
# data <- readRDS(here::here("data", "XX_analysis", "cleaned_data.rds"))
```

---

## 4 数据概览 {#sec-overview}

### 4.1 样本信息

```{r sample-summary}
# 样本数量和分组
```

### 4.2 数据质量

```{r quality-check}
# 数据完整性检查
```

---

## 5 结果 {#sec-results}

### 5.1 [主要分析1]

#### 5.1.1 分析过程

```{r analysis-1}
# 分析代码
```

#### 5.1.2 结果可视化

```{r fig-1}
#| fig-cap: "Figure X. [描述]"
#| fig-width: 7.2
#| fig-height: 5

# 绘图代码
```

#### 5.1.3 统计检验

```{r stats-1}
# 统计检验代码
```

> **关键发现**：[简要解读]

### 5.2 [主要分析2]

[同上结构...]

---

## 6 结果汇总 {#sec-summary}

### 6.1 主要发现

| 分析 | 结果 | P值 | 解读 |
|------|------|-----|------|
| [分析1] | [结果] | [P] | [解读] |

### 6.2 与假说的关系

[发现如何支持/反驳functional footprint假说]

### 6.3 局限性

- [局限1]
- [局限2]

---

## 7 下一步 {#sec-next}

基于本分析发现，后续分析应：

1. **[方向1]**: [描述]
2. **[方向2]**: [描述]

**关联分析文件**:
- 上游: `XX_previous_analysis.qmd`
- 下游: `XX_next_analysis.qmd`

---

## 8 输出保存 {#sec-output}

```{r save-outputs}
# 保存关键结果
# saveRDS(results, here::here("data", "XX_analysis", "results.rds"))

# 保存发表级图表
# ggsave("figure_X.png", plot = p,
#        width = 183, height = 120, units = "mm", dpi = 300)
```

---

## Session Info

```{r session-info}
sessionInfo()
```
```

---

## Part 编号规范

| Part | 分析内容 | 文件 |
|------|---------|------|
| 1 | Alpha/Beta多样性 (Bracken) | 01_alpha_beta_diversity_analysis.qmd |
| 2 | 功能谱分析 (HUMAnN4) | 02_functional_profiling.qmd |
| 2b | 扩展功能分析 (GO/PFAM) | 02b_extended_functional_analysis.qmd |
| 3 | SingleM/Lyrebird多样性 | 03_singlem_diversity_analysis.qmd |
| 3b | 病毒组整合分析 | 03b_virome_function_integration.qmd |
| 3c | 共现网络分析 | 03c_cooccurrence_network_analysis.qmd |

---

## 图表规范速查

### 尺寸
- 单栏: 89mm (3.5 inch)
- 双栏: 183mm (7.2 inch)
- DPI: 300

### 字体
- 正文: 5-7 pt
- 标签: 8 pt 粗体
- 字体: Helvetica/Arial

### 配色
```r
# NPG (推荐)
p + scale_color_npg() + scale_fill_npg()

# Lancet
p + scale_color_lancet() + scale_fill_lancet()
```

### ggsave
```r
# 双栏图
ggsave("figure.png", p, width = 183, height = 120, units = "mm", dpi = 300)

# 单栏图
ggsave("figure.png", p, width = 89, height = 70, units = "mm", dpi = 300)
```
