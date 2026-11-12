#BiocManager::install("edgeR")
#BiocManager::install("limma")
#BiocManager::install("Glimma")
#BiocManager::install("org.Mm.eg.db")

library(edgeR)
library(limma)
library(Glimma)
library(org.Mm.eg.db)
library(gplots)
library(RColorBrewer)

#load data
seqdata <- read.delim("GSE60450_Lactation-GenewiseCounts.txt", stringsAsFactors = FALSE) #metadata
sampleinfo <- read.delim("SampleInfo.txt") #gene count

#make a new dataset that contains only the counts
countdata <- seqdata[,-(1:2)]

#rename rows with Entrez Gene Id's (the first column of seqdata)
rownames(countdata) <- seqdata[,1]

#use the substr command to truncate the column names
colnames(countdata) <- substr(colnames(countdata),start=1,stop=7)

# filter the data to eliminate genes expressed at very low levels
#start by extracting the counts per million (CPMs)
myCPM <- cpm(countdata)
#thrreshold by CPM >0.5
thresh <- myCPM > 0.5
#stats
table(rowSums(thresh))

#filter
#get rid of genes that only show TRUE in zero or 1 samples
keep <- rowSums(thresh) >= 2
counts.keep <- countdata[keep,]


#sanity check
plot(myCPM[,1],countdata[,1])

#check smaller values
plot(myCPM[,1],countdata[,1],ylim=c(0,50),xlim=c(0,3))

#add threshold line
abline(v=0.5)

#If you look at the intercept of our plot and the vertical line, it does seem that our threshold
#corresponds to a count of about 11CPM – that's perfect for this analysis


#convert our truncated data from counts.keep to the dgelist format required for the EdgeR library
y <- DGEList(counts.keep)

#Quality Control (QC) checks
barplot(y$samples$lib.size,names=colnames(y),las=2)
title("Barplot of library sizes") 

#The distribution appears to be roughly equal – let's try a different plot type to check in a more
#statistical way, using a boxplot of the log of the counts
logcounts <- cpm(y, log=TRUE)
boxplot(logcounts, xlab="", ylab="Log2 counts per million",las=2)
abline(h=median(logcounts),col="blue")
title("Boxplots of logCPMs (unnormalised)")

#The boxplot indicates that the data is roughly evenly distributed amongst the samples, e.g. the
#boxes overlap and the median crosses through them all


#Another good QC comparison is an MDSplot – this stands for Multidimensional Scaling, and is
#essentially a visual representation of a principle components analysis.  This means that it can be
#used to see which individual elements contribute most strongly to any variation seen within the data.
#Let's do side-by-side MDS plots of the data where we color the samples by cell type on one side
#and by condition on the other.

#reset plot
par(mfrow=c(1,2))
#Let's find out how many cell types we have in our samples
levels(sampleinfo$CellType)
sampleinfo$CellType <-as.factor(sampleinfo$CellType)
col.cell <- c("red","blue")[sampleinfo$CellType]

plotMDS(y,col=col.cell)
legend("topleft",fill=c("blue","red"),legend=levels(sampleinfo$CellType))
title("Cell type")


#et's repeat this process for a plot where we color the plot by condition (or status, as it's called in
#our data)
sampleinfo$Status <-as.factor(sampleinfo$Status) #if nulls
#three colors needed
col.status <- c("blue","red","dark green")[sampleinfo$Status]
#make plot
plotMDS(y,col=col.status)
legend("topleft",fill=c("blue","red","dark green"), legend=levels(sampleinfo$Status),
        cex=0.8)
title("Status")


#Now we have two side-by-side MDS plots that show us the cell types and status that contribute the
#most to the variation – the most important factors will be further away from the 0,0 on the plot

#use corrected data to improve plots
sampleinfo <- read.delim("SampleInfo_Corrected.txt")


#redo plots
par(mfrow=c(1,2))

sampleinfo$CellType <-as.factor(sampleinfo$CellType)
sampleinfo$Status <-as.factor(sampleinfo$Status)
col.cell <- c("blue","red")[sampleinfo$CellType]
col.status <- c("blue","red","dark green")[sampleinfo$Status]

plotMDS(y,col=col.cell)
legend("topleft",fill=c("blue","red"),legend=levels(sampleinfo$CellType))
title("Cell type")
plotMDS(y,col=col.status)
legend("topleft",fill=c("blue","red","dark green"), legend = levels(sampleinfo$Status), cex=0.8)
title("Status")

#multi-dimensional analysis

#reset plot
par(mfrow=c(1,1))

#generate a character set to plot for the cell type
char.celltype <- c("X", "O") [sampleinfo$CellType]

#repeat above plot but  include the pch command to plot the cell types by the characters above
plotMDS(y,col=col.status,pch=char.celltype,cex=2)
legend("topright",legend=levels(sampleinfo$Status),col=col.status,pch=16)
legend("bottomright",legend=levels(sampleinfo$CellType),pch=c(1,4))
title("MDS Plot for first two dimension")

#Now let's add the dim command and plot alternate dimensions
#modify the first line to include dim=c(3,4) to plot dimensions 3 and 4 of the MDS.

plotMDS(y,dim=c(3,4), col=col.status,pch=char.celltype,cex=2)
legend("topright",legend=levels(sampleinfo$Status),col=col.status,pch=16)
legend("bottomright",legend=levels(sampleinfo$CellType),pch=c(1,4))
title("MDS Plot for dimensions 3 and 4") 

#What we've done with the MDS plots is really an example of cluster analysis – looking to see if
#common elements (or elements we suspect of having something in common) cluster together
#When we plotted the first two dimensions, there was a clear separation of common elements both
#by color and by status – in other words, the clustering was good.  It wasn't quite so good for
#dimensions 3 and 4. 

#There are many different types of cluster analysis we can perform on data – the easiest of which is
#hierarchical clustering.
#For large datasets the best way to visualize the results of clustering are heatmaps, rather than
#scatter plots – and gplots contains a command, heatmap.2, that will both perform a hierarchical
#clustering and generate a heatmap


#computing the variance in each row of our logcounts
var_genes <- apply(logcounts, 1, var)

#Before we use the variance to generate out clustering heatmap, let's limit the data to just the 500
#most variant genes – this will make the heatmap "easier" to examine
select_var <- names(sort(var_genes, decreasing=TRUE))[1:500]


# subset our logcounts by choosing only the genes that show up in select_var
highly_variable_lcpm <- logcounts[select_var,]


#to see a summary of the contents of highly_variable_lcpm we can use the dim command
dim(highly_variable_lcpm)

#we have 500 genes (rows), each of which has 12 values for expression (columns)

#One of the important components in generating a heatmap is choosing the color palette – the
#range of colors used to distinguish conditions

#brewer.pal from the RColorBrewer library, which is designed to help
#provide good palettes for complex data visualization
mypalette <- brewer.pal(11,"RdYlBu")

#Now that we have our palette, we can use the colorRampPalette command from the GRDevices
#library to generate a series of interpolated colors that will give us a nice full spectrum of colors that fall
#between the 11 we chose for my palette – this is crucial for displaying data that is "analog", where
#there are essentially an infinite number of values
morecols <- colorRampPalette(mypalette)

#perform the clustering and generate the heatmap – again, heatmap.2 from gplots
#will do both in one simple step
heatmap.2(highly_variable_lcpm,col=rev(morecols(50)),trace="none", main="Top 500 most variable genes across samples",
          ColSideColors = col.cell,scale="row")

#Here we are telling heatmap.2 to cluster and display as heatmap our
#data in highly_variable_lcpm using 50 shades of color sorted in reverse order from our
#morecols function.
#The trace="none" command instructs heatmap.2 not to draw connecting lines through
#columns or rows (go ahead and change the value to column or row and regenerate the plot to see the difference).
#The main command is how heatmap.2 generates titles.

#export by redirecting output to png
png(file="High_var_genes.heatmap.png")
heatmap.2(highly_variable_lcpm,col=rev(morecols(50)),trace="none", main="Top 500 most variable genes across samples",ColSideColors=col.cell,scale="row")

#turn off redirect
dev.off()

#alternative is to use dev.copy2pdf() - better reolution works on last plot
dev.copy2pdf() 

