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

setwd("C:\\Users\\George\\Desktop\\report_no_dir")

#filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\speciesNames_1000.csv"
filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\habitatNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\dataNames.csv"


data = read.csv(filepath, header = TRUE, sep=",", row.names = 1)

#combine similar search terms

river <- rowSums(data[,c("reach", "river", "tributary", "tributaries", "spring", "freshwater", "riparian", "channel")])
laboratory <- rowSums(data[,c("impoundment", "raceway", "tank", "laboratory", "hatchery")])
lake <- rowSums(data[,c("shore", "lake", "reservoir", "sediment")])
marsh <- rowSums(data[,c("drainage", "flood", "floodplain", "wetland","backwater", "pond")])
woodland <- rowSums(data[,c("herbaceous",	"woody",	"woodlands",	"canopy",	"understory",	"wildfire",	"forest",	"foliage")])
agricultural<- rowSums(data[,c("agricultural",	"soil", "crop", "irrigation", "ditch", "reclamation", "dam")])
mines <- data[,c("mine")]
roosts<- rowSums(data[,c("roost", "roosting")])


data_combined <- data.frame(river, laboratory, lake, marsh, woodland, agricultural, mines, roosts)

#remove outlying nodes
#data_crop <- data[!rownames(data_combined) %in% c("c39", "e14"), ]
#data_crop <- data_combined
data_crop <- data_combined[!rownames(data_combined) %in% c("c39", "e14", "e27"), ]

#remove outlying variables
#data_crop <- data_crop[,c("fish","amphibian","bird","bat","vegetation","bacteria","zooplankton","mammal","frog","mussel","cottonwood", "mesquite","razorback","bonytail","chub","tamarisk","larval","eggs")]
#data_crop <- data_crop[,c("fish","bird", "bat")]

#create distance matrix
dis_mat <- dist(as.matrix(data_crop))


# #hcluster
fit <- hclust(dis_mat, method="ward.D")
plot(fit)
groups <- cutree(fit, k=15)
rect.hclust(fit, k=15, border="red")


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
tree_plot <- nj(as.dist(dis_mat))
#tree_plot <- nj(dis_mat)
plotTree(tree_plot)
#fig1<-plotTree(tree_plot, fsize=0.5)
#fig1<-nodelabels()

#set branches to same length
new_tree = compute.brlen(tree_plot,1)
plotTree(new_tree, fsize=0.8)
# #nodelabels


# #force-directed graph
# dis_mat <- dist(as.matrix(data_crop))
# dist_mi <- 1/dis_mat
# jpeg('example_forcedraw.jpg', width=1000, height=1000, unit='px')
# qgraph(dist_mi, layout='spring', vsize=3)
# dev.off()

