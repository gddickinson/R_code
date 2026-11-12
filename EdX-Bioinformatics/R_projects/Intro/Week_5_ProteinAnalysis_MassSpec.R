#Protein Analysis
library(gplots)
peptides.txt <- read.table("peptidefrags.txt", header=FALSE)
peptides <-as.vector(peptides.txt$V1)
hist(peptides,breaks=100) 

mascot.txt <- read.table("mascot.txt", header=FALSE)
xtandem.txt <- read.table("xtandem.txt", header=FALSE)
protpro.txt <- read.table("protpro.txt", header=FALSE)
mascot<-as.vector(mascot.txt$V1)
xtandem<-as.vector(xtandem.txt$V1)
protpro<-as.vector(protpro.txt$V1)

#create list with all three vectors
combinedMSdata <- list(Mascot=mascot, XTandem=xtandem, ProtPro=protpro)

#make venn diagram
venn(combinedMSdata)







