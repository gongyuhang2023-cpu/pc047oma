# PC047 分析脚本目录

**创建日期**: 2026-01-24
**用途**: PPT制作和补充分析的可视化脚本

---

## 脚本列表 (6个)

| 脚本 | 输出文件 | 用途 |
|------|----------|------|
| `plot_daa_effect_size.R` | `01_.../daa_aldex2_effect_size.png` | ALDEx2差异物种效应值图 |
| `plot_bacteria_phage_procrustes.R` | `03_.../bacteria_phage_procrustes.png`<br>`03_.../bacteria_phage_beta_combined.png` | Procrustes分析 + 双联PCoA图 |
| `plot_bacteria_phage_network_comparison.R` | `03c_.../bacteria_phage_modularity_comparison.png`<br>`03c_.../bacteria_phage_network_combined.png`<br>`03c_.../bacteria_phage_network_stats.csv` | 细菌vs噬菌体网络模块度对比 |
| `plot_bacteria_phage_network_viz.R` | `03c_.../bacteria_phage_network_2x2.png`<br>`03c_.../bacteria_phage_network_1x4.png` | 2x2和1x4网络可视化 |
| `plot_network_modularity.R` | `03c_.../network_modularity_comparison.png`<br>`03c_.../network_module_concept.png` | 网络模块度概念图 |
| `plot_summary_graphical_abstract.R` | `summary_graphical_abstract.png`<br>`summary_graphical_abstract_horizontal.png` | PPT总结页图形摘要 |

---

## 运行方式

```bash
cd /c/Users/36094/Desktop/pc047oma
"/c/Program Files/R/R-4.5.2/bin/Rscript.exe" analyses/scripts/<script_name>.R
```

或在R中：
```r
source(here::here("analyses", "scripts", "<script_name>.R"))
```

---

## 依赖包

- ggplot2, patchwork, dplyr
- TreeSummarizedExperiment, SummarizedExperiment
- vegan (Procrustes, cmdscale)
- igraph (network analysis)
- here

---

## 输出文件位置

| 分析 | 目录 |
|------|------|
| 01 物种多样性 | `analyses/data/01_alpha_beta_diversity_analysis/` |
| 03 SingleM/Lyrebird | `analyses/data/03_singlem_diversity_analysis/` |
| 03c 共现网络 | `analyses/data/03c_cooccurrence_network/` |
| 总结图 | `analyses/data/` |

---

## 新增图片汇总 (PPT用)

### 01 Taxonomic Analysis
- `daa_aldex2_effect_size.png` - 5个显著下降物种的效应值

### 03 Bacteria-Phage Analysis
- `bacteria_phage_beta_combined.png` - 双联PCoA对比
- `bacteria_phage_procrustes.png` - Procrustes旋转图

### 03c Network Analysis
- `bacteria_phage_network_2x2.png` - 2x2网络可视化 (推荐)
- `bacteria_phage_network_1x4.png` - 1x4横版
- `bacteria_phage_modularity_comparison.png` - 模块度柱形图

### Summary
- `summary_graphical_abstract_horizontal.png` - 总结图形摘要 (推荐)

---

*最后更新: 2026-01-24*
