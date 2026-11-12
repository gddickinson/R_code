#BiocManager::install("Rgraphviz")
#BiocManager::install("graph")
#BiocManager::install("RBGL")
#BiocManager::install("yeastExpData")
library(graph)
library(Rgraphviz)
library(RBGL)
library(yeastExpData)

#load yeast expression data (see Ge et al 2001, Correlation between transcriptome and interactome mapping data from Saccharomyces cerevisiae)
#The litG library contains interaction data represented as a graph, where the vertices, or nodes,
#represent proteins, and edges between nodes indicate interaction
data("litG")

#retrieve the names of all of the proteins (vertices or nodes)
litGnodes <- nodes(litG) #nodes command is from the graph library

#view the first 25
litGnodes[1:25]

#see all of the proteins that interact with yeast protein YFL039C
adj(litG, "YFL039C")

#extract the subgraphs, or connected components,
connectedComponents <- connectedComp(litG)

#to see all members of subgraph 1
connectedComponents[[1]]

# save all of the nodes of subgraph3 to a variable component3 
component3 <- connectedComponents[[3]]

#use the subGraph command to pull out the nodes and edges from component3 
subgraph3 <- subGraph(component3, litG)

subgraph3

#plot
subgraph3plot <- layoutGraph(subgraph3, layoutType="neato")
renderGraph(subgraph3plot)

#degree distribution for the PPI dataset
numdegrees <- graph::degree(litG) #numdegrees contains the list of how many "links" each protein has

# sort the values so that we can plot the histogram out in increasing (or decreasing) order
numdegrees <- sort(numdegrees)

#get mean
meandeg <- mean(numdegrees)

#plot histogram
hist(numdegrees, col="red", main = paste("Degree Distribution - Protein Interactions in litG with a mean of " , meandeg))







