# 分析文件错误修复日志

## 2026-01-17 错误修复记录

### 错误信息
- **位置**：Part 4 数据准备代码块 (行 1928-1942)
- **错误类型**：Error
- **错误消息**：
  ```
  错误于`[[<-`(`*tmp*`, name, value = integer(0)):
    0 elements in value to replace 27 elements
  ```

### 原因分析

代码试图使用不存在的 `sample_name` 列来创建 `genotype` 变量：

```r
# 原始错误代码
colData(tse_full)$genotype <- factor(
  ifelse(grepl("^[0-9]", colData(tse_full)$sample_name), "ApcMUT", "ApcWT"),
  levels = c("ApcWT", "ApcMUT")
)
```

问题：
1. `colData(tse_full)$sample_name` 列不存在
2. `grepl()` 返回空向量 `logical(0)`
3. `ifelse()` 返回 `integer(0)`（0个元素）
4. 尝试将0个元素赋值给27行的 DataFrame 列，导致错误

实际数据结构：
- `genotype` 列已存在，值为 `Apc_wt` 和 `Apc_1638N`
- `infection` 列已存在，值为 `control`, `hp_koCagA`, `hp_wt`
- 无需重新创建，只需转换为标准化格式

### 修复方案

将代码修改为使用现有列并创建新的标准化 factor 变量：

```r
# 修复后代码
colData(tse_full)$genotype_factor <- factor(
  ifelse(colData(tse_full)$genotype == "Apc_wt", "ApcWT", "ApcMUT"),
  levels = c("ApcWT", "ApcMUT")
)

colData(tse_full)$infection_factor <- factor(
  dplyr::case_when(
    colData(tse_full)$infection == "control" ~ "Ctrl",
    colData(tse_full)$infection == "hp_koCagA" ~ "HpKO",
    colData(tse_full)$infection == "hp_wt" ~ "HpWT"
  ),
  levels = c("Ctrl", "HpKO", "HpWT")
)
```

同时更新了后续代码中的变量引用：
- `alpha_data_full` 的 `dplyr::select()` 调用
- `betadisper` 检验使用 `genotype_factor` 和 `infection_factor`
- PERMANOVA 公式使用 `genotype_factor * infection_factor`
- 2x2 子集筛选使用 `infection_factor`

### 修复状态
- [x] 已验证通过

### 验证输出
```
=== Part 4: 样本分组统计 ===
使用标准化 factor 变量:

         Ctrl HpKO HpWT
  ApcWT     5    5    5
  ApcMUT    3    4    5

总样本数: 27

=== SUCCESS: 代码执行成功 ===
```

---

## 2026-01-17 02_functional_profiling.qmd Part 8 错误修复

### 错误信息
- **位置**：Part 8 `part8-permanova-table` 代码块
- **错误类型**：Error
- **错误消息**：
  ```
  错误于data.frame(Factor = c("Genotype", "Infection", "Genotype × Infection", :
    参数值意味着不同的行数: 4, 3
  ```

### 原因分析

`adonis2()` 默认返回汇总行（Model, Residual, Total = 3行），但代码期望 4 行：

```r
# 原始代码 - 无 by="terms" 参数
permanova_pathway_2way <- vegan::adonis2(
  dist_bc_pathway_full ~ genotype_factor * infection_factor,
  data = metadata_pathway_full,
  permutations = 999
)
# 返回 3 行: Model, Residual, Total
```

代码中 `Factor = c("Genotype", "Infection", "Genotype × Infection", "Residual")` 有 4 个元素，与 `adonis2()` 返回的 3 行不匹配。

### 修复方案

1. 在 PERMANOVA 调用中添加 `by = "terms"` 参数，获取每个因子的单独结果（5行）：

```r
# 修复后代码
permanova_pathway_2way <- vegan::adonis2(
  dist_bc_pathway_full ~ genotype_factor * infection_factor,
  data = metadata_pathway_full,
  permutations = 999,
  by = "terms"  # 获取每个因子的单独结果
)
# 返回 5 行: genotype_factor, infection_factor, genotype:infection, Residual, Total
```

2. 更新 data.frame 构建以匹配 5 行结果：

```r
permanova_pathway_results <- data.frame(
  Factor = c("Genotype", "Infection", "Genotype × Infection", "Residual", "Total"),
  # ... 其他列 ...
  Interpretation = c(
    ifelse(permanova_pathway_2way$`Pr(>F)`[1] < 0.05, "显著 ✓", "不显著"),
    ifelse(permanova_pathway_2way$`Pr(>F)`[2] < 0.05, "显著 ✓", "不显著"),
    ifelse(permanova_pathway_2way$`Pr(>F)`[3] < 0.05, "交互显著 ⭐", "无交互"),
    NA,  # Residual
    NA   # Total
  )
)
```

### 修复状态
- [ ] 待验证
