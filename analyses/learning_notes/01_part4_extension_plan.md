# 01 Alpha/Beta Diversity Analysis - Part 4 扩展计划

## 目标
将01分析从核心双组比较（ApcMUT_HpWT vs ApcMUT_HpKO）扩展为完整的2×3因子设计分析，与03分析的Part 4保持一致。

## 当前状态
- **数据**: Kraken2/Bracken物种丰度数据（Standard + Virus）
- **现有分析**: 仅比较 ApcMUT_HpWT vs ApcMUT_HpKO（n=9）
- **缺失**: betadisper检验、多组比较、交互作用分析

## 扩展设计

### 实验因子
```
Genotype (2水平): ApcWT, ApcMUT
Infection (3水平): Ctrl, HpKO, HpWT
共6组: ApcWT_Ctrl, ApcWT_HpKO, ApcWT_HpWT, ApcMUT_Ctrl, ApcMUT_HpKO, ApcMUT_HpWT
```

### 分析策略（遵循OMA/NotebookLM建议）

#### 层次1: 全6组分析
- 目的：评估整体因子效应
- 方法：双因素PERMANOVA（genotype * infection）

#### 层次2: 2×2子集分析（排除Ctrl组）
- 目的：聚焦感染效应，检测CagA特异性作用
- 样本：ApcWT_HpKO, ApcWT_HpWT, ApcMUT_HpKO, ApcMUT_HpWT
- 方法：双因素PERMANOVA（genotype * infection）

---

## Part 4 具体实现计划

### 4.1 数据准备 - 全样本TSE对象

```r
# 使用完整的清洗后数据（保留所有6组）
# 需要新建一个包含所有样本的TSE对象
tse_all_groups <- tse_standard_species_ca_cleaned  # 全部样本

# 添加因子变量
colData(tse_all_groups)$genotype <- factor(
  ifelse(grepl("^[0-9]", colData(tse_all_groups)$sample_name), "ApcMUT", "ApcWT"),
  levels = c("ApcWT", "ApcMUT")
)

colData(tse_all_groups)$infection <- factor(
  case_when(
    grepl("Ctrl", colData(tse_all_groups)$treatment_group) ~ "Ctrl",
    grepl("HpKO", colData(tse_all_groups)$treatment_group) ~ "HpKO",
    grepl("HpWT", colData(tse_all_groups)$treatment_group) ~ "HpWT"
  ),
  levels = c("Ctrl", "HpKO", "HpWT")
)
```

### 4.2 Alpha Diversity 扩展分析

#### 4.2.1 全6组Alpha多样性可视化
```r
# 计算多种alpha多样性指数
tse_all_groups <- addAlpha(tse_all_groups,
                           index = c("shannon", "observed", "simpson", "chao1"))

# 可视化：按genotype和infection分面
p_alpha_full <- plotAlpha(tse_all_groups, "shannon",
                          colour_by = "infection") +
  facet_wrap(~genotype) +
  theme_bw()
```

#### 4.2.2 双因素方差分析
```r
# Kruskal-Wallis或ANOVA检验主效应和交互作用
# 使用aligned rank transform (ART) ANOVA处理非正态数据
library(ARTool)

alpha_data <- colData(tse_all_groups) %>%
  as.data.frame() %>%
  select(genotype, infection, shannon, observed)

# ART ANOVA for Shannon
art_model <- art(shannon ~ genotype * infection, data = alpha_data)
anova(art_model)
```

### 4.3 Beta Diversity 扩展分析

#### 4.3.1 betadisper同质性检验（关键步骤！）
```r
# OMA建议：PERMANOVA前必须检验组间方差齐性
# 计算Bray-Curtis距离矩阵
dist_bc <- getDissimilarity(tse_all_groups, method = "bray",
                             assay.type = "relabundance")

# betadisper检验
disp_genotype <- betadisper(dist_bc, colData(tse_all_groups)$genotype)
disp_infection <- betadisper(dist_bc, colData(tse_all_groups)$infection)
disp_interaction <- betadisper(dist_bc, colData(tse_all_groups)$treatment_group)

# 方差齐性检验
permutest(disp_genotype, permutations = 999)
permutest(disp_infection, permutations = 999)
permutest(disp_interaction, permutations = 999)

# 可视化betadisper结果
plot(disp_interaction, main = "betadisper: Treatment Groups")
```

#### 4.3.2 全6组PCoA可视化
```r
# PCoA排序图，展示所有6组
tse_all_groups <- addMDS(tse_all_groups,
                          FUN = getDissimilarity,
                          method = "bray",
                          assay.type = "relabundance",
                          name = "PCoA_Bray_Full")

p_pcoa_full <- plotReducedDim(tse_all_groups, "PCoA_Bray_Full",
                               colour_by = "infection",
                               shape_by = "genotype") +
  stat_ellipse(aes(group = treatment_group), level = 0.95) +
  theme_bw() +
  labs(title = "PCoA: All 6 Treatment Groups (Bray-Curtis)")
```

#### 4.3.3 双因素PERMANOVA - 全6组
```r
# 使用vegan::adonis2进行双因素PERMANOVA
# 公式：~ genotype * infection（包含交互作用）

metadata <- as.data.frame(colData(tse_all_groups))

permanova_full <- adonis2(
  dist_bc ~ genotype * infection,
  data = metadata,
  permutations = 999,
  method = "bray",
  by = "margin"  # Type III SS，检验每个因子的独立效应
)

print(permanova_full)
# 输出：
# - genotype主效应（Apc突变的整体影响）
# - infection主效应（感染状态的整体影响）
# - genotype:infection交互作用（CagA效应是否依赖于Apc基因型）
```

#### 4.3.4 2×2子集分析（排除Ctrl组）
```r
# 筛选感染组样本（排除Ctrl）
tse_infected <- tse_all_groups[, colData(tse_all_groups)$infection != "Ctrl"]

# 重新计算距离矩阵
dist_bc_infected <- getDissimilarity(tse_infected, method = "bray",
                                      assay.type = "relabundance")

# betadisper检验
disp_infected <- betadisper(dist_bc_infected,
                            colData(tse_infected)$treatment_group)
permutest(disp_infected, permutations = 999)

# 2×2 PERMANOVA
metadata_infected <- as.data.frame(colData(tse_infected))

permanova_infected <- adonis2(
  dist_bc_infected ~ genotype * infection,
  data = metadata_infected,
  permutations = 999,
  by = "margin"
)

print(permanova_infected)
# 这个分析更聚焦于：CagA效应是否在不同Apc基因型背景下表现不同
```

### 4.4 成对比较与FDR校正

#### 4.4.1 假设驱动的比较（只对这些做FDR校正）
```r
# 根据NotebookLM建议：只对预定义的科学问题驱动的比较做校正
# 关键比较列表：
key_comparisons <- list(
  # 1. CagA效应（核心问题）
  c("ApcMUT_HpWT", "ApcMUT_HpKO"),   # 变异鼠中CagA效应
  c("ApcWT_HpWT", "ApcWT_HpKO"),     # 野生型中CagA效应

  # 2. Apc基因型效应
  c("ApcMUT_HpWT", "ApcWT_HpWT"),    # 感染CagA+时的基因型效应
  c("ApcMUT_HpKO", "ApcWT_HpKO"),    # 感染CagA-时的基因型效应

  # 3. 感染效应（vs Ctrl）
  c("ApcMUT_HpWT", "ApcMUT_Ctrl"),   # 变异鼠感染效应
  c("ApcMUT_HpKO", "ApcMUT_Ctrl")    # 变异鼠对照感染效应
)

# 执行成对PERMANOVA
pairwise_results <- lapply(key_comparisons, function(pair) {
  # 筛选样本
  tse_pair <- tse_all_groups[, colData(tse_all_groups)$treatment_group %in% pair]
  dist_pair <- getDissimilarity(tse_pair, method = "bray",
                                 assay.type = "relabundance")
  meta_pair <- as.data.frame(colData(tse_pair))

  # PERMANOVA
  result <- adonis2(dist_pair ~ treatment_group, data = meta_pair,
                    permutations = 999)

  data.frame(
    comparison = paste(pair, collapse = " vs "),
    R2 = result$R2[1],
    F_value = result$F[1],
    p_value = result$`Pr(>F)`[1]
  )
})

pairwise_df <- do.call(rbind, pairwise_results)

# FDR校正（只对这6个预定义比较）
pairwise_df$p_adj <- p.adjust(pairwise_df$p_value, method = "BH")
```

### 4.5 结果可视化汇总

#### 4.5.1 效应量热图
```r
# 展示各因子效应的R²值
effect_sizes <- data.frame(
  Factor = c("Genotype", "Infection", "Interaction"),
  Full_6groups = c(permanova_full$R2[1:3]),
  Subset_2x2 = c(permanova_infected$R2[1:3])
)

# 热图可视化
library(pheatmap)
pheatmap(as.matrix(effect_sizes[,-1]),
         row.names = effect_sizes$Factor,
         cluster_rows = FALSE, cluster_cols = FALSE,
         display_numbers = TRUE)
```

#### 4.5.2 交互作用可视化
```r
# 如果交互作用显著，用折线图展示
interaction_data <- colData(tse_all_groups) %>%
  as.data.frame() %>%
  group_by(genotype, infection) %>%
  summarise(
    mean_PC1 = mean(PC1),
    se_PC1 = sd(PC1)/sqrt(n())
  )

p_interaction <- ggplot(interaction_data,
                        aes(x = infection, y = mean_PC1,
                            color = genotype, group = genotype)) +
  geom_line() +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_PC1 - se_PC1, ymax = mean_PC1 + se_PC1),
                width = 0.1) +
  theme_bw() +
  labs(title = "Interaction: Genotype × Infection",
       y = "PCoA Axis 1")
```

---

## 预期结果结构

| 分析 | 指标 | 预期显著性 | 生物学意义 |
|------|------|------------|------------|
| Full PERMANOVA - Genotype | R², P-value | 可能显著 | Apc突变整体效应 |
| Full PERMANOVA - Infection | R², P-value | 可能显著 | 感染状态整体效应 |
| Full PERMANOVA - Interaction | R², P-value | 关键检验 | CagA效应是否依赖Apc |
| 2×2 PERMANOVA - Genotype | R², P-value | 参考03结果 | 排除Ctrl后的基因型效应 |
| 2×2 PERMANOVA - Infection | R², P-value | 参考03结果 | 排除Ctrl后的感染效应 |
| Pairwise: MUT_HpWT vs MUT_HpKO | R², P-adj | **0.012** (已有) | CagA在变异鼠中的效应 |

---

## 与03分析的对比预期

| 数据来源 | Apc基因型效应 | CagA效应 | 交互作用 |
|----------|---------------|----------|----------|
| 03 SingleM | R²≈50%, P=0.009 | R²≈25% | 待验证 |
| 01 Bracken | 待分析 | R²=24.5%, P=0.012 | 待分析 |

---

## 实施顺序

1. **数据准备**: 创建全样本TSE对象，添加genotype/infection因子
2. **betadisper检验**: 先验证方差齐性假设
3. **Alpha扩展**: 全6组可视化 + ART ANOVA
4. **Beta扩展**:
   - 全6组PCoA可视化
   - 双因素PERMANOVA（全6组）
   - 2×2子集PERMANOVA
5. **成对比较**: 6个关键比较 + FDR校正
6. **结果汇总**: 效应量热图、交互作用图

---

## 注意事项

1. **betadisper必须做**: 如果方差不齐，PERMANOVA结果需谨慎解读
2. **FDR策略**: 只对6个预定义比较做校正，不做全部15个两两比较
3. **样本量**: 部分组样本量较小（n=3-5），结果需谨慎
4. **与03对比**: Bracken和SingleM方法可能得到不同结论，这是正常的

---

*Created: 2026-01-16*
*Based on: OMA Book, 03 Part 4 framework, NotebookLM consultation*
