# ==============================================================================
# 生成 PC047 总结页 PPT
# ==============================================================================

# 安装officer包（如果没有）
if (!requireNamespace("officer", quietly = TRUE)) {
  install.packages("officer", repos = "https://cloud.r-project.org")
}

library(officer)
library(here)

# ------------------------------------------------------------------------------
# 1. 创建PPT
# ------------------------------------------------------------------------------

ppt <- read_pptx()

# ------------------------------------------------------------------------------
# 2. 添加总结页
# ------------------------------------------------------------------------------

ppt <- add_slide(ppt, layout = "Title and Content", master = "Office Theme")

# 标题
ppt <- ph_with(ppt,
               value = "CagA Reshapes Gut Microbiome: Conclusions & Next Steps",
               location = ph_location_type(type = "title"))

# ------------------------------------------------------------------------------
# 3. 创建内容文本
# ------------------------------------------------------------------------------

content_text <- "
KEY FINDINGS

1. Composition Changed (not destroyed)
   - Beta diversity P = 0.012; 5 species depleted (ALDEx2)

2. Function Stable (via redundancy)
   - No FDR-significant pathways; Driver species shift

3. Network Structure Collapsed
   - Modularity: Bacteria -63%, Phage -30%

4. Bacteria-Phage Tightly Coupled
   - Mantel r = 0.932, P = 0.001


HYPOTHESIS

Persistent CD8+ T-cell activation driven by reshaped microbiome
through molecular mimicry (CagA-like epitopes?)


NEXT STEPS

1. Immediate: Integrate immune/tumor phenotype data (Bioinformatics)
2. Short-term: Metabolomics validation (SCFA, LPS)
3. Long-term: Epitope analysis & Driver species isolation
"

ppt <- ph_with(ppt,
               value = content_text,
               location = ph_location_type(type = "body"))

# ------------------------------------------------------------------------------
# 4. 添加带图片的页面
# ------------------------------------------------------------------------------

ppt <- add_slide(ppt, layout = "Title and Content", master = "Office Theme")

ppt <- ph_with(ppt,
               value = "Summary: Graphical Abstract",
               location = ph_location_type(type = "title"))

# 添加图片
img_path <- here::here("analyses", "data", "summary_graphical_abstract_horizontal.png")

if (file.exists(img_path)) {
  ppt <- ph_with(ppt,
                 value = external_img(img_path, width = 9, height = 5),
                 location = ph_location(left = 0.5, top = 1.5, width = 9, height = 5))
}

# ------------------------------------------------------------------------------
# 5. 保存PPT
# ------------------------------------------------------------------------------

output_path <- here::here("PPT", "PC047_Summary_Conclusions.pptx")

# 确保PPT目录存在
if (!dir.exists(here::here("PPT"))) {
  dir.create(here::here("PPT"))
}

print(ppt, target = output_path)

cat("\n✅ PPT已生成:", output_path, "\n")
