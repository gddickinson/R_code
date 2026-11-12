#Pairwise Sequence analysis

# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install()

library(Biostrings)
library(seqinr)

#load sequence data
prokaryotes <- read.fasta(file = "prok.fasta", seqtype = "DNA")

#split the file into individual sequences first for our pairwise alignment
seq1 <- as.character(prokaryotes[[1]])
seq1 = paste(seq1,collapse='')
seq2 <- as.character(prokaryotes[[2]])
seq2 = paste(seq2,collapse='')

#align seq1 and seq2 using the default settings of Biostrings
pairalign <- pairwiseAlignment(pattern = seq2, subject = seq1)
summary(pairalign)

#convert alignment to FASTA and save
pairalignString = BStringSet( c( toString( subject(pairalign) ), toString(pattern(pairalign))))
writeXStringSet(pairalignString, "aligned.txt", format="FASTA")

#Dot plot using protein sequences
#Load COX1 sequences
coxgenes <- read.fasta(file = "cox1multi.fasta", seqtype="AA")
cox1 <- as.character(coxgenes[[1]])
cox2 <- as.character(coxgenes[[2]])

#create dot plot
dotPlot(cox1, cox2, main = "Human vs Mouse Cox1 Dotplot")
#dotplot with options selected to improve signal to noise
dotPlot(cox1, cox2, wsize = 3, wstep = 3, nmatch = 3, main = "Human vs Mouse Cox1 Dotplot\nwsize = 3, wstep = 3, nmatch = 3")
#limited to first 100 residues 
dotPlot(cox1[1:100], cox2[1:100], wsize = 3, wstep = 3, nmatch = 3, main = "Human vs Mouse Cox1 first 100 AA Dotplot\nwsize = 3, wstep = 3, nmatch = 3")




                         