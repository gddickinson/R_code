#Linear Discriminate Analysis

#install.packages('timeSeries')
#install.packages('MASS')
#install.packages('rgl')

library(timeSeries)
library(MASS)
library(rgl)
library(ggplot2)

Dataset <- read.csv("ms.csv", header=TRUE, na.strings="NA", dec=".", strip.white=TRUE)

#limit dataset to protein data of interest
RawData <- Dataset[,2:14]

#eliminate empty columns

#Get the standard deviation for the columns in RawData dataframe, and wherever the value is NOT zero (!=0.0), creates a vector called
#filledcols listing those columns. 
filledcols = colSds(RawData) != 0.0
#Rreplace the RawData dataframe with only those columns that were identified in the vector filledcols. 
RawData <- RawData[,filledcols]

#LDA
#create the LDA probabilities for each class in X1 based on the values in Dataset and store them in our variable, test1.lda
test1.lda <- lda(Dataset$X1 ~ . , data=Dataset)

#generate the actual LDA values by testing these probabilities against the data itself:
test1.lda.values <- predict(test1.lda,Dataset)

#we have 3 columns of values – one is the sample number, and the other two are the LDA scores for that sample
#You will always have N-1 LDA scores for a dataset which contains N conditions, e.g. if you had 6 conditions you would end up with 5 LDA score columns as the output
test1.lda.values

#prepare data for plotting
#The $x[,1] specifies that we are taking the first column from the X list from test1.lda.values – it's
#important to leave the comma in as that is how you specify that you are looking at all rows and the
#specified column
x <- test1.lda.values$x[,1]
y <- test1.lda.values$x[,2]

#Create vector class to be used in our plot
class <- Dataset$X1

#create a dataframe that consists of our plot data X and Y values with their matching class
plotdata <- data.frame(class, x, y)

#use the aggregate command and column-bind the x and y values per class from plotdata, using the mean as the result 
centroids <- aggregate(cbind(x,y)~class,plotdata,mean)

#generate a distance matrix from the dataframe centroids using straight-line (euclidean) geometry 
#This – only generates the "upper" part of the matrix
CentroidDistances <- dist(centroids, method = "euclidean", diag = TRUE, upper = FALSE, p = 2)
CentroidDistances

#add the label value to CentroidDistances using attr 
attr(CentroidDistances, "Labels") <- centroids$class

#plot
plot1 <- ggplot(plotdata,aes(x,y,color=factor(class))) + geom_point(size=3) + geom_point(data=centroids,size=7) + geom_text(data=centroids, size=7, label=centroids$class, colour="black") + ggtitle("LDA of Conditions 1-3") + geom_text(aes(label=Dataset$X1),hjust=0, vjust=0, colour="black")
plot1

#save plot
ggsave(filename="plot1.pdf")
#save distances
write.csv(as.matrix(CentroidDistances, file = "centroiddistances.csv"))

