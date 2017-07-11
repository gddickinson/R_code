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


#https://rstudio-pubs-static.s3.amazonaws.com/33876_1d7794d9a86647ca90c4f182df93f0e8.html

setwd("C:\\Users\\George\\Desktop\\report_no_dir")

#filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\speciesNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\habitatNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\dataNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\data_habitatNames.csv"
filepath <- "C:\\Users\\George\\Desktop\\report_no_dir\\data_habitat_speciesNames.csv"

data = read.csv(filepath, header = TRUE, sep=",", row.names = 1)

#combine similar search terms


######speciesNames###################
birds <- rowSums(data[,c("avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed")])
fish <- rowSums(data[,c("fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass")])
plants <- rowSums(data[,c("deciduous","weed","plant",	"tree",	"shrub","willow",	"quailbush",	"cedar",	"mesquite",	"arrowweed",	"cottonwood",	"cottonwood.willow", "milkvetch",	"buckwheat", "saltcedar",	"saltgrass",	"tamarisk")])
insects <- rowSums(data[,c("butterfly", "insect", "sootywing")])
bats <- data[,c("bat")]
amphibians <- rowSums(data[,c("amphibian", "frog")])
             
data_combined <- data.frame(birds, fish, plants, insects, bats, amphibians)
#########################################
            
####### habitatNames #################
river <- rowSums(data[,c("reach", "river", "tributary", "tributaries", "spring", "freshwater", "riparian", "channel")])
laboratory <- rowSums(data[,c("impoundment", "raceway", "tank", "laboratory", "hatchery")])
lake <- rowSums(data[,c("shore", "lake")])
reservoir <- rowSums(data[,c("reservoir", "sediment", "dam", "pond")])
marsh <- rowSums(data[,c("flood", "floodplain", "wetland","backwater")])
woodland <- rowSums(data[,c("herbaceous",	"woody",	"woodlands",	"canopy",	"understory",	"wildfire",	"forest",	"foliage")])
agricultural<- rowSums(data[,c("agricultural",	"soil", "crop", "irrigation", "ditch", "reclamation", "sediment", "drainage")])
mines <- data[,c("mine")]
roosts<- rowSums(data[,c("roost", "roosting")])
# 
# data_combined <- data.frame(river, laboratory, reservoir, lake, marsh, woodland, agricultural, mines, roosts)
######################################

####### dataNames ####################

fishTracking <- rowSums(data[,c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat")])
birdTracking <- rowSums(data[,c("call.playback","banded","banding","mist.netting","vocalization","singing","band")])
birdPlumage <- rowSums(data[,c("display","plumage","colorimeter")])
trapping <- rowSums(data[,c("hoop","trapping","trap","capture","captured","release","mark","recapture","mark.recapture","netting","netted")])
tracking <- rowSums(data[,c("tag","telemetry","track","tracking","passive","active","transponder","transmitters","tagging","tagged","acoustic","sonic")])
physiology <- rowSums(data[,c("physiology","physiological","growth","mass","height","weight","weighed","disease","aging", "sexed","tissue","cell","microscope","mortality")])
fishPhysiology <-rowSums(data[,c("pectoral","fin","swim","swimming")])
waterChemistry <- rowSums(data[,c("depth","oxygen","nitrogen","carbon","potassium","phosphorous","ammonia","salinity","nitrate","nitrite","acid","alkalinity","arsenic","selenium","conductivity","turbidity")])
soilChemistry <- rowSums(data[,c("pozzolan","lassenite","humidity","limnological","hydrology","hydrological")])
gis <- rowSums(data[,c("gis","satellite","map","mapping")])
hatchery <- rowSums(data[,c("hatchery.reared","post.stocking","translocation","broodstock","repatriation","stocking","spawning")])
populationStats <- rowSums(data[,c("distribution","demography","absence","presence","population","diversity","anova","sampling","double.sampling","transect","survivorship","colonization","survival","recruitment")])
genetic <- rowSums(data[,c("genetic","dna","mtdna","microsatellites","haplotype","dimorphism","taxonomic")])
restoration <- rowSums(data[,c("evaluation","study","conservation","development","plan","outreach","restoration","planting","clearing","monitoring")])
photography <- rowSums(data[,c("video", "photo","photograph","photography","orthophotography","imaging")])
predation <- rowSums(data[,c("predation","predator","prey", "foraging")])
breeding <- rowSums(data[,c("nest","nesting","eggs","breeding","propagation")])
transport <-rowSums(data[,c("transport","handling","management")])
diet <-data[,c("diet")]
biologicalMeasures <-rowSums(data[,c("biomass","density","moisture","temperature","toxicity","abiotic","habitat")])
survey <- rowSums(data[,c("survey","search","sampled","aerial","visual","helicopter")])
fertilizer <- rowSums(data[,c("fertilization","fertilizer")])

#all data sets
#data_combined <- data.frame(fishTracking,birdTracking,birdPlumage,trapping,tracking,physiology,fishPhysiology,waterChemistry,soilChemistry,gis,hatchery,populationStats,genetic,restoration,photography,predation,breeding,transport,diet,biologicalMeasures,survey,fertilizer)

#selected data
#data_combined <- data.frame(fishTracking,birdTracking)

######################################

#####data, habitat and species names########
data_combined <- data.frame(birds, fish, plants, insects, bats, amphibians,fishTracking,birdTracking,birdPlumage,trapping,tracking,physiology,fishPhysiology,waterChemistry,soilChemistry,gis,hatchery,populationStats,genetic,restoration,photography,predation,breeding,transport,diet,biologicalMeasures,survey,fertilizer,river, laboratory, reservoir, lake, marsh, woodland, agricultural, mines, roosts)
###################################


#remove outlying nodes
#data_crop <- data_combined[!rownames(data_combined) %in% c("c39", "e14", "e18"), ]
#data_crop <- data_combined
data_crop <- data_combined[!rownames(data_combined) %in% c("c39", "e14", "e27", "e18"), ]

#data_crop <- data_crop[,c("fish","amphibian","bird","bat","vegetation","bacteria","zooplankton","mammal","frog","mussel","cottonwood", "mesquite","razorback","bonytail","chub","tamarisk","larval","eggs")]
#data_crop <- data_crop[,c("fish","bird", "bat")]


################################################################
# K-Means

# # Determine number of clusters
wss <- (nrow(data_crop)-1)*sum(apply(data_crop,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(data_crop,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

# To standarize the variables
#data.stand <- scale(data_crop) 

#not standardized
data.stand <- data_crop

#set number of clusters
kmeansValue = 12


k.means.fit <- kmeans(data.stand, kmeansValue) # k = 10
#attributes(k.means.fit)

# Centroids:
k.means.fit$centers

# Clusters:
k.means.fit$cluster

# Cluster size:
k.means.fit$size

#dosen't work if too many variables
clusplot(data.stand, k.means.fit$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)


#################################################
# Euclidean distance matrix.
d <- dist(data.stand, method = "euclidean") # Euclidean distance matrix.

H.fit <- hclust(d, method="ward.D")

plot(H.fit) # display dendogram
Euc_groups <- cutree(H.fit, k=kmeansValue) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(H.fit, k=kmeansValue, border="red") 

o = data.frame(Euc_groups,k.means.fit$cluster)
