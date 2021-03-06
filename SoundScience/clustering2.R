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
library(lattice)
library(plotrix)

#https://rstudio-pubs-static.s3.amazonaws.com/33876_1d7794d9a86647ca90c4f182df93f0e8.html

setwd("C:\\Users\\George\\Desktop\\SoundScience\\report_no_dir")

#filepath <- "C:\\Users\\George\\Desktop\\SoundScience\\report_no_dir\\speciesNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\SoundScience\\report_no_dir\\habitatNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\SoundScience\\report_no_dir\\dataNames.csv"
#filepath <- "C:\\Users\\George\\Desktop\\SoundScience\\report_no_dir\\data_habitatNames.csv"
filepath <- "C:\\Users\\George\\Desktop\\SoundScience\\report_no_dir\\data_habitat_speciesNames.csv"

data = read.csv(filepath, header = TRUE, sep=",", row.names = 1)

#combine similar search terms


######speciesNames###################
birds <- rowSums(data[,c("avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed")])
fish <- rowSums(data[,c("fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass")])
insects <- rowSums(data[,c("butterfly", "insect", "sootywing")])
bats <- data[,c("bat")]
amphibians <- rowSums(data[,c("amphibian", "frog")])
mouse_rat <- rowSums(data[,c("mouse","rat","sigmodon","rodent")])
#reptiles <- rowSums(data[,c("tortoise","reptile")])

plants <- rowSums(data[,c("deciduous","weed","plant",	"tree",	"shrub","willow",	"quailbush",	"cedar",	"mesquite",	"arrowweed",	"cottonwood",	"cottonwood.willow", "milkvetch",	"buckwheat", "saltcedar",	"saltgrass",	"tamarisk")])
animals <- rowSums(data[,c("mouse","rat","sigmodon","rodent","avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed","fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass","butterfly", "insect", "sootywing", "bat","amphibian", "frog")])
             
data_combined1 <- data.frame(birds, fish, plants, insects, bats, amphibians)

######plot 2 components##################
data_combined1 <- data.frame(plants,animals)
plot(data_combined1, xlim = c(0, 0.01), ylim=c(0,0.2),col= "white", pch = 19, cex = 1, lty = "solid", lwd = 2)
text(data_combined1$plants,data_combined1$animals,labels = row.names(data_combined1))
#########################################


######barplot project code vs component#######
#opar <- par()
#par(las=2)
#barplot(data_combined1$plants, horiz=TRUE, names.arg=row.names(data_combined1), cex.names =0.4, pch = 2)
#par(opar)
###########################################

#####plot project code vs component - animals and plants#########
#opar <- par()
lablist<-row.names(data_combined1)
plot(x=data_combined1$plants+0.001,y=1:99, labels = FALSE, xlab = "Word Frequency (log scale)", ylab = "", log = "x")
axis(1, at=seq(0.1, 1.3, by=0.1))
axis(2, at=seq(1, 99, by=1), labels = lablist, par(las=2), cex.axis = 0.5)
par(new=T)
plot(x=data_combined1$animals+0.001,y=1:99, col=3, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x")
legend('topright',c("plants","animals"), pch = 1, col = c(1,3))
par(new=F)
#par(opar)
##############################################
            
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

outdoors<-rowSums(data[,c("reach", "river", "tributary", "tributaries", "spring", "freshwater", "riparian", "channel","shore", "lake","reservoir", "sediment", "dam", "pond","flood", "floodplain", "wetland","backwater","herbaceous","woody","woodlands","canopy","understory",	"wildfire",	"forest",	"foliage","agricultural",	"soil", "crop", "irrigation", "ditch", "reclamation", "sediment", "drainage","mine","roost", "roosting")])


# data_combined <- data.frame(river, laboratory, reservoir, lake, marsh, woodland, agricultural, mines, roosts)
data_habitat <- data.frame(outdoors,laboratory)
######################################

#####plot project code vs component - outdoors and laboratory#########
#opar <- par()
lablist<-row.names(data_habitat)
plot(x=data_habitat$outdoors+0.001,y=1:99, labels = FALSE, xlab = "Word Frequency (log scale)", ylab = "", log = "x")
axis(1, at=seq(0.1, 1.3, by=0.1))
axis(2, at=seq(1, 99, by=1), labels = lablist, par(las=2), cex.axis = 0.5)
par(new=T)
plot(x=data_habitat$laboratory+0.001,y=1:99, col=3, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x")
legend('topright',c("outdoors","laboratory"), pch = 1, col = c(1,3))
par(new=F)
#par(opar)
##############################################


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
wildfire <- rowSums(data[,c("fire","wildfire")])

##### fish and bird techniques################
#fish<-rowSums(data[,c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat","pectoral","fin","swim","swimming")])
#bird<-rowSums(data[,c("call.playback","banded","banding","mist.netting","vocalization","singing","band","display","plumage","colorimeter")])

# #####plot project code vs component - birds and fish#########
# #opar <- par()
# lablist<-row.names(data_experimental)
# plot(x=data_experimental$fish+0.001,y=1:99, labels = FALSE, xlab = "Word Frequency (log scale)", ylab = "", log = "x", col= 1:99, pch = 0)
# axis(1, at=seq(0.1, 10, by=1))
# axis(2, at=seq(1, 99, by=1), labels = lablist, par(las=2), cex.axis = 0.5)
# par(new=T)
# plot(x=data_experimental$bird+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x")
# legend('topright',c("fish","birds"), pch = c(0,1))
# par(new=F)
# #par(opar)
# ##############################################

# #### genetic - non-genetic techniques###########
# 
# genetic_bin<-ifelse(genetic> 0, 1,0)
# other_bin<-ifelse(genetic> 0, 0,1)
# 
# data_experimental <- data.frame(genetic_bin,other_bin)                        
# 
# #################################################

# #####plot project code vs component - genetic#########
# #opar <- par()
# lablist<-row.names(data_experimental)
# plot(x=data_experimental$genetic_bin+0.001,y=1:99, labels = FALSE, xlab = "Word Frequency (log scale)", ylab = "", log = "x", col= 1:99, pch = 0)
# axis(1, at=seq(0.1, 10, by=1))
# axis(2, at=seq(1, 99, by=1), labels = lablist, par(las=2), cex.axis = 0.5)
# par(new=T)
# plot(x=data_experimental$other_bin+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 1)
# 
# legend('bottomright',c("genetic","other"), pch = c(0,1), cex = 0.7)
# par(new=F)
# #par(opar)
# ##############################################


#####fish, bird, amphbian, bat - all terms######
fish<-rowSums(data[,c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat","pectoral","fin","swim","swimming","fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass")])
bird<-rowSums(data[,c("call.playback","banded","banding","mist.netting","vocalization","singing","band","display","plumage","colorimeter","avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed","nest","nesting")])
insects <- rowSums(data[,c("butterfly", "insect", "sootywing")])
bats <- rowSums(data[,c("bat","roost", "roosting","mine")])
amphibians <- rowSums(data[,c("amphibian", "frog")])

data_experimental <- data.frame(fish,bird,insects,bats,amphibians,mouse_rat,plants)

#####plot project code vs component - fish, bird, amphbian, bat - all terms#########
#opar <- par()
lablist<-row.names(data_experimental)
plot(x=data_experimental$fish+0.001,y=1:99, labels = FALSE, xlab = "Word Frequency (log scale)", ylab = "", log = "x", col= 1:99, pch = 0)
axis(1, at=seq(0.1, 10, by=1))
axis(2, at=seq(1, 99, by=1), labels = lablist, par(las=2), cex.axis = 0.5)
par(new=T)
plot(x=data_experimental$bird+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 1)
par(new=T)
plot(x=data_experimental$insects+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 2)
par(new=T)
plot(x=data_experimental$bats+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 3)
par(new=T)
plot(x=data_experimental$amphibians+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 4)
par(new=T)
plot(x=data_experimental$mouse_rat+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 5)
#par(new=T)
#plot(x=data_experimental$reptiles+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 6)

par(new=T)
plot(x=data_experimental$plants+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 7)


legend('bottomright',c("fish","birds","insects","bats","amphibians", "mouse_rat", "plants"), pch = c(0,1,2,3,4), cex = 0.7)
par(new=F)
#par(opar)
##############################################



#all data sets
#data_combined2 <- data.frame(fishTracking,birdTracking,birdPlumage,trapping,tracking,physiology,fishPhysiology,waterChemistry,soilChemistry,gis,hatchery,populationStats,genetic,restoration,photography,predation,breeding,transport,diet,biologicalMeasures,survey,fertilizer)

#selected data
#data_combined <- data.frame(fishTracking,birdTracking)

######################################

#####data, habitat and species names########
#data_combined <- data.frame(birds, fish, plants, insects, bats, amphibians,fishTracking,birdTracking,birdPlumage,trapping,tracking,physiology,fishPhysiology,waterChemistry,soilChemistry,gis,hatchery,populationStats,genetic,restoration,photography,predation,breeding,transport,diet,biologicalMeasures,survey,fertilizer,river, laboratory, reservoir, lake, marsh, woodland, agricultural, mines, roosts)
###################################


#################################################################
######Choose Data set to Cluster#################################
#################################################################

#remove outlying nodes
#data_crop <- data_combined[!rownames(data_combined) %in% c("c39", "e14", "e18"), ]
#data_crop <- data_combined
#data_crop1 <- data_combined1[!rownames(data_combined1) %in% c("c39", "e14", "e27", "e18"), ]
#data_crop2 <- data_combined2[!rownames(data_combined2) %in% c("c39", "e14", "e27", "e18"), ]
#data_crop <- data_crop[,c("fish","amphibian","bird","bat","vegetation","bacteria","zooplankton","mammal","frog","mussel","cottonwood", "mesquite","razorback","bonytail","chub","tamarisk","larval","eggs")]
#data_crop <- data_crop[,c("fish","bird", "bat")]
data_crop <- data_experimental

################################################################

# To standarize the variables
#data.stand <- scale(data_crop) 

#not standardized
data.stand <- data_crop
#data.stand1 <- data_crop1
#data.stand2 <- data_crop2

#####Using binary values leads to stronger clustering############
#set values > 0 to 1
data.stand <- ifelse(data.stand> 0, 1,0)


###### K-Means #################################################
# # Determine number of clusters################################
n <- 15
x<-seq(n)

wss <- (nrow(data.stand)-1)*sum(apply(data.stand,2,var))
for (i in 2:n) wss[i] <- sum(kmeans(data.stand,
                                     centers=i)$withinss)
plot(x, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")


wss_data <- data.frame(x,wss)
##fit smoothed line#######
loess_fit <- loess(wss ~ x,wss_data)
lines(wss_data$x, predict(loess_fit), col = "blue")

##########################

#set number of clusters
kmeansValue = 6

k.means.fit <- kmeans(data.stand, kmeansValue) # k = 11
#k.means.fit1 <- kmeans(data.stand1, kmeansValue) # k = 11
#k.means.fit2 <- kmeans(data.stand2, kmeansValue) # k = 11
#attributes(k.means.fit)

# Centroids:
k.means.fit$centers
#k.means.fit1$centers
#k.means.fit2$centers

# Clusters:
k.means.fit$cluster
#k.means.fit1$cluster
#k.means.fit2$cluster

# Cluster size:
k.means.fit$size
#k.means.fit1$size
#k.means.fit2$size

#dosen't work if too many variables
clusplot(data.stand, k.means.fit$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)

# clusplot(data.stand, k.means.fit1$cluster, main='2D representation of the Cluster solution',
#          color=TRUE, shade=TRUE,
#          labels=2, lines=0)
# 
# clusplot(data.stand, k.means.fit2$cluster, main='2D representation of the Cluster solution',
#          color=TRUE, shade=TRUE,
#          labels=2, lines=0)

######################################################################
########### Euclidean distance matrix. ###############################
d <- dist(data.stand, method = "euclidean") # Euclidean distance matrix.

# d1 <- dist(data.stand1, method = "euclidean") # Euclidean distance matrix.
# d2 <- dist(data.stand2, method = "euclidean") # Euclidean distance matrix.

H.fit <- hclust(d, method="ward.D")

# H.fit1 <- hclust(d1, method="ward.D")
# H.fit2 <- hclust(d2, method="ward.D")

plot(H.fit) # display dendogram
Euc_groups <- cutree(H.fit, k=kmeansValue) # cut tree into k clusters
# draw dendogram with red borders around the k clusters
rect.hclust(H.fit, k=kmeansValue, border="red") 

o = data.frame(Euc_groups,k.means.fit$cluster)

# plot2groupings = data.frame(k.means.fit1$cluster,k.means.fit2$cluster)
# plot(plot2groupings)

comparison <-data.frame(o,data.stand)