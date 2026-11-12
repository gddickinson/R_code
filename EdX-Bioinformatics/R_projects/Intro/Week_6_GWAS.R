#install.packages(c( "GenABEL_1.8-0.tar.gz"), repos = NULL)
#install.packages(c("GenABEL.data_1.0.0.tar.gz"), repos = NULL)
#install.packages("hglm")
#install.packages("RepeatABEL_1.1.tar.gz", repos = NULL)
library(GenABEL)

#load data using GenAbEL
data <- load.gwaa.data(phenofile="phenotype.dat", genofile="genotype.raw")

#browse data
#gtdata(data)


#access the genotype at markers 3 through 5 for the first individual in the data
gtdata(data)[1,3:5]

#to see the chromosome that markers 3 through 5 are on 
chromosome(gtdata(data)[,3:5])


#to get the name of marker (SNP) 17000
snpnames(gtdata(data)[ ,17000])

#to see the genotypes at marker 1177 for the first four individuals
as.character(gtdata(data)[1:4, 1177])

#To see the reference ("wild type") allele 
refallele(gtdata(data)[ ,1177])



#Hardy-Weinberg Equilibrium data (HWE)
# Hardy-Weinberg equilibrium states that the population is in equilibrium for the distribution of the alleles
#– and this is typically not the case.
#The columns for p.11, p.12, and p.22 give you the actual number of each genotype – you can see the
#distribution is not equal.
#The Fmax column shows the deviation from HWE
summary.snp.data(gtdata(data))

#distribution of the continuous trait
ct <- phdata(data)$ct

#distribution of the continuous variable
hist(ct, col="slateblue", main="Distribution of ct")

# ct ~ phdata(data)$sex simply checks to see whether our continuous trait depends
#on the sex column in the phenotypic data of dataset data.
boxplot(ct ~ phdata(data)$sex, col=c("blue", "red"), xlab="sex", names=c("F", "M"), main="ct by sex")


#QC check, let's use the standard 95% interval and apply that to markers that couldn't be
#determined (called) better than 95% of the time as well as individuals who don't have 95% of the
#genotype represented
#We also want to remove markers with a very low minor allele frequency (meaning they are
#monomorphic, or not very informative) as well as markers that are strongly out of HWE – we'll set
#both of those to 10-08 criteria
qc <- check.marker(data, call = 0.95, perid.call = 0.95, maf = 1e-08, p.lev = 1e-08) 

#create a new dataset containing only individuals and snps that are "ok"
data.qc <- data[qc$idok, qc$snpok]

#Cochran-Armitage Trend Test
#In this command we are checking whether ct depends on any of the genotypic data in data.qc,
#and we expect that the trait uses a gaussian distribution
an <- qtscore(ct~1, data=data.qc, trait="gaussian")

#manhattan plot
plot(an, col=c("olivedrab","slateblue"), cex=.5, main="Manhattan plot")

#we need to make sure that our p-values for each of the many tests that occurred are really
#"significant" – we can do this by looking at lambda, which is the genomic inflation factor, and can result
#in lower than expected p values due to cryptic relatedness or population structure
#Here we have simply estimated the genomic inflation based on P1df in the QC data and plotted the results.
#The console also tells us our estimate is 1.18 – since this is above 1, we do have a small amount of
#genomic inflation
estlambda(an[,"P1df"], plot=T)

#correct for inflation using 
plot(an, col=c("olivedrab","slateblue"), cex=.5, main="Manhattan plot", df="Pc1df")

#There's still one more correction we should look at.
#Since this analysis involves a large number of statistical tests – one per marker – there's a possibility
#that some of the p-values will be significant just by chance – a false positive.
#The more tests you run the more likely you will have one or more false positives.
#We could compensate for this by increasing the p-value threshold, but there's a way of adding a
#statistical check to our plot  instead.
#We will use a Bonferroni correction, which divides each p-value for each test by the number of tests.
pval.threshold <- 0.05
bonferroni <- -log10(pval.threshold / nids(data.qc))

#Add The Bonferroni score to our Manhattan plot as a line showing it as a threshold
plot(an, col=c("olivedrab","slateblue"), cex=.5, main="Manhattan plot", df="Pc1df")
abline(h=bonferroni, lty=3, color="red")

