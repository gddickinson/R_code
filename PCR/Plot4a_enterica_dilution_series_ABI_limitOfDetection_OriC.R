setwd("C:\\Users\\DickinsG\\Desktop\\PCR")

abi_oric = read.csv('abi7500_detection_limit_oric.csv', header = T)

#abi_gfp = read.csv('abi7500_detection_limit_gfp.csv.csv', header = T)

x <- abi_oric$dilution
x2 <- c(1.03, 10.3, 103, 1030, 10300, 103000)

pointsize = 1.5

plot (x, abi_oric$enterica_a,
      log = "x",
      main="OriC assay",
      xlab='dilution factor',
      ylab = "ct",
      ylim=c(20,45),
	col="red",
 	pch = 16,
 	cex = pointsize)

points (x, abi_oric$enterica_a, col="red", pch = 16, cex = pointsize)
points (x2, abi_oric$enterica_b, col="blue", pch = 16, cex = pointsize)



legend("topleft", 
       inset = c(0,0), 
       cex = 1.1, 
       bty = "n", 
       legend = c("enterica_a", "enterica_b"), 
       text.col = c("red", "blue"),
       col = c("red", "blue"), 
       pch = 16)


