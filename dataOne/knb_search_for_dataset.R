#install.packages("dataone")
library(dataone)

##########################################################
##To search the DataONE Federation Member Node Knowledge Network for Biocomplexity (KNB) for a dataset:
##########################################################
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
mySearchTerms <- list(q="abstract:salmon+AND+keywords:spawn+AND+keywords:chinook",
                      fl="id,title,dateUploaded,abstract,size",
                      fq="dateUploaded:[2017-06-01T00:00:00.000Z TO 2017-07-01T00:00:00.000Z]",
                      sort="dateUploaded+desc")
result <- query(mn, solrQuery=mySearchTerms, as="data.frame")
result[1,c("id", "title")]
id <- result[1,'id']

##########################################################
##The metadata file that describes the located research can be downloaed and viewed in an XML viewer, text editor after being written to disk, or in R via the commands below:
##########################################################
library(XML)
metadata <- rawToChar(getObject(mn, id))
doc = xmlRoot(xmlTreeParse(metadata, asText=TRUE, trim = TRUE, ignoreBlanks = TRUE))
tf <- tempfile()
saveXML(doc, tf)
file.show(tf)

##########################################################
##This metadata file describes a data file (CSV) in this data collection (package) that can be obtained using the listed identifier, using the commands:
##########################################################
dataRaw <- getObject(mn, "urn:uuid:49d7a4bc-e4c9-4609-b9a7-9033faf575e0")
dataChar <- rawToChar(dataRaw)
theData <- textConnection(dataChar)
df <- read.csv(theData, stringsAsFactors=FALSE)
df[1,]

