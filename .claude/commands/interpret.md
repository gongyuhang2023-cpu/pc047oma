# Interpret Results

Help interpret microbiome analysis results in biological context.

## Usage
- `/interpret <result_type>` - Get interpretation guidance
- `/interpret alpha-beta` - Alpha/Beta diversity pattern interpretation
- `/interpret daa` - Differential abundance interpretation
- `/interpret correlation` - Correlation analysis interpretation

## Alpha-Beta Diversity Patterns

| Alpha | Beta | Pattern | Interpretation |
|-------|------|---------|----------------|
| No change | No change | Stable | No community effect |
| No change | **Changed** | **Restructuring** | Selective modulation (PC047 pattern) |
| Decreased | Changed | Dysbiosis | Ecological disruption |
| Increased | Changed | Enrichment | New colonization |

**PC047 Finding**: Community Restructuring - CagA selectively reshapes community without destroying diversity.

## Functional Redundancy

When species composition changes but function remains stable:
- Multiple species perform similar metabolic functions
- Ecosystem maintains stability through redundancy
- CagA effect may be through specific metabolites, not overall function

## Host-Virus Correlation

Strong Mantel/Procrustes correlation between bacteria and phage suggests:
- Coordinated dynamics between host and virus
- Possible phage-mediated regulation of bacterial community
- Three-way interaction: CagA → Phage → Bacteria → Function

## Instructions

1. Identify the result type user wants to interpret
2. Provide the relevant interpretation framework from OMA
3. Apply specifically to PC047 context (CagA, Apc mutation, tumorigenesis)
4. Suggest follow-up analyses if appropriate
5. Reference relevant OMA chapters for deeper reading
