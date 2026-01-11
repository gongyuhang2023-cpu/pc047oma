# Create New Analysis

Create a new Quarto analysis file following project conventions.

## Usage
- `/new-analysis <number> <name>` - Create new analysis file
- Example: `/new-analysis 04 metabolomics_integration`

## Instructions

1. Ask for analysis number (e.g., 04, 05) if not provided
2. Ask for analysis name (snake_case) if not provided
3. Create file: `analyses/<number>_<name>.qmd`
4. Use the template below
5. Update the `00_analysis_summary_report.md` to include the new analysis

## Template

```yaml
---
title: "<number>_<name>"
title-block-banner: true
author:
  - name: Gong Yuhang
date: <current_date>
toc: true
toc-depth: 4
number-sections: true
code-fold: true
code-line-numbers: true
code-tools: true
format:
  html:
    embed-resources: true
    smooth-scroll: true
    page-layout: full
reference-location: section
citation-location: document
params:
  name: "<number>_<name>"
---

**Updated: `r format(Sys.time(), '%Y-%m-%d %H:%M:%S', tz = 'CET')` CET.**

本文档是项目 pc047 (vCagAepitope) 的分析模块。
[Description of analysis purpose]

```{r}
#| label: params
#| eval: !expr interactive()
#| include: false
params <- list(name = "<number>_<name>")
```

```{r}
#| label: setup
#| message: false
#| include: false
#| warning: false
wd <- "analyses"
if (basename(getwd()) != wd) {
  setwd(here::here(wd))
}
here::i_am(paste0(params$name, ".qmd"), uuid = "<generate_new_uuid>")
projthis::proj_create_dir_target(params$name, clean = FALSE)
path_target <- projthis::proj_path_target(params$name)
path_source <- projthis::proj_path_source(params$name)
```

## Packages
```{r}
#| label: packages
#| message: false
suppressPackageStartupMessages({
  library(here)
  library(conflicted)
  library(tidyverse)
  library(mia)
  library(TreeSummarizedExperiment)
  library(ggplot2)
  library(patchwork)
  devtools::load_all()
})

conflicts_prefer(base::setdiff)
conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::select)

set.seed(20261)
```

## Tasks

[Analysis code here]

## Session Info
```{r}
sessionInfo()
```
```

## Checklist
- [ ] File created with proper YAML header
- [ ] UUID generated for here::i_am()
- [ ] Required packages listed
- [ ] Analysis sections added
- [ ] Summary report updated
