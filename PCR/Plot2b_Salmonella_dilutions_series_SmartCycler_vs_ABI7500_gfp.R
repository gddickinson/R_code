setwd("C:\\Users\\DickinsG\\Desktop\\PCR")

#smartcycler_oric = read.csv('smartcycler_dilutions_oric.csv', header = T)
#abi_oric = read.csv('abi7500_dilutions_oric.csv', header = T)

smartcycler_gfp = read.csv('smartcycler_dilutions_gfp.csv', header = T)
abi_gfp = read.csv('abi7500_dilutions_gfp.csv', header = T)

x <- smartcycler_gfp$dilution
x2 <- c(1.05, 10.5, 105, 1050)

pointsize <- 1.5

plot (x, smartcycler_gfp$enterica,
      log = "x",
      main="gfp assay",
      xlab='dilution factor',
      ylab = "ct",
      ylim=c(20,45),
	col="red",
 	pch = 16,
 	cex = pointsize)

points (x, smartcycler_gfp$typhimurium, col="blue", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$irumu, col="green", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$newport, col="purple", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$infantis, col="orange", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$X4..5...12.i..., col="yellow", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$montevideo, col="brown", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$cerro, col="pink", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$hadar, col="grey", pch = 16, cex = pointsize)
points (x, smartcycler_gfp$muenchen, col="black", pch = 16, cex = pointsize)

points (x2, abi_gfp$typhimurium, col="blue", pch = 15, cex = pointsize)
points (x2, abi_gfp$irumu, col="green", pch = 15, cex = pointsize)
points (x2, abi_gfp$newport, col="purple", pch = 15, cex = pointsize)
points (x2, abi_gfp$infantis, col="orange", pch = 15, cex = pointsize)
points (x2, abi_gfp$X4..5...12.i..., col="yellow", pch = 15, cex = pointsize)
points (x2, abi_gfp$montevideo, col="brown", pch = 15, cex = pointsize)
points (x2, abi_gfp$cerro, col="pink", pch = 15, cex = pointsize)
points (x2, abi_gfp$hadar, col="grey", pch = 15, cex = pointsize)
points (x2, abi_gfp$muenchen, col="black", pch = 15, cex = pointsize)


pos <- legend("topright", 
       inset = c(0,0), 
       cex = 1.1, 
       bty = "n", 
       legend = c("enterica", "typhimurium", "irumu", "newport", "infantis", "4,[5], 12:i:-", "montevideo", "cerro", "hadar", "muenchen"), 
       text.col = c("red", "blue", "green", "purple", "orange", "yellow", "brown", "pink", "grey", "black"),
       col = c("red", "blue", "green", "purple", "orange", "yellow", "brown", "pink", "grey", "black"), 
       pch = 16)


points(x=rep(pos$text$x, times=2)+250, 
      y=rep(pos$text$y, times=2), 
      pch= 15,
      col = c("red", "blue", "green", "purple", "orange", "yellow", "brown", "pink", "grey", "black"))