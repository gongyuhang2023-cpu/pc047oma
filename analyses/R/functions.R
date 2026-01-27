# PC047 vCagAepitope 公共函数库
# 创建于 2026-01-27
# 用途：消除QMD文件间的代码重复

# ============================================================
# 1. 发表级ggplot主题
# ============================================================

#' Nature风格ggplot主题
#'
#' @param base_size 基础字号 (默认 14)
#' @return ggplot2主题对象
theme_publication <- function(base_size = 14) {
  ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      text = ggplot2::element_text(family = "Helvetica"),
      plot.title = ggplot2::element_text(size = ggplot2::rel(1.0), face = "bold"),
      plot.subtitle = ggplot2::element_text(size = ggplot2::rel(0.85)),
      axis.title = ggplot2::element_text(size = ggplot2::rel(0.9)),
      axis.text = ggplot2::element_text(size = ggplot2::rel(0.8)),
      axis.line = ggplot2::element_line(color = "black", linewidth = 0.5),
      legend.title = ggplot2::element_text(size = ggplot2::rel(0.85)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.75)),
      legend.key.size = ggplot2::unit(0.8, "lines"),
      strip.text = ggplot2::element_text(size = ggplot2::rel(0.85), face = "bold"),
      strip.background = ggplot2::element_rect(fill = "grey95", color = NA),
      panel.grid.major = ggplot2::element_line(color = "grey90", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(color = "black", linewidth = 0.5)
    )
}

# ============================================================
# 2. NPG配色函数
# ============================================================

#' 获取NPG配色向量
#'
#' @param n 颜色数量
#' @param alpha 透明度
#' @return 颜色向量
get_npg_colors <- function(n = 10, alpha = 1) {
  ggsci::pal_npg("nrc", alpha = alpha)(n)
}

#' 获取Lancet配色向量
#'
#' @param n 颜色数量
#' @param alpha 透明度
#' @return 颜色向量
get_lancet_colors <- function(n = 9, alpha = 1) {
  ggsci::pal_lancet("lanonc", alpha = alpha)(n)
}

# ============================================================
# 3. Bracken数据导入函数
# ============================================================

#' 读取Bracken标准物种数据
#'
#' @param path Bracken输出目录路径
#' @param pattern 文件名匹配模式
#' @return 长格式数据框
read_bracken_data <- function(path, pattern = "_S\\.tsv$") {
  files <- list.files(path, pattern = pattern, full.names = TRUE)

  if (length(files) == 0) {
    stop("No files found matching pattern: ", pattern, " in ", path)
  }

  abundance_list <- lapply(files, function(f) {
    df <- readr::read_tsv(f, show_col_types = FALSE)
    sample_id <- basename(f) |> stringr::str_extract("^[^_]+")

    tibble::tibble(
      feature = df$name,
      abundance = df$new_est_reads,
      sample = sample_id
    )
  })

  dplyr::bind_rows(abundance_list)
}

#' 从长格式数据构建TSE对象
#'
#' @param long_data read_bracken_data返回的长格式数据
#' @param metadata_path metadata Excel文件路径
#' @param source_organ 筛选的器官类型 (默认 "caecum")
#' @return TreeSummarizedExperiment对象
build_tse_from_bracken <- function(long_data, metadata_path, source_organ = "caecum") {
  # 构建count矩阵
  count_mat <- long_data |>
    tidyr::pivot_wider(
      names_from = sample,
      values_from = abundance,
      values_fill = 0
    ) |>
    tibble::column_to_rownames("feature") |>
    as.matrix()

  # 构建TSE
  tse <- TreeSummarizedExperiment::TreeSummarizedExperiment(
    assays = list(counts = count_mat)
  )

  # 添加rowData
  SummarizedExperiment::rowData(tse)$Species <- rownames(tse)

  # 读取并绑定metadata
  metadata <- readxl::read_xlsx(metadata_path) |>
    tibble::column_to_rownames("sample_id")

  common_samples <- base::intersect(colnames(tse), rownames(metadata))
  tse <- tse[, common_samples]
  SummarizedExperiment::colData(tse) <- S4Vectors::DataFrame(metadata[common_samples, ])

  # 筛选器官
  if (!is.null(source_organ)) {
    tse <- tse[, tse$source_organ == source_organ]
  }

  return(tse)
}

# ============================================================
# 4. 数据质量控制函数
# ============================================================

#' 执行标准QC流程
#'
#' @param tse TreeSummarizedExperiment对象
#' @param min_prevalence 最小流行率阈值
#' @param min_detection 最小检测阈值
#' @return 清洗后的TSE对象
run_standard_qc <- function(tse, min_prevalence = 0.1, min_detection = 1) {
  # 添加QC指标
  tse <- scuttle::addPerCellQCMetrics(tse)
  tse <- scuttle::addPerFeatureQCMetrics(tse)

  # 流行率过滤
  tse <- mia::subsetByPrevalent(
    tse,
    prevalence = min_prevalence,
    detection = min_detection
  )

  return(tse)
}

# ============================================================
# 5. Alpha多样性分析函数
# ============================================================

#' 计算并添加Alpha多样性指数
#'
#' @param tse TSE对象
#' @return 添加了多样性指数的TSE
add_alpha_diversity <- function(tse) {
  tse <- mia::addAlpha(tse, index = c("shannon", "simpson", "observed"))
  return(tse)
}

#' Alpha多样性统计检验
#'
#' @param tse TSE对象
#' @param group_var 分组变量名
#' @param indices 多样性指数名称向量
#' @return 统计结果数据框
test_alpha_diversity <- function(tse, group_var, indices = c("shannon", "simpson", "observed")) {
  col_data <- as.data.frame(SummarizedExperiment::colData(tse))

  results <- lapply(indices, function(idx) {
    if (idx %in% colnames(col_data)) {
      formula <- as.formula(paste(idx, "~", group_var))
      test <- wilcox.test(formula, data = col_data)
      tibble::tibble(
        index = idx,
        statistic = test$statistic,
        p_value = test$p.value
      )
    }
  })

  dplyr::bind_rows(results)
}

# ============================================================
# 6. Beta多样性分析函数
# ============================================================

#' 执行PERMANOVA检验
#'
#' @param tse TSE对象
#' @param formula 模型公式 (右侧部分，如 "Group")
#' @param method 距离方法 (默认 "bray")
#' @param permutations 置换次数
#' @return adonis2结果
run_permanova <- function(tse, formula, method = "bray", permutations = 999) {
  # 计算距离矩阵
  dist_mat <- vegan::vegdist(t(SummarizedExperiment::assay(tse, "counts")), method = method)

  # 构建完整公式
  col_data <- as.data.frame(SummarizedExperiment::colData(tse))
  full_formula <- as.formula(paste("dist_mat ~", formula))

  # 执行PERMANOVA
  result <- vegan::adonis2(full_formula, data = col_data, permutations = permutations)

  return(result)
}

#' 执行betadisper方差齐性检验
#'
#' @param tse TSE对象
#' @param group_var 分组变量名
#' @param method 距离方法
#' @return betadisper和permutest结果列表
run_betadisper <- function(tse, group_var, method = "bray") {
  dist_mat <- vegan::vegdist(t(SummarizedExperiment::assay(tse, "counts")), method = method)
  col_data <- as.data.frame(SummarizedExperiment::colData(tse))

  bd <- vegan::betadisper(dist_mat, col_data[[group_var]])
  test <- vegan::permutest(bd)

  list(betadisper = bd, permutest = test)
}

# ============================================================
# 7. 图表保存函数
# ============================================================

#' 保存单栏图 (89mm)
#'
#' @param filename 文件名
#' @param plot ggplot对象
#' @param height 高度 (mm)
#' @param dpi 分辨率
save_single_column <- function(filename, plot, height = 70, dpi = 300) {
  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = 89,
    height = height,
    units = "mm",
    dpi = dpi
  )
}

#' 保存双栏图 (183mm)
#'
#' @param filename 文件名
#' @param plot ggplot对象
#' @param height 高度 (mm)
#' @param dpi 分辨率
save_double_column <- function(filename, plot, height = 120, dpi = 300) {
  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    width = 183,
    height = height,
    units = "mm",
    dpi = dpi
  )
}

# ============================================================
# 8. 统计结果格式化
# ============================================================

#' 格式化P值
#'
#' @param p P值
#' @param digits 小数位数
#' @return 格式化字符串
format_pvalue <- function(p, digits = 3) {
  if (p < 0.001) {
    return("< 0.001")
  } else if (p < 0.01) {
    return(sprintf("%.3f", p))
  } else {
    return(sprintf(paste0("%.", digits, "f"), p))
  }
}

#' 添加显著性星号
#'
#' @param p P值
#' @return 星号字符串
add_significance <- function(p) {
  dplyr::case_when(
    p < 0.001 ~ "***",
    p < 0.01 ~ "**",
    p < 0.05 ~ "*",
    p < 0.1 ~ ".",
    TRUE ~ ""
  )
}

# ============================================================
# 9. PC047项目特定函数
# ============================================================
#' 定义核心比较组颜色
#'
#' @return 命名颜色向量
get_group_colors <- function() {
  npg <- ggsci::pal_npg("nrc")(10)
  c(
    "ApcMUT_HpWT" = npg[1],   # CagA+ 感染组
    "ApcMUT_HpKO" = npg[2],   # CagA- 对照组
    "ApcMUT_Mock" = npg[3],
    "ApcWT_HpWT" = npg[4],
    "ApcWT_HpKO" = npg[5],
    "ApcWT_Mock" = npg[6]
  )
}

#' 筛选核心比较组 (ApcMUT_HpWT vs ApcMUT_HpKO)
#'
#' @param tse TSE对象
#' @return 筛选后的TSE
filter_core_comparison <- function(tse) {
  tse[, tse$Group %in% c("ApcMUT_HpWT", "ApcMUT_HpKO")]
}
