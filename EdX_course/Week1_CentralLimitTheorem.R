library(downloader)
#install.packages("rafalib")
library(rafalib)
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/mice_pheno.csv"
filename <- basename(url)
download(url, destfile=filename)
dat <- read.csv(filename) 

dat <- na.omit( dat )

#males
x <- unlist(filter(dat, Sex == "M" & Diet == "chow") %>% select(Bodyweight))
bodyweight_male_chow_mean <- mean(x)
bodyweight_male_chow_sd <- popsd(x)

set.seed(1)
sample_x_25 <- sample(x,25)
sample_x_25_mean <- mean(sample_x_25)

y <- unlist(filter(dat, Sex == "M" & Diet == "hf") %>% select(Bodyweight))
bodyweight_male_hf_mean <- mean(y)
bodyweight_male_hf_sd <- popsd(y)

set.seed(1)
sample_y_25 <- sample(y,25)
sample_y_25_mean <- mean(sample_y_25)

difference_means <- abs(bodyweight_male_hf_mean - bodyweight_male_chow_mean) - abs(sample_x_25_mean - sample_y_25_mean) 

#females

x <- unlist(filter(dat, Sex == "F" & Diet == "chow") %>% select(Bodyweight))
bodyweight_female_chow_mean <- mean(x)
bodyweight_female_chow_sd <- popsd(x)

set.seed(1)
sample_x_25 <- sample(x,25)
sample_x_25_mean <- mean(sample_x_25)

y <- unlist(filter(dat, Sex == "F" & Diet == "hf") %>% select(Bodyweight))
bodyweight_female_hf_mean <- mean(y)
bodyweight_female_hf_sd <- popsd(y)

set.seed(1)
sample_y_25 <- sample(y,25)
sample_y_25_mean <- mean(sample_y_25)

difference_means <- abs(bodyweight_female_hf_mean - bodyweight_female_chow_mean) - abs(sample_x_25_mean - sample_y_25_mean) 

