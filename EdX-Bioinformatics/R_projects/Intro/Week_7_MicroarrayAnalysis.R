BiocManager::install("affy")
BiocManager::install("limma")
library(affy)
library(limma)

affy.data <- ReadAffy()
eset.mas5 <- mas5(affy.data)

#retrieve the normalized expression matrix and store it as an expression set
exprSet.nologs <- exprs(eset.mas5)

#rename cols
colnames(exprSet.nologs) <- c("brain.1", "brain.2", "fetal.brain.1", "fetal.brain.2", "fetal.liver.1",
                              "fetal.liver.2", "liver.1", "liver.2")



#convert exprSet.nologs to a log base 2 binary dataset called exprSet 
exprSet <- log(exprSet.nologs, 2)
#export
write.table(exprSet, file="Su_mas5_matrix.txt", quote=F, sep="\t")

#absent/present check
data.mas5calls <- mas5calls(affy.data)
data.mas5calls.calls <- exprs(data.mas5calls)


brain.fetalbrain.2color <- read.maimages("brain.fetalbrain.2color.data.txt",
                                         columns=list(G="brain.1", R="fetal.brain.1", Gb="bg1", Rb="bg2"))



#normalize colour
brain.fetalbrain.2color.loess <- normalizeWithinArrays(brain.fetalbrain.2color, method="loess")


#plotting
par(mfrow=c(1,2))
plotMA(brain.fetalbrain.2color)
plotMA(brain.fetalbrain.2color.loess)

# takes the means of the concatenated values (e.g. brain.1 and brain.2) from
#exprSet; the apply command makes sure that the means command is expressed to each pair of
#values within that set
brain.mean <- apply(exprSet[, c("brain.1", "brain.2")], 1, mean)
fetal.brain.mean <- apply(exprSet[, c("fetal.brain.1", "fetal.brain.2")], 1, mean)
liver.mean <- apply(exprSet[, c("liver.1", "liver.2")], 1, mean)
fetal.liver.mean <- apply(exprSet[, c("fetal.liver.1", "fetal.liver.2")], 1, mean)

#calculate the ratio
#Since we've already done log-transformations of the expression values, this is actually a matter of
#subtraction recall that log(A / B) = log(A) - log(B
brain.fetal.to.adult <- fetal.brain.mean - brain.mean
liver.fetal.to.adult <- fetal.liver.mean - liver.mean

all.data <- cbind(exprSet, brain.mean, fetal.brain.mean, liver.mean, fetal.liver.mean, brain.fetal.to.adult,
                  liver.fetal.to.adult)

#export
write.table(all.data, file = "Microarray_ALL.txt", quote=F, sep="\t")


#T test on  adult vs fetal brain data
#get all data
dataset.1 <- exprSet[1, c("brain.1", "brain.2")]
dataset.2 <- exprSet[1, c("fetal.brain.1", "fetal.brain.2")]

#T-Test
t.test.gene.1 <- t.test(dataset.1, dataset.2, "two.sided")

#use apply command again and apply a T test across the relevant columns to compare
#adult brain expression values to fetal
brain.p.value.all.genes <- apply(exprSet, 1, function(x){ t.test(x[1:2], x[3:4]) $p.value } )
liver.p.value.all.genes <- apply(exprSet, 1, function(x) { t.test(x[5:6], x[7:8]) $p.value } )

#Use A/P test from before and filter out genes that are uninformative
AP <- apply(data.mas5calls.calls, 1, paste, collapse="")

#remove any gene that has all A values
genes.present = names(AP[AP != "AAAAAAAA"])
length(genes.present) 


#Now we can create a new dataset by taking the subset of exprSet that has data – add this line to your script and RUN it:
exprSet.present <- exprSet[genes.present,]


#Now we're going to look at our p values from the t test – but we need to adjust for the FDR, or false discovery rate.
#FDR correction is necessary when looking at many thousands of tests as a way of minimizing the
#false positives that inevitably are found when so many samples are analyzed, e.g. 5% of the time a
#95% confidence interval is wrong.

#isolate the p values from our t test for only genes that are informative
brain.raw.pvals.present <- brain.p.value.all.genes[genes.present]
liver.raw.pvals.present <- liver.p.value.all.genes[genes.present]

#FDR correction is built-in
#p values are automatically adjusted to compensate for the false discovery rate 
brain.fdr.pvals.present <- p.adjust(brain.raw.pvals.present, method="fdr")
liver.fdr.pvals.present <- p.adjust(liver.raw.pvals.present, method="fdr")


#sort genes by p-values
#increasing order of significance (meaning that there are significant differences between tissues)
brain.fdr.pvals.present.sorted <- brain.fdr.pvals.present[order(brain.fdr.pvals.present)]
liver.fdr.pvals.present.sorted <- liver.fdr.pvals.present[order(liver.fdr.pvals.present)]

#first 10 in terms of lowest p-values which means highest significance
brain.fdr.pvals.present.sorted[1:10]
liver.fdr.pvals.present.sorted[1:10]

#theshold by highest significance
brain.DE.probesets <- names(brain.raw.pvals.present[brain.raw.pvals.present < 0.01])
liver.DE.probesets <- names(liver.raw.pvals.present[liver.raw.pvals.present < 0.01])

#pull out the log base 2 ratios for the genes in those dataset
brain.DE.log2.ratios <- all.data[brain.DE.probesets, c("brain.fetal.to.adult", "liver.fetal.to.adult")]
liver.DE.log2.ratios <- all.data[liver.DE.probesets, c("brain.fetal.to.adult", "liver.fetal.to.adult")]

#export
write.table(brain.DE.log2.ratios, "brain.DE.log2.ratios.txt", sep="\t", quote=F)
write.table(liver.DE.log2.ratios, "liver.DE.log2.ratios.txt", sep="\t", quote=F)

#reset plotting layout
par(mfrow=c(1,1))

#generate a simple intensity scatterplot comparing adult and fetal brain expression
x.data <- all.data[, "brain.mean"]
y.data <- all.data[, "fetal.brain.mean"]

#generate a scatter plot where each point represents a gene, and it's position in graph-space
#represents it's relative expression levels in adult vs fetal brain.
#If expression were identical in both tissues, we would expect to see the gene lie along the diagonal
#of the graph.
plot(x.data, y.data, main = "Log2 expression in fetal brain (n=2) vs adult brain (n=2)", xlab="brain", ylab="fetal brain", col="blue", cex=0.5)
#show diagonal
abline(0,1)

#generate a different type of plot – this one is called a Ratio Intensity Plot, also known as an MA
#or Bland-Altman plot
#MA Plots are commonly used for genomic data – they help display the difference between
#measurements between two samples by transforming the data onto a log ratio (or M) scale and an
#average (or A) scale; these are then used as X and Y values.

#First we need to calculate our average (A) and log ratio (M) values
brain = all.data[, "brain.mean"]
fetal.brain = all.data[, "fetal.brain.mean"]

#calculate the A (average):
A = (fetal.brain + brain) / 2

#calculate the M – recall that we already have done a log transform, so as before the ratio is computed simply by subtracting
M = fetal.brain - brain

#simple scatter plot using A and M as our X and Y coordinates:
plot(A, M, main="MA plot of fetal brain vs brain", pch=19, cex=0.2, col="red")

#Volcano Plot
#This visualization plots significance (p value) versus fold-change on the y and x axes

#concatenates the columns containing the p-values, both raw and FDR corrected, from
#exprSet.present into our new dataset, expression.plus.pvals
expression.plus.pvals = cbind(exprSet.present, brain.raw.pvals.present, brain.fdr.pvals.present,
                              liver.raw.pvals.present, liver.fdr.pvals.present)



#calculate the log base 2 ratios – again simply by subtracting the already-log-transformed values.
log2.ratios = expression.plus.pvals[, "brain.1"] -  expression.plus.pvals[, "fetal.brain.1"]

#We're going to plot against the adult brain expression values, so we put those into a variable
p.values = expression.plus.pvals[, "brain.raw.pvals.present"]

#Recall that a volcano plot is simply the p-values on the Y axis and the fold-difference on the X
#Notice that within the plot formula we did a quick log base 10 transform of the raw p-values; this
#gives us an easier to read plot (albeit the Y axis is now a log axis)
plot(log2.ratios, -log(p.values, 10) )


#plot results together
#To read a volcano plot, you look for the points that are furthest away from the bottom center –
#those points represent the genes that are most deferentially expressed
par(mfrow=c(1,2))
plot(log2.ratios, p.values)
plot(log2.ratios, -log(p.values, 10) )

