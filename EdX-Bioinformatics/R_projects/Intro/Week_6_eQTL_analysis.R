#install.packages("MatrixEQTL")
library(MatrixEQTL) 

#set model
useModel = modelLINEAR # modelANOVA, modelLINEAR, or modelLINEAR_CROSS
#set significance threshold
pvOutputThreshold = 1e-2

#choose covariance matrix (here setting it to identity)
errorCovariance = numeric()

snps = SlicedData$new()
snps$fileDelimiter = '\t'
snps$fileSkipColumns = 1
snps$fileSliceSize = 2000
snps$LoadFile('SNP.txt')

gene = SlicedData$new()
gene$fileDelimiter = "\t"      
gene$fileOmitCharacters = "NA" 
gene$fileSkipRows = 1          
gene$fileSkipColumns = 1       
gene$fileSliceSize = 2000      
gene$LoadFile("GE.txt")

cvrt = SlicedData$new()
cvrt$fileDelimiter = "\t"      
cvrt$fileOmitCharacters = "NA" 
cvrt$fileSkipRows = 1          
cvrt$fileSkipColumns = 1       
cvrt$LoadFile("Covariates.txt")


me = Matrix_eQTL_engine(snps=snps,
                        gene=gene,
                        cvrt=cvrt,
                        output_file_name='outfile.txt',
                        pvOutputThreshold = pvOutputThreshold,
                        useModel = useModel,
                        errorCovariance = errorCovariance,
                        verbose = TRUE,
                        pvalue.hist = FALSE,
                        min.pv.by.genesnp = FALSE,
                        noFDRsaveMemory = FALSE)

cat('Analysis done in: ', me$time.in.sec, ' seconds', '\n')
cat('Detected eQTLs:', '\n')
show(me$all$eqtls)

#make temporary files to store the cis vs trans information
output_file_name_cis = tempfile()
output_file_name_tra = tempfile()

#set params
pvOutputThreshold_cis = 1e-2
pvOutputThreshold_tra = 1e-2
cisDist = 1e6

#load position file data
snpspos = read.table("snpsloc.txt", header = TRUE, stringsAsFactors = FALSE)
genepos = read.table("geneloc.txt", header = TRUE, stringsAsFactors = FALSE)

#Using A quantile-quantile (q-q) plot - a graphical technique for determining if two data sets come from
#populations with a common distribution
me = Matrix_eQTL_main(snps=snps,
                        gene=gene,
                        cvrt=cvrt,
                        output_file_name = output_file_name_tra,
                        pvOutputThreshold = pvOutputThreshold_tra,
                        useModel = useModel,
                        errorCovariance = errorCovariance,
                        verbose = TRUE,
                        output_file_name.cis = output_file_name_cis,
                        pvOutputThreshold.cis= pvOutputThreshold_cis,
                        snpspos = snpspos,
                        genepos = genepos,
                        cisDist = cisDist,
                        pvalue.hist = "qqplot",
                        min.pv.by.genesnp = FALSE,
                        noFDRsaveMemory = FALSE)



show(me$cis$eqtls)
cat('Detected distant eQTLS:', '\n')
show(me$trans$eqtls)
plot(me)

