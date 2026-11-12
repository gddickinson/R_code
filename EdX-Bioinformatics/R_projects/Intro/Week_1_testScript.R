#R Test Srcipt
#George Dickinson
#May 3rd 2020
#The purpose of this script is to learn R

#install.packages("reshape2")
#install.packages("ggplot2")
library(ggplot2)
library(reshape2)

organism <- c("Human", "Chimpanzee", "Yeast")
chromosomes <- c(23, 24, 16)
multicellular <- c(TRUE, TRUE, FALSE)

organismTable <- data.frame(organism, chromosomes, multicellular)
write.table(organismTable, file = "MyData.csv",row.names=FALSE,
            na="",col.names=FALSE, sep=",")

NewDataFrame <- read.csv("MyData.csv", header=FALSE, sep=",")

count <- 0

for (val in organismTable$chromosomes){
  if (val > 20) count = count +1
}

print(count)

barplot(organismTable$chromosomes)

#load the data
rawdata <- read.csv("Week_1_Plotdata.csv", header=TRUE)

#simple plot of one column
ggplot(rawdata, aes(x=Subject, y=a)) + geom_point()

#convert data to simple X Y coordinates by Subject and condition
melted = melt(rawdata, id.vars ="Subject", measure.vars = c("a","c","d","e","f","g","j","k"))

#generate a ggplot and store in myPlot
myPlot <- ggplot(melted, aes(x=variable, y=value, col=Subject, group=Subject)) + geom_point() +
  geom_line() + 
  xlab("X Axis") + 
  ylab("Y Axis") + 
  ggtitle("My Nice Title")

#display plot
myPlot
#save plot
ggsave(filename="MyPlot.pdf", plot=myPlot)
