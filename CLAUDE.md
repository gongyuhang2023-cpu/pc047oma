# PC047 vCagAepitope - Gut Microbiome Analysis

## What

Investigating how *H. pylori* CagA protein reshapes gut microbiome in Apc-mutant mice.

**Core question**: What drives persistent CagA-specific CD8+ T-cell activation after infection clears?

**Comparison**: ApcMUT_HpWT (n=5, CagA+) vs ApcMUT_HpKO (n=4, Control)

## How

### Commands

```bash
# Render analysis
quarto render analyses/01_alpha_beta_diversity_analysis.qmd

# Load cleaned data in R
tse <- readRDS(here::here("analyses/data/01_alpha_beta_diversity_analysis/tse_standard_species_ca_cleaned.rds"))
```

### Code Style

- Use `mia` package and `TreeSummarizedExperiment` - never manual calculations
- Statistics: ANCOM-BC/ALDEx2/MaAsLin2 for differential abundance
- Output: Quarto (.qmd) with `embed-resources: true`

### Namespace Conflicts (重要)

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
mia::addBeta()         # 替代已弃用的 runMDS() 等

# igraph 函数 (常与 ape 冲突)
igraph::degree()
igraph::betweenness()
igraph::closeness()
```

### Path Convention

qmd 文件在 `analyses/` 目录下，使用 `here::here()` 时不要重复 `"analyses"`：
```r
# 正确
here::here("data", "01_alpha_beta_diversity_analysis", "xxx.rds")

# 错误 (会变成 analyses/analyses/data/...)
here::here("analyses", "data", "01_alpha_beta_diversity_analysis", "xxx.rds")
```

## Skills Available

### /notebooklm - OMA & Protocol Reference
Query OMA book and analysis protocols via Gemini with source citations.
```
Notebook ID: pc047-oma-protocols-reference
Topics: diversity, ANCOM-BC, ALDEx2, MaAsLin, TreeSummarizedExperiment
```

### /notebooklm - Literature Reference (Apc-Microbiome)
Query literature on Apc mutation and gut microbiome interactions.
```
Notebook ID: c14f7f4b-2edd-4bce-a287-b3e531b2f855
Topics: Apc mutation, gut dysbiosis, CagA, tumor suppressor genes, host-microbiome interaction
Key papers: PMID 26121046, 39910460, 32728212
```

### Paper Search (MCP)
Search/download papers from arXiv, PubMed, bioRxiv, Semantic Scholar.

## Reference Documents

| Need | Document |
|------|----------|
| Analysis results | `analyses/00_analysis_summary_report.md` |
| Hypothesis & findings | `analyses/PC047_analysis_brief_report.md` |
| Method details | Query `/notebooklm` for OMA chapters |
| Protocols | `analyses/Protocol/*.pdf` |

## Key Results

| Analysis | P-value | Interpretation |
|----------|---------|----------------|
| Species Beta | **0.012** | Community restructured |
| Functional Beta | **0.012** | Composition differs |
| Pathway DAA | >0.05 | Functional redundancy |
| Species-KO pairs | 78 (FDR<0.05) | Candidate targets |

## Structure

```
analyses/
├── 01_alpha_beta_diversity_analysis.qmd  # Kraken2/Bracken
├── 02_functional_profiling.qmd           # HUMAnN4
├── 03_singlem_diversity_analysis.qmd     # SingleM/Lyrebird
├── 03b_virome_function_integration.qmd   # Virome integration
├── data/                                 # git-ignored
├── OMA BOOK/                             # Method reference
└── Protocol/                             # Analysis protocols
```
