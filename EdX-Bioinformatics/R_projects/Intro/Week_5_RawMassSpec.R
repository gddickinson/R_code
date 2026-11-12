#Accessing raw mass spectrometry data in R
#BiocManager::install("msdata")
#BiocManager::install("mzR")
#BiocManager::install("MSnbase")

library('msdata')

fls <- proteomics(full.names=TRUE)
basename(fls)
fl <- fls[2]
fl

library("mzR")
rw <- openMSfile(fl)
rw

sp1 <- spectra(rw,1)
head(sp1)

spl <- spectra(rw,1:2)
class(spl)
head(spl[[1]])

#access all spectra
spl <- spectra(rw)
length(spl)

#get all data for each spectra
hd<-header(rw)
head(hd)

#create mass spec experiment data object
suppressPackageStartupMessages(library("MSnbase"))

mse <- readMSData(fl, mode= "onDisk")
mse

mse[[1]]

fData(mse)







