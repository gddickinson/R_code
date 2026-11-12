#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#
#BiocManager::install("Biostrings")

library(Biostrings)
library(seqinr)

#read fasta into AB0036468 object
AB003468 <- readDNAStringSet("AB003468.fasta")
#convert to characters only
AB003468 <- as.character(AB003468)
#search for START codon 'ATG' pattern
matchPattern("ATG", AB003468)

#define START and STOP codons
start_codon <- "ATG"
stop_codons <- c("TGA","TAA","TAG")

#create variables to store search results
start_pos <- c()
revstart_pos <- c()
stop_pos <- c()
revstop_pos <- c()

#add search sequence to generic variable
sequence <- AB003468

#search for matches to START codon
matches <- matchPattern(start_codon,sequence)

#take the starting location of each match in matches and put it into the final variable
start_pos <- c(start_pos, start(matches))
start_pos

#search reverse complement
revmatches <- matchPattern(reverseComplement(DNAString(start_codon)), sequence)

#get starting positions
revstart_pos <- c(revstart_pos, start(revmatches))
revstart_pos

#sort numerically
start_pos <- sort(start_pos)
revstart_pos <- sort(revstart_pos, decreasing = TRUE)
revstart_pos

#finding STOPS
for (codon in stop_codons) {
  matches <- matchPattern(codon, sequence)
  stop_pos <- c(stop_pos, start(matches))
  revmatches <- matchPattern(reverseComplement(DNAString(codon)),sequence)
  revstop_pos <- c(revstop_pos, start(revmatches))
}

#sort numerically
stop_pos <- sort(stop_pos)
revstop_pos <- sort(revstop_pos, decreasing = TRUE)

#map out the actual ORFs
#START and STOP pointers
#k is our threshold – we're setting that so that our minimum ORF is 150 (or 50 amino acids)
k <- 150
lengths <- vector(mode="numeric")
#forward 3 frames

#stop_pointers will hold the location of the STOPS in each reading frame for each iteration
stop_pointers <- c(0,0,0)
#Count is simply the number of ORFs we find
count <- 0

for (current_start in start_pos) {
  frame <- (current_start%%3) + 1
  stop_pointer <- stop_pointers[frame]
  
  if (stop_pointer <= length(stop_pos) && (stop_pointer == 0 || stop_pos[stop_pointer] < current_start)) 
    {
      stop_pointer <- stop_pointer + 1  
  
    while ((stop_pointer <= length(stop_pos))
           && ((stop_pos[stop_pointer] <= current_start))
            || (((stop_pos[stop_pointer]%%3 +1) != frame))){
      stop_pointer <- stop_pointer + 1
    }
      
  stop_pointers[frame] <- stop_pointer
  
  if (stop_pointer <= length(stop_pos)){
    if ((stop_pos[stop_pointer] + 2 - current_start + 1) > k ) {
      count <- count + 1
      print(count)
      print("Frame:")
      print(frame)
      print("Start:")
      print(current_start)
      print("Stop:")
      print(stop_pos[stop_pointer])
      print("Length:")
      lengths <- c(lengths, (stop_pos[stop_pointer]+2-current_start+1))
      print(stop_pos[stop_pointer]+2-current_start+1)
      print("Sequence:")
      print(subseq(sequence,current_start,stop_pos[stop_pointer]+2))
    }}
    }
  }
  
  
  
#Reverse 3 frames

revstop_pointers <- c(0,0,0)
count <- 0

for (current_revstart in revstart_pos) {
  current_revstart <- current_revstart + 2
  frame <- (current_revstart%%3) + 1
  revstop_pointer <- revstop_pointers[frame]
  
  if (revstop_pointer <= length(revstop_pos) && (revstop_pointer == 0 
                                                 || revstop_pos[revstop_pointer] > current_revstart)) 
  {
    revstop_pointer <- revstop_pointer + 1  
    
    while ((revstop_pointer <= length(revstop_pos))
           && ((revstop_pos[revstop_pointer] +2 >= current_revstart)
           || ((((revstop_pos[revstop_pointer] + 2 ) %%3) +1) != frame))) {
      revstop_pointer <- revstop_pointer + 1
    }
    
    revstop_pointers[frame] <- revstop_pointer
    
    if (revstop_pointer <= length(revstop_pos)){
      if ((current_revstart - revstop_pos[revstop_pointer]) + 1  > k ) {
        count <- count + 1
        print(count)
        print("Frame:")
        print(frame)
        print("Start:")
        print(current_start)
        print("Stop:")
        print(revstop_pos[revstop_pointer] + 2)
        print("Length:")
        lengths <- c(lengths, (current_revstart - revstop_pos[revstop_pointer]))
        print(current_revstart - revstop_pos[revstop_pointer])
        print("Sequence:")
        print(subseq(sequence,revstop_pos[revstop_pointer],current_revstart))
      }}
  }
}


lengths <- sort(lengths)
#barplot lengths
barplot(lengths)
#kernel density (i.e. distribution) plot lengths 
plot(density(lengths))
#histogram of lengths
bins <- seq(0,1000,50)
hist(lengths, breaks=bins, col="red", xlim=c(0,1000))






