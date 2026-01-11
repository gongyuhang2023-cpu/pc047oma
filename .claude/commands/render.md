# Render Quarto Analysis

Render a Quarto (.qmd) analysis file to HTML.

## Usage
- `/render` - Show available qmd files and ask which to render
- `/render 01` - Render 01_alpha_beta_diversity_analysis.qmd
- `/render 02` - Render 02_functional_profiling.qmd
- `/render 03` - Render 03_singlem_diversity_analysis.qmd
- `/render 03b` - Render 03b_virome_function_integration.qmd
- `/render all` - Render all analysis files

## Instructions

1. First, list the available qmd files in `analyses/` directory
2. If user specifies a number (01, 02, 03, 03b), map it to the full filename
3. Run `quarto render analyses/<filename>.qmd`
4. Report success or any errors
5. If errors occur, offer to help debug

## File mapping
- 01 → 01_alpha_beta_diversity_analysis.qmd
- 02 → 02_functional_profiling.qmd
- 03 → 03_singlem_diversity_analysis.qmd
- 03b → 03b_virome_function_integration.qmd
