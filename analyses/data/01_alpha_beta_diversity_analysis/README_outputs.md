# Part 1: Standard Species & Genus 分析结果清单

本文档列出了 `01_alpha_beta_diversity_analysis.qmd` Part 1 分析生成的所有图表和数据文件。

---

## 📊 图表文件 (Figures)

### 质量控制图表 (Quality Control)

| 文件名 | 描述 | 分析阶段 |
|--------|------|----------|
| `01_qc_library_size_cleaning1.png` | 文库大小分布（第1遍清洗） | 数据探索 |
| `02_qc_prevalence_distribution_cleaning1.png` | 物种流行率分布（第1遍清洗） | 数据探索 |
| `03_qc_library_size_cleaning2.png` | 文库大小分布（第2遍清洗，去除异源species后） | 数据清洗 |
| `04_qc_prevalence_distribution_cleaning2.png` | 物种流行率分布（第2遍清洗） | 数据清洗 |
| `06_qc_library_size_cleaning3.png` | 文库大小分布（第3遍清洗，去除ca08样本后） | 数据清洗 |
| `07_qc_prevalence_distribution_cleaning3.png` | 物种流行率分布（第3遍清洗） | 数据清洗 |

### 群落组成图表 (Community Composition)

| 文件名 | 描述 | 用途 |
|--------|------|------|
| `05_composition_top10_species_cleaning2.png` | Top 10物种组成图（第2遍清洗，发现ca08异常） | 识别异常样本 |
| `08_composition_top10_species_final.png` | Top 10物种组成图（最终版） | 群落结构展示 |
| `09_abundance_density_top5_species.png` | Top 5物种丰度密度分布图 | 组间差异可视化 |

### Alpha多样性图表 (Alpha Diversity)

| 文件名 | 描述 | 统计结果 |
|--------|------|----------|
| `10_alpha_shannon_diversity_species.png` | Shannon多样性指数箱线图（Species水平） | P=0.73，无显著差异 |
| `11_alpha_observed_richness_species.png` | 观测物种丰富度箱线图（Species水平） | P=0.29，无显著差异 |
| `12_alpha_diversity_combined_species.png` | Alpha多样性组合图（Shannon + Richness） | 综合展示 |

### Beta多样性图表 (Beta Diversity)

| 文件名 | 描述 | 统计结果 |
|--------|------|----------|
| `13_beta_pcoa_bray_curtis_species.png` | PCoA排序图（Bray-Curtis距离，Species水平） | PERMANOVA P=0.012** |
| `14_beta_pcoa_aitchison_species.png` | PCoA排序图（Aitchison距离，Species水平） | 组成型数据分析 |
| `15_beta_pcoa_bray_curtis_genus.png` | PCoA排序图（Bray-Curtis距离，Genus水平） | PERMANOVA P=0.006** |

**关键结论**：Beta多样性在两组间有显著差异，说明CagA蛋白显著重塑了肠道菌群结构。

---

## 📁 数据文件 (Data Files)

### 统计分析结果 (Statistical Results)

| 文件名 | 描述 | 主要发现 |
|--------|------|----------|
| `16_permanova_bray_curtis_species.csv` | PERMANOVA检验结果（Species水平） | P=0.012，R²=0.064 |
| `17_permanova_bray_curtis_genus.csv` | PERMANOVA检验结果（Genus水平） | P=0.006，R²=0.078 |
| `18_daa_ancombc_top10_species.csv` | ANCOM-BC差异丰度分析Top10（Species） | 前8名均为Microbacterium，LFC=-1.1到-1.6 |
| `19_daa_ancombc_top10_genus.csv` | ANCOM-BC差异丰度分析Top10（Genus） | 无q<0.05的显著差异 |
| `20_daa_aldex2_significant_species.csv` | ALDEx2显著差异物种（FDR<0.05） | 3个物种：Variovorax, Cnuibacter, Agromyces |
| `21_daa_aldex2_trending_genus.csv` | ALDEx2趋势性差异属（\|effect\|>1） | Wenyingzhuangia (effect=-1.31) |

### 清洗后的TSE对象 (Cleaned TreeSE Objects)

| 文件名 | 描述 | 用途 |
|--------|------|------|
| `tse_standard_species_ca_cleaned.rds` | 清洗后的Species水平数据（全部样本） | 后续分析使用 |
| `tse_standard_genus_ca_cleaned.rds` | 清洗后的Genus水平数据（全部样本） | 后续分析使用 |
| `tse_standard_species_ca_cleaned_corepair.rds` | 核心比较组数据（ApcMUT_HpWT vs HpKO，Species） | DAA专用 |
| `tse_standard_genus_ca_corepair.rds` | 核心比较组数据（ApcMUT_HpWT vs HpKO，Genus） | DAA专用 |

---

## 🔬 关键科学发现总结

### 1. Alpha多样性（复杂度）
- **结论**：两组间无显著差异
- **意义**：CagA诱导的致瘤过程并未引起菌群整体复杂度崩溃

### 2. Beta多样性（结构）
- **结论**：两组间有显著差异（P<0.05）
- **意义**：CagA显著重塑了菌群的整体组成结构

### 3. 差异丰度分析
- **主要发现**：
  - **下调菌群**：Microbacterium（微杆菌属）多个物种在HpWT组显著减少
  - **显著消失**：Variovorax, Cnuibacter, Agromyces在致瘤组几乎消失
  - **上调趋势**：Kocuria, Pseudarthrobacter有富集趋势（但未达显著）

### 4. 核心假说支持
这些结果支持**"Functional Footprint"假说**：
- Alpha多样性不变 → 不是简单的菌群崩溃
- Beta多样性显著改变 → 特定菌群结构重塑
- 特定菌种富集/消失 → 可能产生激活T细胞的非肽代谢物

---

## 📝 使用说明

### 读取TSE对象示例
```r
# 读取清洗后的数据
tse <- readRDS(here::here("data", "01_alpha_beta_diversity_analysis", "tse_standard_species_ca_cleaned.rds"))

# 查看对象信息
tse
colData(tse)
rowData(tse)
```

### 读取统计结果示例
```r
# 读取ANCOM-BC结果
ancombc_results <- read.csv(
  here::here("data", "01_alpha_beta_diversity_analysis", "18_daa_ancombc_top10_species.csv")
)

# 查看显著差异物种
View(ancombc_results)
```

---

**分析日期**：2025-12-31
**分析人员**：Gong Yuhang
**项目代号**：pc047 (vCagAepitope)
