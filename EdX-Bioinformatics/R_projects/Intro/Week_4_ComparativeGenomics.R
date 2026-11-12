#BiocManager::install("biomaRt")

library(biomaRt)

#Biomart lets you access ENSEMBLE genomes directly and download relevant information
#for example, we can see a list of available databases
listMarts()

#To pick the ensemble database 
ensembl=useMart("ensembl")

#see available ensemble datasets
valid_datasets <- listDatasets(ensembl)

#load data for Chimpanzee and Gorilla datasets
#We aren't retrieving the full genome sequences, just the metadata and descriptors about the genes
Chimpanzee <- useDataset("ptroglodytes_gene_ensembl", mart = ensembl)
Gorilla <- useDataset("ggorilla_gene_ensembl", mart = ensembl)
Human <- useDataset("hsapiens_gene_ensembl", mart = ensembl)

#pull the list of available attributes down for each dataset 
ChimpanzeeAttributes <- listAttributes(Chimpanzee)
GorillaAttributes <- listAttributes(Gorilla)
HumanAttributes <- listAttributes(Human)
#View the attributes
GorillaAttributes

#The getBM command retrieves the data from the ensembl servers,
#using the mart ID's we set up previously
#Note that we are fetching not just the gene id but the gene type 
#e.g. is it a protein coding gene, etc
#The ensemble Gene ID is a unique gene identifier and can be used to indicate a specific gene
#regardless of which species it is in
ChimpanzeeGenes <- getBM(attributes = c("ensembl_gene_id", "gene_biotype"), mart=Chimpanzee)
GorillaGenes <- getBM(attributes = c("ensembl_gene_id", "gene_biotype"), mart=Gorilla)
HumanGenes <- getBM(attributes = c("ensembl_gene_id", "gene_biotype"), mart=Human)


#parse the gene names and gene types into two separate vectors for each species
ChimpanzeeGeneNames <- ChimpanzeeGenes[[1]]
ChimpanzeeGeneTypes <- ChimpanzeeGenes[[2]]
GorillaGeneNames <- GorillaGenes[[1]]
GorillaGeneTypes <- GorillaGenes[[2]]

HumanGeneNames <- HumanGenes[[1]]
HumanGeneTypes <- HumanGenes[[2]]

#summarize the Gene Types using the TABLE command
ChimpanzeeTypesTable <- table(ChimpanzeeGeneTypes)
GorillaTypesTable <- table(GorillaGeneTypes)
HumanTypesTable <- table(HumanGeneTypes)

ChimpanzeeTypesTable
GorillaTypesTable
HumanTypesTable

#compare the number of protein coding genes in gorilla vs chimpanzees
ChimpanzeeProteins <- ChimpanzeeTypesTable["protein_coding"]
GorillaProteins <- GorillaTypesTable["protein_coding"]
HumanProteins <- HumanTypesTable["protein_coding"]

ChimpanzeeProteins
GorillaProteins
HumanProteins

#how many genes Chimpanzees have that have gorilla orthologs
ChimpGGNum <- getBM(attributes = "ggorilla_homolog_ensembl_gene", mart = Chimpanzee)
#This line retrieves the list of both Chimpanzee gene ID's along with their gorilla orthologs
#(if available) in a dataframe
ChimpanzeeGG <- getBM(attributes = c("ensembl_gene_id","ggorilla_homolog_ensembl_gene"), mart = Chimpanzee)
#same for Gorilla
GorillaCNum <- getBM(attributes = "ptroglodytes_homolog_ensembl_gene", mart = Gorilla)
GorillaC <- getBM(attributes = c("ensembl_gene_id","ptroglodytes_homolog_ensembl_gene"), mart = Gorilla)















