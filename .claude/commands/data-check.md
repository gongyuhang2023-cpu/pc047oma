# Check Data Status

Check the status of data files and analysis outputs.

## Usage
- `/data-check` - Overview of all data files
- `/data-check raw` - Check raw input data
- `/data-check outputs` - Check analysis outputs
- `/data-check tse` - List TreeSummarizedExperiment objects

## Instructions

1. Check `analyses/data/` directory structure
2. List available data files by category:
   - Raw data: `analyses/data/00-raw/`
   - Metadata: `analyses/data/metadata/`
   - Analysis outputs: `analyses/data/<analysis_name>/`
3. For each analysis, report:
   - Number of output files (.png, .csv, .rds)
   - Key .rds objects (TreeSummarizedExperiment)
   - Whether outputs appear complete

## Expected outputs by analysis

### 01_alpha_beta_diversity_analysis
- `tse_standard_species_ca_cleaned.rds` - Main TreeSE object
- Alpha diversity plots and stats
- Beta diversity PCoA plots
- PERMANOVA results

### 02_functional_profiling
- Pathway abundance data
- KO abundance data
- DAA results (MaAsLin2)
- Species-KO correlation results

### 03_singlem_diversity_analysis
- SingleM TreeSE object
- Lyrebird TreeSE object
- UniFrac distance matrices
- Host-virus correlation results

### 03b_virome_function_integration
- Phage-KO correlation matrix
- Tripartite network edges
- Integration analysis results
