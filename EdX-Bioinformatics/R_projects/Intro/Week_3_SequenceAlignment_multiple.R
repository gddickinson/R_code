#Multiple Sequence Alignment (MSA)
#BiocManager::install("msa")
#install.packages("phangorn")
library(msa) 
library(seqinr)
library(ape)
library(phangorn)

#load sequence data
coxAA <- readAAStringSet("cox1multi.fasta")
prokDNA <- readDNAStringSet("prok.fasta")

#align using CLUSTALW
coxAligned <- msa(coxAA)
prokAligned <- msa(prokDNA)

#view alignments
coxAligned
prokAligned

#view with better format
print(prokAligned, show="complete")

# for differnt alignment algorithms
#msa(prokDNA, "ClustalW")
#msa(prokDNA, "ClustalOmega")
#msa(prokDNA, "Muscle")

#texshade printing
# print(msaPrettyPrint(prokAligned, output="asis", y=c(164, 213),
#                subset=c(1:6), showNames="none", showLogo="none",
#                consensusColor="ColdHot", showLegend=FALSE,
#                askForOverwrite=FALSE))

#tex output
msaPrettyPrint(prokAligned, output="tex", y=c(164, 213),
               subset=c(1:6), showNames="none", showLogo="none",
               consensusColor="ColdHot", showLegend=FALSE,
               askForOverwrite=FALSE)

# #pdf output
# msaPrettyPrint(prokAligned, output="pdf", y=c(164, 213),
#                subset=c(1:6), showNames="none", showLogo="none",
#                consensusColor="ColdHot", showLegend=FALSE,
#                askForOverwrite=FALSE)


#export alignment
#FASTA
prokAlignStr = as(prokAligned, "DNAStringSet")
writeXStringSet(prokAlignStr, file="prokAligned.fasta")

coxAlignStr = as(coxAligned, "AAStringSet")
writeXStringSet(coxAlignStr, file="coxAligned.fasta")

#PHYLIP
write.phylip(coxAligned, "coxAligned.phylip")


#Phylogeny analysis
prokAligned2 <- msaConvert(prokAligned, type="seqinr::alignment")
#create distance matrix
prokdist <- dist.alignment(prokAligned2, "identity")
#visualise matrix
prokdist
#make neighbour-joining tree
prokTree <- nj(prokdist)
#visulise tree
plot(prokTree)


#maximum parsimony 
#A more evolutionary-centric approach is maximum parsimony, which actually looks at shared
#characters between sequences and maximizes similarity while minimizing the number of steps
#required to construct a the phylogenetic history between the "cades", or species.

prokAligned3 <- msaConvert(prokAligned, type="phangorn::phyDat")
ParsTree <- pratchet(prokAligned3)

plot(ParsTree)

#maximum likelihood
#Maximum likelihood lets you use a distance matrix (as previously) but also includes the full sequence
#alignment and calculates the statistical likelihood of a tree given the full data.
#qAs such maximum likelihood is far more computationally intense, but it may also provide more
#accurate reconstructions than "conventional" distance approaches.

fit <- pml(prokTree, prokAligned3)

#optimize the tree using optim.pml
#optim.pml requires us to provide the "model" of evolution that we think will best fit our data.
#üThe model we will use for this exercise is the Jukes-Cantor model, which assumes that all bases
#are found in equal numbers, and that all mutations are equally likely (e.g. A to T or C or G, etc.).
#Another "popular" model is K80, or the Kimura two-parameter model, which states that
#transition mutations (A <-> G)  will have a different rate from transversions (C<->T).

#with JC model
fitJC <- optim.pml(fit, model = "JC", rearrangement = "stochastic")
plot(fitJC)
#with K80 model
fitJC <- optim.pml(fit, model = "K80", rearrangement = "stochastic")
plot(fitJC)

#bootstraping
bootstrapped <- bootstrap.pml(fitJC, bs=100, optNni=TRUE, multicore=FALSE, control = pml.control(trace=0))
plotBS(midpoint(fitJC$tree), bootstrapped, p = 50, type="p")












