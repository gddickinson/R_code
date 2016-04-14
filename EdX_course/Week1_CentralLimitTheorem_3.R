library(downloader)
library(rafalib)
library(dplyr)
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/femaleMiceWeights.csv"
filename <- "femaleMiceWeights.csv"
if(!file.exists("femaleMiceWeights.csv")) download(url,destfile=filename)
dat <- read.csv(filename)


#exercises 1-2
set.seed(1)
n=100
props <- replicate(1000, mean(sample(1:6, n, replace=TRUE)==6)) 

set.seed(1)
n=100
p=1/6
list_z <- replicate(10000, (mean(sample(1:6, n, replace=TRUE)==6)- p) / sqrt(p*(1-p)/n))
hist(list_z)
z_over_2 <- mean(abs(list_z) > 2)

mypar(2,2)
set.seed(1)
n=5
p=1/2
list_z <- replicate(10000, (mean(sample(1:2, n, replace=TRUE)==2)- p) / sqrt(p*(1-p)/n))
hist(list_z, main = paste("n=", n, "p=", p))

set.seed(1)
n=30
p=1/2
list_z <- replicate(10000, (mean(sample(1:2, n, replace=TRUE)==2)- p) / sqrt(p*(1-p)/n))
hist(list_z, main = paste("n=", n, "p=", p))

set.seed(1)
n=30
p=1/100
list_z <- replicate(10000, (mean(sample(1:100, n, replace=TRUE)==100)- p) / sqrt(p*(1-p)/n))
hist(list_z, main = paste("n=", n, "p=", p))

set.seed(1)
n=100
p=1/100
list_z <- replicate(10000, (mean(sample(1:100, n, replace=TRUE)==100)- p) / sqrt(p*(1-p)/n))
hist(list_z, main = paste("n=", n, "p=", p))

#exercise3 

X <- filter(dat, Diet=="chow") %>% select(Bodyweight) %>% unlist
Y <- filter(dat, Diet=="hf") %>% select(Bodyweight) %>% unlist

sampleAverage_X <- mean(X)

