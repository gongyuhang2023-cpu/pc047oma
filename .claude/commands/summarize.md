# Summarize Analysis Results

Generate a summary of analysis findings.

## Usage
- `/summarize` - Full project summary
- `/summarize 01` - Summarize alpha/beta diversity results
- `/summarize 02` - Summarize functional profiling results
- `/summarize 03` - Summarize SingleM/Lyrebird results
- `/summarize 03b` - Summarize virome-function integration

## Instructions

1. Read the `analyses/00_analysis_summary_report.md` file
2. For specific analysis:
   - Read the corresponding qmd file
   - Check output files in `analyses/data/<analysis_name>/`
3. Provide a concise summary including:
   - Key statistical results (P-values, effect sizes)
   - Biological interpretation
   - Relation to the core scientific questions
4. Use tables for statistical results where appropriate

## Key metrics to report

### 01 Analysis (Diversity)
- Alpha diversity: Shannon index, Wilcoxon P-value
- Beta diversity: PERMANOVA P-value, R²

### 02 Analysis (Function)
- Pathway DAA results
- KO DAA results
- Species-KO correlations (significant pairs)

### 03 Analysis (SingleM/Lyrebird)
- UniFrac P-values (weighted/unweighted)
- Phage alpha diversity changes
- Host-virus correlation (Mantel, Procrustes)

### 03b Analysis (Integration)
- Phage-KO correlations
- Tripartite network edges
