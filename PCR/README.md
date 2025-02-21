# PCR Validation Project: Comparing ABI 7500 FAST with Cepheid SmartCycler

This repository contains data and R scripts for a comparative validation study between two real-time PCR platforms: Applied Biosystems ABI 7500 FAST and Cepheid SmartCycler. The study focuses on the detection of *Salmonella* using OriC and GFP assays, with a comprehensive assessment of sensitivity, specificity, and detection limits across multiple serotypes.

## Project Overview

The project compares the performance of two real-time PCR platforms for *Salmonella* detection using:
- Multiple *Salmonella* serotypes (10 different strains)
- Non-*Salmonella* bacterial controls (10 different species)
- Serial dilutions to assess sensitivity (1:10, 1:100, 1:1000)
- Two different assays: OriC and GFP

## Sample Information

### *Salmonella* Positive Controls
| Sample # | Salmonella serotype | Code |
|----------|---------------------|------|
| 1 | *S. enterica* | C170200725 |
| 2 | *S. typhimurium* | C170200649 |
| 3 | *S. irumu* | C170200234 |
| 4 | *S. newport* | C170300003 |
| 5 | *S. infantis* | C170300006 |
| 6 | *S. 4,[5], 12:i:-* | C170100930 |
| 7 | *S. montevideo* | C170200040 |
| 8 | *S. cerro* | C17-1-209 |
| 9 | *S. hadar* | C170100507 |
| 10 | *S. muenchen* | C170100935 |

### Non-*Salmonella* Bacterial Controls
| Sample # | Bacteria |
|----------|----------|
| 1 | *Escherichia coli* |
| 2 | *Pseudomonas aeruginosa* |
| 3 | *Enterobacter cloacae* |
| 4 | *Shigella flexneri* |
| 5 | *Shigella sonnei* |
| 6 | *Stenotrophomonas maltophilia* |
| 7 | *Proteus mirabilis* |
| 8 | *Morganella morganii* |
| 9 | *Citrobacter freundii* |
| 10 | *Citrobacter freundii* complex |

## Repository Structure

### R Scripts

1. **Salmonella Dilution Series Comparisons**
   - `Plot1a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R` - OriC assay comparison
   - `Plot1b_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_gfp.R` - GFP assay comparison
   - `Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R` - Multiple serotypes with OriC
   - `Plot2b_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_gfp.R` - Multiple serotypes with GFP

2. **Non-Salmonella Controls**
   - `Plot3a_Non-Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R` - Specificity testing

3. **Limit of Detection Assessment**
   - `Plot4a_enterica_dilution_series_ABI_limitOfDetection_OriC.R` - Detection limits for *S. enterica*

4. **Additional Scripts**
   - `dotPlot_PCR_data.R` - General plotting script for PCR data

### Data Files

- CSV files containing raw Ct values for all samples and conditions
- Excel workbooks with compiled data and additional metadata
- R history and workspace files

## Key Visualizations

The R scripts generate several plots for comparing the performance of both PCR platforms:

1. **Serotype Comparisons** - Ct values for each *Salmonella* serotype across all dilutions
2. **Platform Comparisons** - Side-by-side comparisons of ABI 7500 vs. SmartCycler
3. **Assay Comparisons** - Performance differences between OriC and GFP assays
4. **Dilution Series** - Sensitivity assessment using serial dilutions
5. **Non-target Testing** - Specificity assessment with non-*Salmonella* bacteria

## Usage Instructions

### Prerequisites
- R (version 3.4 or higher recommended)
- Required R packages: base plotting functionality

### Running the Scripts
1. Clone the repository
2. Ensure all CSV and data files are in your working directory
3. Run individual R scripts to generate specific plots
4. Use `setwd()` to set your working directory if needed


