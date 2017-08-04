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

plants <- rowSums(data[,c("willow",	"quailbush",	"cedar",	"mesquite",	"arrowweed",	"cottonwood",	"cottonwood.willow", "milkvetch",	"buckwheat", "saltcedar",	"saltgrass",	"tamarisk")])
animals <- rowSums(data[,c("avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed","fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass","butterfly", "insect", "sootywing", "bat","amphibian", "frog")])
             
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


#####data terms######
fishTracking <- rowSums(data[,c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat")])
birdTracking <- rowSums(data[,c("call.playback","banded","banding","mist.netting","vocalization","singing","band","nest","nesting")])
birdPlumage <- rowSums(data[,c("display","plumage","colorimeter")])
trapping <- rowSums(data[,c("hoop","trapping","trap","capture","captured","release","mark","recapture","mark.recapture","netting","netted")])
tracking <- rowSums(data[,c("tag","telemetry","track","tracking","passive","active","transponder","transmitters","tagging","tagged","acoustic","sonic")])
physiology <- rowSums(data[,c("diet","physiology","physiological","growth","mass","height","weight","weighed","disease","aging", "sexed","tissue","cell","microscope","mortality")])
fishPhysiology <-rowSums(data[,c("pectoral","fin","swim","swimming")])
waterChemistry <- rowSums(data[,c("depth","oxygen","nitrogen","carbon","potassium","phosphorous","ammonia","salinity","nitrate","nitrite","acid","alkalinity","arsenic","selenium","conductivity","turbidity")])
soilChemistry <- rowSums(data[,c("pozzolan","lassenite","humidity","limnological","hydrology","hydrological")])
gis <- rowSums(data[,c("gis","satellite","map","mapping")])
hatchery <- rowSums(data[,c("hatchery","hatchery.reared","post.stocking","translocation","broodstock","repatriation","stocking","spawning")])
populationStats <- rowSums(data[,c("distribution","demography","absence","presence","population","diversity","anova","sampling","double.sampling","transect","survivorship","colonization","survival","recruitment")])
genetic <- rowSums(data[,c("genetic","dna","mtdna","microsatellites","haplotype","dimorphism","taxonomic")])
restoration <- rowSums(data[,c("reclamation","evaluation","study","conservation","development","plan","outreach","restoration","planting","clearing","monitoring","fertilization","fertilizer")])
photography <- rowSums(data[,c("video", "photo","photograph","photography","orthophotography","imaging")])
predation <- rowSums(data[,c("predation","predator","prey", "foraging")])
breeding <- rowSums(data[,c("nest","nesting","eggs","breeding","propagation")])
transport <-rowSums(data[,c("transport","handling","management")])
biologicalMeasures <-rowSums(data[,c("biomass","density","moisture","temperature","toxicity","abiotic","habitat")])
survey <- rowSums(data[,c("survey","search","sampled","aerial","visual","helicopter")])
#fish<-rowSums(data[,c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat","pectoral","fin","swim","swimming","fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass")])
#bird<-rowSums(data[,c("call.playback","banded","banding","mist.netting","vocalization","singing","band","display","plumage","colorimeter","avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed","nest","nesting")])
#insects <- rowSums(data[,c("butterfly", "insect", "sootywing")])
#bats <- rowSums(data[,c("bat","roost", "roosting","mine")])
#amphibians <- rowSums(data[,c("amphibian", "frog")])

data_experimental <- data.frame(fishTracking,birdTracking,birdPlumage,trapping,tracking,physiology,fishPhysiology,waterChemistry,soilChemistry,gis,hatchery,populationStats,genetic,restoration,photography,predation,breeding,transport,biologicalMeasures,survey)

#####plot project code vs component - fish, bird, amphbian, bat and all data terms#########
#opar <- par()
lablist<-row.names(data_experimental)
plot(x=data_experimental$fish+0.001,y=1:99, labels = FALSE, xlab = "Word Frequency (log scale)", ylab = "", log = "x", col= 1:99, pch = 0)
axis(1, at=seq(0.1, 10, by=1))
axis(2, at=seq(1, 99, by=1), labels = lablist, par(las=2), cex.axis = 0.5)
par(new=T)
#plot(x=data_experimental$bird+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 1)
#par(new=T)
#plot(x=data_experimental$insects+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 2)
#par(new=T)
#plot(x=data_experimental$bats+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 3)
#par(new=T)
#plot(x=data_experimental$amphibians+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 4)
#par(new=T)
#plot(x=data_experimental$plants+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 5)
#par(new=T)
plot(x=data_experimental$fishTracking+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 6)
par(new=T)
plot(x=data_experimental$birdTracking+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 7)
par(new=T)
plot(x=data_experimental$birdPlumage+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 8)
par(new=T)
plot(x=data_experimental$trapping+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 9)
par(new=T)
plot(x=data_experimental$tracking+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 10)
par(new=T)
plot(x=data_experimental$physiology+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 11)
par(new=T)
plot(x=data_experimental$fishPhysiology+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 12)
par(new=T)
plot(x=data_experimental$waterChemistry+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 13)
par(new=T)
plot(x=data_experimental$soilChemistry+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 14)
par(new=T)
plot(x=data_experimental$gis+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 15)
par(new=T)
plot(x=data_experimental$hatchery+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 16)
par(new=T)
plot(x=data_experimental$populationStats+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 17)
par(new=T)
plot(x=data_experimental$genetic+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 18)
par(new=T)
plot(x=data_experimental$restoration+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 19)
par(new=T)
plot(x=data_experimental$photography+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 20)
par(new=T)
plot(x=data_experimental$predation+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 21)
par(new=T)
plot(x=data_experimental$breeding+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 22)
par(new=T)
plot(x=data_experimental$transport+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 23)
par(new=T)
plot(x=data_experimental$biologicalMeasures+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 24)
par(new=T)
plot(x=data_experimental$survey+0.001,y=1:99, col= 1:99, axes = FALSE, labels = FALSE, xlab = "", ylab = "",log = "x", pch = 25)
par(new=T)

legend('bottomright',c("fishTracking","birdTracking","birdPlumage","trapping","tracking","physiology","fishPhysiology","waterChemistry","soilChemistry","gis","hatchery","populationStats","genetic","restoration","photography","predation","breeding","transport","biologicalMeasures","survey"), pch = c(0,1,2,3,4), cex = 0.7)
par(new=F)
#par(opar)
##############################################


#################################################################
######Choose Data set to Cluster#################################
#################################################################

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
kmeansValue = 7

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

#plot2groupings = data.frame(k.means.fit1$cluster,k.means.fit2$cluster)
#plot(plot2groupings)

#plot total number of projects mentioning data type
par(opar)
par(las=2) # make label text perpendicular to axis
par(mar=c(5,8,4,2)) # increase y-axis margin.
#create table of total number of projects mentioning data types
data.totals <- apply(data.stand, 2, sum)
barplot(data.totals, main="text mining LCR pdfs (99 project groupings)", horiz=TRUE,cex.names=0.8, xlim=c(0,100), cex.axis=0.8, xlab = "# of projects in which all reports match search term at least once")
par(opar)

#plot search term frequency for projects mentioning data type 
par(opar)
par(las=2) # make label text perpendicular to axis
par(mar=c(5,8,4,2)) # increase y-axis margin.
#create table of total number of projects mentioning data types
data.totals <- apply(data_crop, 2, mean)
#create function for standard error
se <- function(x) sqrt(var(x)/length(x))
#apply se function to data set
data.error <- apply(data_crop, 2, se)
fig<-barplot(data.totals, main="text mining LCR pdfs (99 project groupings)", horiz=TRUE,cex.names=0.8, xlim=c(0,0.25), cex.axis=0.8, xlab = "mean frequency of search terms")
#arrows(y0=fig,x0=data.totals+data.error,x1=data.totals-data.error,angle=90,code=3,length=0.1)
par(opar)

#####number of words in data search terms######
fishTracking_n <- length(c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat"))
birdTracking_n <- length(c("call.playback","banded","banding","mist.netting","vocalization","singing","band","nest","nesting"))
birdPlumage_n <- length(c("display","plumage","colorimeter"))
trapping_n <- length(c("hoop","trapping","trap","capture","captured","release","mark","recapture","mark.recapture","netting","netted"))
tracking_n <- length(c("tag","telemetry","track","tracking","passive","active","transponder","transmitters","tagging","tagged","acoustic","sonic"))
physiology_n <- length(c("diet","physiology","physiological","growth","mass","height","weight","weighed","disease","aging", "sexed","tissue","cell","microscope","mortality"))
fishPhysiology_n <-length(c("pectoral","fin","swim","swimming"))
waterChemistry_n <- length(c("depth","oxygen","nitrogen","carbon","potassium","phosphorous","ammonia","salinity","nitrate","nitrite","acid","alkalinity","arsenic","selenium","conductivity","turbidity"))
soilChemistry_n <- length(c("pozzolan","lassenite","humidity","limnological","hydrology","hydrological"))
gis_n <- length(c("gis","satellite","map","mapping"))
hatchery_n <- length(c("hatchery","hatchery.reared","post.stocking","translocation","broodstock","repatriation","stocking","spawning"))
populationStats_n <- length(c("distribution","demography","absence","presence","population","diversity","anova","sampling","double.sampling","transect","survivorship","colonization","survival","recruitment"))
genetic_n <- length(c("genetic","dna","mtdna","microsatellites","haplotype","dimorphism","taxonomic"))
restoration_n <- length(c("reclamation","evaluation","study","conservation","development","plan","outreach","restoration","planting","clearing","monitoring","fertilization","fertilizer"))
photography_n <- length(c("video", "photo","photograph","photography","orthophotography","imaging"))
predation_n <- length(c("predation","predator","prey", "foraging"))
breeding_n <- length(c("nest","nesting","eggs","breeding","propagation"))
transport_n <-length(c("transport","handling","management"))
biologicalMeasures_n <-length(c("biomass","density","moisture","temperature","toxicity","abiotic","habitat"))
survey_n <- length(c("survey","search","sampled","aerial","visual","helicopter"))
#fish_n<-length(c("submersible","sherman","fyke","electrofishing","sur","hydrophone","pit","trammel","implantation","boat","pectoral","fin","swim","swimming","fish","pikeminnow","razorback", "rasu",	"flannelmouth",	"humpback",	"chub",	"bonytail",	"rainbow",	"trout",	"catfish",	"bass"))
#bird_n<-length(c("call.playback","banded","banding","mist.netting","vocalization","singing","band","display","plumage","colorimeter","avian","woodpecker","bird","warbler","tanager","cuckoo", "owl","flycatcher",	"flicker",	"vireo",	"quail",	"blackbird",	"starling",	"dove",	"migrants",	"waterbirds",	"shorebirds", "yellow.billed","nest","nesting"))
#insects_n <- length(c("butterfly", "insect", "sootywing"))
#bats_n <- length(c("bat","roost", "roosting","mine"))
#amphibians_n <- length(c("amphibian", "frog"))
#plants_n <- length(c("willow",	"quailbush",	"cedar",	"mesquite",	"arrowweed",	"cottonwood",	"cottonwood.willow", "milkvetch",	"buckwheat", "saltcedar",	"saltgrass",	"tamarisk"))


data.wordNumber <- data.frame(fishTracking_n,birdTracking_n,birdPlumage_n,trapping_n,tracking_n,physiology_n,fishPhysiology_n,waterChemistry_n,soilChemistry_n,gis_n,hatchery_n,populationStats_n,genetic_n,restoration_n,photography_n,predation_n,breeding_n,transport_n,biologicalMeasures_n,survey_n)

#plot search term frequency for projects mentioning data type - normalized by number of words in search term
par(opar)
par(las=2) # make label text perpendicular to axis
par(mar=c(5,8,4,2)) # increase y-axis margin.
#create table of total number of projects mentioning data types
data.normalized <- apply(data_crop/as.numeric(data.wordNumber), 2, mean)
fig_normalized<-barplot(data.normalized, main="text mining LCR pdfs (99 project groupings)", horiz=TRUE,cex.names=0.8, xlim=c(0,0.025), cex.axis=0.8, xlab = "normalized mean frequency of search terms")
#arrows(y0=fig,x0=data.totals+data.error,x1=data.totals-data.error,angle=90,code=3,length=0.1)
par(opar)



