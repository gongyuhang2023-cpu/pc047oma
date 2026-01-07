# PC047-OMA: CagA依赖性肿瘤发生中的肠道微生物组研究

**项目编号**: PC047
**项目名称**: vCagAepitope
**分析框架**: OMA (Orchestrating Microbiome Analysis) + bioBakery 3

---

## 项目概述

本项目使用**Apc基因突变小鼠模型**研究幽门螺杆菌（*Helicobacter pylori*）CagA蛋白在肿瘤发生过程中对肠道微生物组的影响。CagA是幽门螺杆菌的重要致癌因子，本研究旨在揭示CagA如何通过重塑肠道菌群来影响肿瘤微环境。

### 核心科学问题

1. CagA感染是否改变了肠道微生物的**群落结构**？
2. 群落结构的改变是否伴随**功能潜力**的变化？
3. 哪些**特定物种-功能关联**可能参与CagA的致瘤机制？

---

## 实验设计

### 实验分组

| Treatment Group | 基因型 | 感染状态 | 样本数 | 说明 |
|-----------------|--------|----------|--------|------|
| ApcWT_HpKO | Apc野生型 | 未感染 | 5 | 基线对照 |
| ApcWT_HpWT | Apc野生型 | Hp感染(CagA+) | 5 | 野生型感染 |
| **ApcMUT_HpKO** | Apc突变 | 未感染 | 4 | **核心对照组** |
| **ApcMUT_HpWT** | Apc突变 | Hp感染(CagA+) | 5 | **核心实验组** |
| ApcMUT_Ctrl | Apc突变 | 对照 | 4 | 参考组 |
| ApcWT_Ctrl | Apc野生型 | 对照 | 5 | 参考组 |

**核心比较**: ApcMUT_HpWT vs ApcMUT_HpKO（在Apc突变背景下比较CagA+感染与未感染的差异）

### 样本来源

- **组织类型**: Caecum (盲肠)
- **总样本数**: 28个（去除污染样本后）
- **排除样本**: ca08 (因E. coli异常高丰度被剔除)

---

## 分析流程

本项目遵循**OMA框架**和**bioBakery 3**分析协议：

```
原始数据 (FASTQ)
    │
    ├── Kraken2 + Bracken ──→ 物种组成分析 (01_alpha_beta_diversity_analysis)
    │                              ├── Alpha多样性: 群落复杂度评估
    │                              ├── Beta多样性: 群落结构差异检验
    │                              └── 差异丰度分析: 关键物种识别
    │
    └── HUMAnN4 ──────────→ 功能潜力分析 (02_functional_profiling)
                                   ├── 功能多样性: 代谢潜力差异
                                   ├── 通路/KO差异分析: 功能变化检测
                                   └── 物种-功能整合: 驱动物种识别
```

### 分析工具

| 工具 | 用途 | 参考协议 |
|------|------|----------|
| Kraken2 + Bracken | 物种分类注释 | Metagenome analysis using Kraken suite |
| HUMAnN4 | 功能通路注释 | HUMAnN4 Analysis Protocol |
| ANCOM-BC, ALDEx2, MaAsLin2 | 差异丰度分析 | OMA Chapter 14-15 |
| mia/vegan (R) | 多样性分析 | OMA Chapter 7-10 |

---

## 目录结构

```
pc047oma/
├── analyses/
│   ├── 00_analysis_summary_report.md    # 完整分析总结报告
│   ├── 01_alpha_beta_diversity_analysis.qmd  # Alpha/Beta多样性分析
│   ├── 02_functional_profiling.qmd      # 功能分析
│   ├── 03_strain_analysis.qmd           # 菌株分析
│   │
│   ├── data/                            # 数据文件（git忽略）
│   │   └── 01_alpha_beta_diversity_analysis/
│   │       ├── *.png                    # 分析图表
│   │       ├── *.csv                    # 统计结果
│   │       └── *.rds                    # TreeSE对象
│   │
│   ├── OMA BOOK/                        # OMA操作手册（28章）
│   └── Protocol/                        # 分析协议文档
│       ├── HUMAnN4_Analysis_Protocol.pdf
│       ├── Metagenome analysis using the Kraken software suite.pdf
│       └── singlem_and_lyrebird_analyses_protocal.pdf
│
├── DESCRIPTION                          # R包描述文件
├── NAMESPACE                            # R包命名空间
└── README.md                            # 本文件
```

---

## 主要发现

### 统计结果汇总

| 分析层面 | 分析方法 | 统计结果 | 生物学结论 |
|----------|----------|----------|------------|
| 物种Alpha多样性 | Shannon + Wilcoxon | P=0.73 | 群落复杂度无显著差异 |
| 物种Beta多样性 | Bray-Curtis + PERMANOVA | **P=0.012** | **群落结构显著不同** |
| 功能Beta多样性 | Bray-Curtis + PERMANOVA | **P=0.012**, R²=33.1% | **功能组成显著不同** |
| 通路差异丰度 | MaAsLin2 + FDR | q>0.05 | 无显著差异通路 |
| 物种-KO关联 | Spearman + FDR | **78对显著关联** | 存在强物种-功能关联 |

### 关键科学结论

1. **CagA显著重塑肠道菌群结构**（Beta多样性P=0.012），但不影响整体多样性
2. **功能冗余现象**：尽管物种组成改变，整体代谢功能潜力保持稳定
3. **发现78对显著物种-功能关联**，涉及29个物种和45个KO，为后续机制研究提供候选靶点

### 解读模式

| Alpha多样性 | Beta多样性 | 解读 |
|-------------|------------|------|
| 无变化 | **显著变化** | **群落重组 (Community Restructuring)** |

这提示CagA可能通过**选择性调控特定菌群**而非"全面破坏"来影响肿瘤微环境。

---

## 快速开始

### 环境要求

- R >= 4.2.0
- Bioconductor >= 3.17
- 主要R包: mia, TreeSummarizedExperiment, vegan, ANCOM-BC, ALDEx2, MaAsLin2

### 读取清洗后数据

```r
# 读取清洗后的物种水平数据
tse <- readRDS(here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
                          "tse_standard_species_ca_cleaned.rds"))

# 查看对象信息
tse
colData(tse)
rowData(tse)
```

### 运行分析

```r
# 渲染分析报告
quarto::quarto_render("analyses/01_alpha_beta_diversity_analysis.qmd")
quarto::quarto_render("analyses/02_functional_profiling.qmd")
```

---

## 参考资料

### OMA框架

本项目遵循 **Orchestrating Microbiome Analysis (OMA)** 框架，相关章节参考：
- Chapter 7-10: 多样性分析
- Chapter 11-15: 差异丰度分析
- Chapter 16-20: 功能分析

### 分析协议

- **HUMAnN4**: Beghini et al., bioBakery 3 workflows
- **Kraken**: Wood et al., Metagenome analysis using the Kraken software suite
- **SingleM/Lyrebird**: 菌株分析协议

---

## 作者

**分析人员**: Gong Yuhang
**分析日期**: 2026-01-03
**联系方式**: gongyuhang2023@gmail.com
**GitHub**: https://github.com/gongyuhang2023-cpu/pc047oma
