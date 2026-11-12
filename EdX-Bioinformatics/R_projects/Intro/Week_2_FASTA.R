#Week 2 - working with FASTA
#install.packages("seqinr")
#install.packages("ape")
#install.packages("rentrez")
#install.packages("Peptides")


library(seqinr)
library(ape)
library(rentrez)
library(Peptides)

#import file from disk
cox1 <- read.fasta(file="cox1.fasta",seqtype="AA")
#select sequence object
seq1 <- cox1[1]

#retrieve sequence from Genebank using APE
AB003468 <- read.GenBank("AB003468", as.character = "TRUE")
#convert from binary format to FASTA (saves to disk)
write.dna(AB003468, file ="AB003468.fasta", format = "fasta", append = FALSE, nbcol = 6, colsep = " ", colw = 10)

#convert our sequence into a simple string for analysis
CloningVector <- AB003468[[1]]
#Retrieve the total count of each nucleotide (A, C, G, and T) and store it in the variable count
allBases_count <- count(CloningVector,1) 
allBases_count

#'word count' analysis
dinucleotide_combinations <- count(CloningVector,2)
dinucleotide_combinations
trinucleotide_combinations <-count(CloningVector,3)
trinucleotide_combinations

#GC Content - the ratio of G (guanines) and C (cystosines) residues compared to A
GC <- GC(CloningVector)
GC

#Analyse GC content over regions of sequence
#by chunks of 200
GCwindow <- seq(1, length(CloningVector)-200, by = 200)
GCwindow
#make loop to chunk sequence
#numer of chunks
n <- length(GCwindow)
#Create a new, blank vector with the same number of blank spaces that we can fill with our GC values
Chunks <- numeric(n)
#FOR loop to compute GC per chunk
for (i in 1:n) {
  chunk <- CloningVector[GCwindow[i]:(GCwindow[i]+199)]
  chunkGC <- GC(chunk)
  print(chunkGC)
  Chunks[i] <- chunkGC
}

#plot the result
plot(GCwindow,Chunks,type="b",xlab="Nucleotide start position",ylab="GC content")

#Custom function for GC Window Plotting
slidingwindowGCplot <- function(windowsize,inputseq)
{
  GCwindow <- seq(1, length(inputseq)-windowsize, by = windowsize) 
  #find the length of the GCwindow
  n <- length(GCwindow)
  #make a vector the same length but "blank" for us to fill
  Chunks <- numeric(n)
  for (i in 1:n) {
    chunk <- inputseq[GCwindow[i]:(GCwindow[i]+windowsize-1)]
    chunkGC <- GC(chunk)   
    print(chunkGC)   
    Chunks[i] <- chunkGC  
  }
  plot(GCwindow,Chunks,type="b",xlab="Nucleotide start position",ylab="GC content",main=paste("GC Plot with windowsize ", windowsize))
}
  
#run function
slidingwindowGCplot(200,CloningVector)
slidingwindowGCplot(175,CloningVector)


#protein sequence stats
#The aaComp() command uses the Peptides library to determine the amino acid composition of the sequence
aaComp(cox1[1])
#aliphatic index of the protein sequence (an indicator of thermostability of globular proteins)
aIndex(cox1)
#net charge of the protein
charge(charge(cox1), pH = 7, pKscale = "Lehninger")
#with a sequence and a different pKscale 
charge(seq="FLPVLAG", pH=7, pKscale="EMBOSS")
#hydrophobicity
hydrophobicity(cox1[1])

#Custom function to plot windowed hydrophobicity 
slidingwindowHydrophobicityplot <- function(windowsize,inputseq)
{
  Hydro_window <- seq(1, length(inputseq)-windowsize, by = windowsize) 
  #find the length of the Hydro_window
  n <- length(Hydro_window)
  #make a vector the same length but "blank" for us to fill
  Chunks <- numeric(n)
  for (i in 1:n) {
    chunk <- inputseq[Hydro_window[i]:(Hydro_window[i]+windowsize-1)]
    chunkHydro <- hydrophobicity(chunk)   
    print(chunkHydro)   
    Chunks[i] <- chunkHydro  
  }
  plot(Hydro_window,Chunks,type="b",xlab="AA start position",ylab="Hydrophobicity",main=paste("Hydrophobicity Plot with windowsize ", windowsize))
}

#run function
slidingwindowHydrophobicityplot(25,cox1$COX1_human)



#retrieve sequence from Genebank using rentrez
#The rentrez package lets us retrieve sequences in other ways than just by accession number and it doesn’t limit us to the binary format that APE does
r_search <- entrez_search(db="nucleotide", term="human superoxide dismutase", retmax=40)
r_search$ids

#For other entrez functions go to https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html
#to list entrez's available databases
entrez_dbs()
entrez_db_summary("cdd")
entrez_db_searchable("sra")

#Advanced counting - track buzzwords in pubmed
search_year <- function(year, term){
  query <- paste(term, "AND (", year, "[PDAT])")
  entrez_search(db="pubmed", term=query, retmax=0)$count
}

year <- 2007:2019
papers <- sapply(year, search_year, term="Connectome", USE.NAMES=FALSE)
plot(year, papers, type='b', main="The Rise of the Connectome")

year <- 2007:2019
papers <- sapply(year, search_year, term="DNA origami", USE.NAMES=FALSE)
plot(year, papers, type='b', main="The Rise of the DNA origami")

year <- 1950:2019
papers <- sapply(year, search_year, term="calcium", USE.NAMES=FALSE)
plot(year, papers, type='b', main="The Rise of calcium")





