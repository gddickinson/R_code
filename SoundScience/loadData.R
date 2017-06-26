#library("cluster", lib.loc="~/R/R-3.3.2/library")
#install.packages("qgraph")
#install.packages("ape")
#install.packages("phytools")
#install.packages("pvclust")
#install.packages("mclust")
#install.packages("cluster")
#install.packages("fpc")
library(ape)
library(phytools)
library(cluster)
library(qgraph)
library(mclust)

filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\searchResult_percent_1.csv"
data = read.csv(filepath, header = TRUE, sep=",", row.names = 1)

#remove outlying nodes
data_crop <- data[!rownames(data) %in% c("c39", "e14", "e27"), ]

#create distance matrix
dis_mat <- dist(as.matrix(data_crop))


# #hcluster
fit <- hclust(dis_mat, method="ward.D")
plot(fit)
groups <- cutree(fit, k=10)
rect.hclust(fit, k=10, border="red")


# #AGNES agglomerative nesting
#distMat = agnes(data_crop)
#plot(distMat)

##PAM
# dist.pam = pam(dis_mat,10)
# plot(dist.pam)

# # Model Based Clustering
#fit <- Mclust(dis_mat)
#plot(fit) # plot results
#summary(fit) # display the best model


# #tree using ape
# tree_plot <- nj(as.dist(dis_mat))
# plotTree(tree_plot)
# #fig1<-plotTree(tree_plot, fsize=0.5)
# #fig1<-nodelabels()
# 
# #set branches to same length
# new_tree = compute.brlen(tree_plot,1)
# plotTree(new_tree, fsize=0.5)
# #nodelabels


# #force-directed graph
# dis_mat <- dist(as.matrix(data_crop))
# dist_mi <- 1/dis_mat
# jpeg('example_forcedraw.jpg', width=1000, height=1000, unit='px')
# qgraph(dist_mi, layout='spring', vsize=3)
# dev.off()

