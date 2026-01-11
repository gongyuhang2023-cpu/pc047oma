# CLAUDE.md - PC047 vCagAepitope Project

## Project Overview

This is a **gut microbiome analysis project** investigating how *Helicobacter pylori* CagA protein reshapes the gut microbiome in Apc-mutant mouse models of tumorigenesis.

**Project ID**: PC047
**Project Name**: vCagAepitope
**Author**: Gong Yuhang (gongyuhang2023@gmail.com)

## Core Scientific Questions

1. Does CagA infection alter gut microbial **community structure**?
2. Are structural changes accompanied by **functional potential** changes?
3. Which **species-function associations** may participate in CagA's tumorigenic mechanisms?

## Project Hypothesis & Validation Framework (CRITICAL)

### The Central Question

> **What factor within the gut is responsible for the persistent activation of pathogenic, CagA-specific CD8+ T-cells in the absence of the original CagA antigen?**

### The "Functional Footprint" Hypothesis

**Core Concept**: T-cell activation is driven by a **non-peptidic molecule or metabolite** produced by a specific microbial community whose structure was **permanently altered** by the initial CagA-positive infection.

**Rationale**: The microbiome's **metabolic activity**, rather than its genetic sequence alone, may be the key driver of inflammation.

### Hypothesis Validation Logic Chain

```
Step 1: CagA infection permanently alters microbial community structure
    → 01 analysis validates this (Species Beta diversity P=0.012) ✓

Step 2: Altered community produces different metabolic outputs
    → 02 analysis tests this (Pathway/KO differential abundance)
    → Result: Functional redundancy observed, no significant pathway enrichment ✗

Step 3: Specific metabolites drive T-cell activation
    → Requires metabolomics data (not available yet)

Step 4: T-cell activation promotes tumorigenesis
    → Requires integration with tumor/T-cell phenotype data
```

### Expected vs Actual Results

| Analysis | Hypothesis Expects | Actual Result | Interpretation |
|----------|-------------------|---------------|----------------|
| 01 Species Beta | Significant change | **P=0.012** ✓ | Supports hypothesis |
| 01 Species Alpha | Not necessarily changed | P=0.73 | Restructuring, not collapse |
| 02 Pathway DAA | Enriched pathways in HpWT | **No significant (q>0.05)** | Functional redundancy |
| 02 Species-KO | Associations exist | **78 pairs (FDR<0.05)** | Candidate targets |

### Implications for Analysis

1. **01 analysis SUPPORTS the hypothesis** - community structure is indeed altered
2. **02 analysis PARTIALLY SUPPORTS** - functional composition differs (Beta P=0.012), but no specific enriched pathways found
3. **The mechanism may be more complex** than pathway-level changes:
   - May require metabolomics data
   - May involve specific metabolites, not pathway abundances
   - May involve direct immune interactions, not metabolic cross-talk

### What to Look For in Each Analysis

| Analysis | Key Question | Success Criteria |
|----------|--------------|------------------|
| 01 | Is community structure altered? | Beta diversity significant ✓ |
| 02 | Are metabolic functions altered? | Pathway/KO DAA significant |
| 03 | Does phylogenetic analysis confirm? | UniFrac significant |
| 03b | Are there phage-function links? | Network connectivity |
| Future | Which metabolites are different? | Metabolomics required |

## Experimental Design

**Core Comparison**: ApcMUT_HpWT (n=5) vs ApcMUT_HpKO (n=4)
- ApcMUT_HpWT: Apc mutation + Hp infection (CagA+) - **Experimental group**
- ApcMUT_HpKO: Apc mutation + No infection - **Control group**

**Sample Source**: Caecum (28 samples after cleaning, ca08 excluded due to E. coli contamination)

## Analysis Framework

This project follows the **OMA (Orchestrating Microbiome Analysis)** framework and **bioBakery 3** protocols:

```
01_alpha_beta_diversity_analysis.qmd  → Kraken2/Bracken species analysis
02_functional_profiling.qmd           → HUMAnN4 functional profiling
03_singlem_diversity_analysis.qmd     → SingleM/Lyrebird OTU analysis
03b_virome_function_integration.qmd   → Virome-function integration
```

## Analysis Principles (IMPORTANT)

**When writing or modifying analysis code, Claude MUST follow these priorities:**

### 1. Prioritize mia Package and OMA Methods
- **ALWAYS prefer `mia` package** functions over alternatives (e.g., use `mia::estimateDiversity()` not manual calculations)
- Use `TreeSummarizedExperiment` as the core data structure
- Follow OMA book methodology and coding patterns
- When uncertain, check OMA BOOK chapters first for recommended approaches

### 2. Follow Protocol Documents
- **Before implementing any analysis**, check if there's a relevant Protocol PDF in `analyses/Protocol/`
- Match analysis steps to protocol recommendations
- Protocol mapping:
  | Analysis Type | Reference Protocol |
  |---------------|-------------------|
  | Species classification | `Metagenome analysis using the Kraken software suite.pdf` |
  | Functional profiling | `HUMAnN4_Analysis_Protocol.pdf` |
  | OTU/Phage analysis | `singlem_and_lyrebird_analyses_protocal.pdf` |

### 3. Consult OMA BOOK for Methods
- Diversity analysis → OMA Chapter 7-10
- Differential abundance → OMA Chapter 11-15
- Functional analysis → OMA Chapter 16-20
- Always cite which OMA chapter the method comes from

---

## Reference Materials

### OMA BOOK (analyses/OMA BOOK/)
The primary methodological reference. **MUST consult before implementing new analyses.**

Key chapters:
- **Chapter 7-10**: Diversity analysis (Alpha, Beta, interpretation)
- **Chapter 11-15**: Differential abundance analysis (ANCOM-BC, ALDEx2, MaAsLin2)
- **Chapter 16-20**: Functional analysis
- **Chapter 21-27**: Advanced topics

### Protocol Documents (analyses/Protocol/)
**MUST follow these protocols for corresponding analysis types:**

- `HUMAnN4_Analysis_Protocol.pdf` - Functional pathway annotation
- `Metagenome analysis using the Kraken software suite.pdf` - Species classification
- `singlem_and_lyrebird_analyses_protocal.pdf` - OTU analysis protocol
- `elife-65088-v1.pdf` - Reference paper

## Code Style Preferences

- **R packages**: tidyverse style, use `mia` and `TreeSummarizedExperiment` ecosystem
- **Visualization**: ggplot2, miaViz, patchwork for combining plots
- **Statistics**: vegan for ecology stats, ANCOM-BC/ALDEx2/MaAsLin2 for DAA
- **File format**: Quarto (.qmd) for reproducible analysis
- **Output**: Self-contained HTML with `embed-resources: true`
- **Data objects**: Save as .rds (TreeSummarizedExperiment objects)
- **Language**: Chinese comments OK, code in English

## Common Commands

```bash
# Render a single qmd file
quarto render analyses/01_alpha_beta_diversity_analysis.qmd

# Render all analyses
quarto render analyses/

# Load the R package during development
devtools::load_all()

# Run in R to read cleaned data
tse <- readRDS(here::here("analyses", "data", "01_alpha_beta_diversity_analysis",
                          "tse_standard_species_ca_cleaned.rds"))
```

## Directory Structure

```
pc047oma/
├── CLAUDE.md                    ← You are here
├── analyses/
│   ├── 00_analysis_summary_report.md   # Complete analysis report
│   ├── 01_alpha_beta_diversity_analysis.qmd
│   ├── 02_functional_profiling.qmd
│   ├── 03_singlem_diversity_analysis.qmd
│   ├── 03b_virome_function_integration.qmd
│   ├── data/                    # Data files (git-ignored outputs)
│   ├── OMA BOOK/                # OMA methodology reference (28 chapters)
│   └── Protocol/                # Analysis protocol PDFs
├── R/                           # Package functions
├── DESCRIPTION                  # R package metadata
└── README.md                    # Project README
```

## Key Findings (Summary)

| Analysis | Key Result | P-value |
|----------|-----------|---------|
| Species Beta diversity | **Significant** | P=0.012 |
| Functional Beta diversity | **Significant** | P=0.012, R²=33.1% |
| Phage Alpha diversity | **Decreased** | P=0.0317 |
| Host-Virus correlation | **Strong** | Mantel P=0.001 |
| Species-KO associations | **78 pairs** | FDR<0.05 |

**Pattern**: Community Restructuring (Alpha unchanged, Beta significant) with Functional Redundancy

## Working with Claude

### When asking Claude to:

1. **Add new analysis**: Reference relevant OMA chapters and Protocol PDFs
2. **Debug code**: Provide the error message and relevant qmd section
3. **Interpret results**: Refer to `00_analysis_summary_report.md` for context
4. **Visualize data**: Specify if you want miaViz or custom ggplot2 style

### Useful context to provide:
- Which qmd file you're working on
- The specific comparison group (usually ApcMUT_HpWT vs ApcMUT_HpKO)
- Whether working with species, function, or OTU-level data

## Git Workflow

- **Main branch**: `main`
- **Feature branches**: `feature/*`
- **Current branch**: Check with `git branch`
- Data files in `analyses/data/` are git-ignored
