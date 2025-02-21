# Lower Colorado River Ecosystem Research Analysis

This repository contains R scripts for text mining and cluster analysis of research reports from the Lower Colorado River ecosystem. The project analyzes word frequencies across different research reports to identify patterns and similarities among research projects.

## Project Overview

The main goal of this project is to analyze and categorize research projects based on their focus areas (species studied, habitat types, and research methodologies). It uses text mining techniques to extract word frequencies from research reports and applies cluster analysis to identify groupings of similar research projects.

## Data

The primary data file is `searchResult_totalWordNumber.txt`, which contains a matrix of word frequencies for various research codes (rows) and search terms (columns). The data includes:

- **Species terms**: birds, fish, insects, bats, amphibians, plants, etc.
- **Habitat terms**: river, lake, marsh, woodland, laboratory, etc.
- **Methodology terms**: tracking, physiology, genetic analysis, survey methods, etc.

## Scripts

The repository contains several R scripts:

### Main Scripts

1. **loadData.R** - Initial script to load and prepare data
2. **clustering.R** - Performs clustering on combined data (species, habitat, methodology)
3. **clustering_dataType.R** - Focuses on clustering based on research methodologies
4. **clustering_dataType-only.R** - Specialized script for analyzing specific data collection techniques
5. **clustering2.R** - Alternative clustering approach with different visualizations

### Core Functionality

The scripts perform the following operations:

- Load and pre-process data from CSV files
- Combine related search terms into broader categories
- Create distance matrices using Euclidean distance
- Perform cluster analysis using:
  - Hierarchical clustering (hclust with Ward's method)
  - K-means clustering
- Visualize results using dendrograms, heat maps, and scatter plots
- Compare different clustering approaches

## Key Analyses

1. **Species-based clustering**: Groups projects based on the organisms they study
2. **Habitat-based clustering**: Groups projects by the environments they focus on
3. **Methodology-based clustering**: Groups projects by research techniques used
4. **Combined clustering**: Integrates all dimensions for comprehensive grouping

## Visualizations

The scripts generate several types of visualizations:

- Dendrograms showing hierarchical relationships between projects
- Cluster plots representing multi-dimensional relationships in 2D space
- Bar plots of word frequencies
- Log-scale comparison plots of different terms across projects

## How to Use

1. Make sure you have R installed along with the following packages:
   - ape
   - phytools
   - cluster
   - qgraph
   - mclust
   - lattice
   - plotrix

2. Update the `setwd()` function in the scripts to point to your local directory containing the data files.

3. Run the scripts in the following order:
   - First run `loadData.R` to prepare the data
   - Then try different clustering approaches with the other scripts

4. Adjust parameters as needed:
   - Change the number of clusters by modifying the `kmeansValue` variable
   - Select different term combinations by modifying the `data_combined` and `data_crop` objects

## Example

To perform clustering based on species data:

```R
# Load required libraries
library(ape)
library(phytools)
library(cluster)
library(qgraph)
library(mclust)

# Load and prepare data
data = read.csv("data_habitat_speciesNames.csv", header = TRUE, sep=",", row.names = 1)

# Create species groups
birds <- rowSums(data[,c("avian","woodpecker","bird","warbler","tanager","cuckoo", "owl", "flycatcher", "flicker", "vireo", "quail", "blackbird", "starling", "dove", "migrants", "waterbirds", "shorebirds", "yellow.billed")])
fish <- rowSums(data[,c("fish","pikeminnow","razorback", "rasu", "flannelmouth", "humpback", "chub", "bonytail", "rainbow", "trout", "catfish", "bass")])
# Combine into a data frame
data_combined <- data.frame(birds, fish, plants, insects, bats, amphibians)

# Remove outliers
data_crop <- data_combined[!rownames(data_combined) %in% c("c39", "e14", "e27"), ]

# Perform clustering
d <- dist(data_crop, method = "euclidean")
H.fit <- hclust(d, method="ward.D")
plot(H.fit)
Euc_groups <- cutree(H.fit, k=6)
rect.hclust(H.fit, k=6, border="red")
```

## Results

The cluster analysis reveals distinct groupings of research projects based on their focus areas:

1. Fish-focused research with tracking and physiological studies
2. Bird-focused projects with behavioral observation techniques
3. Habitat restoration and vegetation studies
4. Water chemistry and environmental monitoring
5. Multi-species biodiversity assessments
6. Specialized studies on particular species (bats, amphibians, etc.)

These groupings help identify research gaps, potential collaborations, and trends in ecosystem research along the Lower Colorado River.

## Notes

- The binary transformation (`ifelse(data.stand> 0, 1,0)`) often leads to stronger clustering results
- Outlier projects were removed to improve clustering (`c39`, `e14`, `e27`)
- Different distance metrics and clustering algorithms may produce varying results
