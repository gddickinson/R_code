library(downloader) 
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/mice_pheno.csv"
filename <- basename(url)
download(url, destfile=filename)
dat <- na.omit( read.csv(filename) )

y <- unlist(filter(dat, Sex == "M" & Diet == "chow") %>% select(Bodyweight))

y_mean <- mean(y)
y_sd <- popsd(y)

prop = function(q) {
  mean(y <= q)
}

prop1 <- prop(y_mean+y_sd)
prop2 <- prop(y_mean-y_sd)

prop_within_1sd <- prop1 - prop2

prop3 <- prop(y_mean+(2*y_sd))
prop4 <- prop(y_mean-(2*y_sd))

prop_within_2sd <- prop3 - prop4

prop5 <- prop(y_mean+(3*y_sd))
prop6 <- prop(y_mean-(3*y_sd))

prop_within_3sd <- prop5 - prop6

mypar(2,2)
y <- filter(dat, Sex=="M" & Diet=="chow") %>% select(Bodyweight) %>% unlist
z <- ( y - mean(y) ) / popsd(y)
qqnorm(z);abline(0,1)
y <- filter(dat, Sex=="F" & Diet=="chow") %>% select(Bodyweight) %>% unlist
z <- ( y - mean(y) ) / popsd(y)
qqnorm(z);abline(0,1)
y <- filter(dat, Sex=="M" & Diet=="hf") %>% select(Bodyweight) %>% unlist
z <- ( y - mean(y) ) / popsd(y)
qqnorm(z);abline(0,1)
y <- filter(dat, Sex=="F" & Diet=="hf") %>% select(Bodyweight) %>% unlist
z <- ( y - mean(y) ) / popsd(y)
qqnorm(z);abline(0,1)

set.seed(1)
y <- filter(dat, Sex=="M" & Diet=="chow") %>% select(Bodyweight) %>% unlist
avgs <- replicate(10000, mean( sample(y, 25)))
mypar(1,2)
hist(avgs)
qqnorm(avgs)
qqline(avgs)

sample_avgs_mean <- mean(avgs)
sample_avgs_sd <- popsd(avgs)





