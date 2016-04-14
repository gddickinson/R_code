library(downloader) 
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/femaleControlsPopulation.csv"
filename <- basename(url)
download(url, destfile=filename)
x <- unlist( read.csv(filename) )

set.seed(1)
n <- 1000
dist_for5 <- vector("numeric",n)
for (i in 1:n) {
  random_sample <- sample(x,5)
  dist_for5 [i] <- mean(random_sample)
}

set.seed(1)
n <- 1000
dist_for50 <- vector("numeric",n)
for (i in 1:n) {
  random_sample <- sample(x,50)
  dist_for50 [i] <- mean(random_sample)
}

p1 <- hist(dist_for5)
p2 <- hist(dist_for50)
plot( p1, col=rgb(0,0,1,1/4), xlim=c(20,30))
plot( p2, col=rgb(1,0,0,1/4), xlim=c(20,30), add=T) 

prop_23to25 <- abs(mean(dist_for50 <= 23) - mean(dist_for50 <= 25)) 

normalDist <- rnorm(5000,23.9,0.43)
propNormal_23to25 <- abs(mean(normalDist<= 23) - mean(normalDist<= 25)) 
p3 <- hist(normalDist)
plot( p3, col=rgb(1,1,0,1/4), xlim=c(20,30), add=T) 

