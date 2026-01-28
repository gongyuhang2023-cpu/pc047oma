# PC047 vCagAepitope - Gut Microbiome Analysis

## What

Investigating how *H. pylori* CagA protein reshapes gut microbiome in Apc-mutant mice.

**Core question**: What drives persistent CagA-specific CD8+ T-cell activation after infection clears?

**Comparison**: ApcMUT_HpWT (n=5, CagA+) vs ApcMUT_HpKO (n=4, Control)

---

## 项目导航准则

**重要**: 在执行文件搜索或复杂操作前，**必须先读取 `项目目录.md`** 以：
- 快速定位目标文件（通过完整路径）
- 了解项目架构（无需全量扫描）
- 使用 `#标签` 检索相关文件
- 减少 Token 消耗

> `项目目录.md` 由 git-auto-sync 技能自动维护。

---

## How

### Commands

```bash
# Render 单个分析文件
quarto render analyses/01_alpha_beta_diversity_analysis.qmd

# Render 整个项目 (使用 freeze 缓存)
cd analyses && quarto render
```

### 推荐 R 包

| 类别 | 包 | 用途 |
|------|-----|------|
| 数据容器 | mia, TreeSummarizedExperiment | 微生物组标准容器 |
| 差异分析 | ANCOM-BC, ALDEx2, MaAsLin2 | 组成型数据 DAA |
| 可视化 | ggplot2, miaViz, patchwork | 绑图和拼图 |
| 配色 | ggsci | Nature/Lancet/AAAS 配色 |
| 统计 | vegan, ape | 多样性和进化分析 |

### 命名空间处理 (重要)

为避免包函数冲突，必须显式指定命名空间：

```r
# dplyr 函数 (常与 MASS, stats 冲突)
dplyr::select()
dplyr::filter()
dplyr::lag()
dplyr::rename()

# base R 函数 (常与 dplyr, lubridate 冲突)
base::intersect()
base::setdiff()
base::union()

# mia 函数 (使用新版 API)
mia::addAlpha()        # 替代已弃用的 estimateDiversity()
mia::addBeta()         # 替代已弃用的 runMDS()

# igraph 函数 (常与 ape 冲突)
igraph::degree()
igraph::betweenness()
igraph::closeness()
```

### 路径约定

qmd 文件在 `analyses/` 目录下，使用 `here::here()` 时不要重复 `"analyses"`：

```r
# 正确 (在 analyses/*.qmd 中)
here::here("data", "01_alpha_beta_diversity_analysis", "xxx.rds")

# 错误 (会变成 analyses/analyses/data/...)
here::here("analyses", "data", "01_alpha_beta_diversity_analysis", "xxx.rds")
```

---

## 图表规范 (Nature 标准)

### 尺寸与分辨率

| 元素 | 规范 | R 代码 |
|------|------|--------|
| 单栏宽度 | **89mm (3.5 in)** | `width = 89, units = "mm"` |
| 1.5栏宽度 | 120-136mm | `width = 120, units = "mm"` |
| 双栏宽度 | **183mm (7.2 in)** | `width = 183, units = "mm"` |
| 分辨率 | **300 dpi** | `dpi = 300` |
| 文件格式 | PNG/PDF (RGB) | |

### 字体规范

| 元素 | 规范 |
|------|------|
| 字体 | **Helvetica / Arial** (无衬线) |
| 正文字号 | 5-7 pt |
| 面板标签 | **8 pt 粗体** (a, b, c) |
| 轴标签 | 首字母大写，无句号 |

### 配色方案 (ggsci)

```r
library(ggsci)

# Nature Publishing Group 配色 (推荐)
p + scale_color_npg() + scale_fill_npg()

# Lancet 配色
p + scale_color_lancet() + scale_fill_lancet()

# 获取颜色向量
npg_colors <- pal_npg("nrc")(10)
# "#E64B35" "#4DBBD5" "#00A087" "#3C5488" "#F39B7F" ...
```

### 标准 ggplot 主题

```r
theme_publication <- function(base_size = 14) {
  theme_bw(base_size = base_size) +
  theme(
    text = element_text(family = "Helvetica"),
    plot.title = element_text(size = rel(1.0), face = "bold"),
    axis.title = element_text(size = rel(0.9)),
    axis.text = element_text(size = rel(0.8)),
    legend.title = element_text(size = rel(0.85)),
    legend.text = element_text(size = rel(0.75)),
    strip.text = element_text(size = rel(0.85)),
    panel.grid.minor = element_blank()
  )
}
```

### ggsave 标准调用

```r
# 单栏图 (89mm)
ggsave(here::here("data", params$name, "fig_01a.png"),
       plot = p, width = 89, height = 70, units = "mm", dpi = 300)

# 双栏图 (183mm)
ggsave(here::here("data", params$name, "fig_01.png"),
       plot = p_combined, width = 183, height = 120, units = "mm", dpi = 300)
```

---

## Quarto 配置

本项目使用 `analyses/_quarto.yml` 配置代码缓存：

| 设置 | 值 | 作用 |
|------|-----|------|
| `freeze: auto` | 项目级 | 源码不变时跳过执行 |
| `embed-resources: true` | | 单文件输出便于分享 |

> **注意**: `_freeze/` 目录需要 git commit 以保持缓存有效。已禁用 knitr cache（跨机器协作时易出问题）。

---

## Skills Available

### /notebooklm - OMA & Protocol Reference
Query OMA book and analysis protocols via Gemini with source citations.
```
Notebook ID: oma-book---microbiome-analysis-with-bioconductor
Topics: diversity, ANCOM-BC, ALDEx2, MaAsLin, TreeSummarizedExperiment
```

### /notebooklm - Literature Reference (Apc-Microbiome)
Query literature on Apc mutation and gut microbiome interactions.
```
Notebook ID: pc047-literature-apc-microbiome
Topics: Apc mutation, gut dysbiosis, CagA, tumor suppressor genes
Key papers: PMID 26121046, 39910460, 32728212
```

### Paper Search (MCP)
Search/download papers from arXiv, PubMed, bioRxiv, Semantic Scholar.

---

## Reference Documents

| 需求 | 文档 |
|------|------|
| **完整项目结构** | `项目目录.md` |
| 分析结果汇总 | `analyses/00_analysis_summary_report.md` |
| 假设与发现 | `analyses/PC047_analysis_brief_report.md` |
| 后续分析计划 | `analyses/TODO_future_analyses.md` |
| 方法详情 | Query `/notebooklm` for OMA chapters |
| 分析协议 | `analyses/Protocol/*.pdf` |

---

## Key Results

| 分析 | P值 | 解读 |
|------|-----|------|
| Species Beta | **0.012** | 群落结构显著重塑 |
| Functional Beta | **0.012** | 功能组成有差异 |
| Phage diversity | **0.032** | 细菌-噬菌体协同变化 |
| Pathway DAA | >0.05 | 功能冗余（执行者静默更替） |
| Species-KO pairs | 78 (FDR<0.05) | 候选靶点 |

---

## Structure (简化版，详见 项目目录.md)

```
pc047oma/
├── analyses/
│   ├── _quarto.yml                       # Quarto 配置 (freeze)
│   ├── 01_alpha_beta_diversity_analysis.qmd  # Kraken2/Bracken
│   ├── 02_functional_profiling.qmd           # HUMAnN4
│   ├── 02b_extended_functional_analysis.qmd  # GO/PFAM
│   ├── 03_singlem_diversity_analysis.qmd     # SingleM/Lyrebird
│   ├── 03b_virome_function_integration.qmd   # Virome integration
│   ├── 03c_cooccurrence_network_analysis.qmd # Co-occurrence network
│   ├── _freeze/                          # Quarto 缓存 (需 git commit)
│   ├── data/                             # 分析输出 (git-ignored)
│   ├── OMA BOOK/                         # 方法参考
│   └── Protocol/                         # 分析协议 PDF
├── PPT/                                  # 组会 PPT
├── CLAUDE.md                             # 本文件
└── 项目目录.md                           # 详细项目索引
```
