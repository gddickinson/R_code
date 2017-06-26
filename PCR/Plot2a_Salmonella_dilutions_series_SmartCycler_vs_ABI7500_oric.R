setwd("C:\\Users\\DickinsG\\Desktop\\PCR")

smartcycler_oric = read.csv('smartcycler_dilutions_oric.csv', header = T)
abi_oric = read.csv('abi7500_dilutions_oric.csv', header = T)

#smartcycler_gfp = read.csv('smartcycler_dilutions_gfp_2.csv', header = T)
#abi_gfp = read.csv('abi7500_gfp_2.csv', header = T)

x <- smartcycler_oric$dilution
x2 <- c(1.05, 10.5, 105, 1050)

pointsize = 1.5

plot (x, smartcycler_oric$enterica,
      log = "x",
      main="OriC assay",
      xlab='dilution factor',
      ylab = "ct",
      ylim=c(20,45),
	col="red",
 	pch = 16,
 	cex = pointsize)

points (x, smartcycler_oric$typhimurium, col="blue", pch = 16, cex = pointsize)
points (x, smartcycler_oric$irumu, col="green", pch = 16, cex = pointsize)
points (x, smartcycler_oric$newport, col="purple", pch = 16, cex = pointsize)
points (x, smartcycler_oric$infantis, col="orange", pch = 16, cex = pointsize)
points (x, smartcycler_oric$X4..5...12.i..., col="yellow", pch = 16, cex = pointsize)
points (x, smartcycler_oric$montevideo, col="brown", pch = 16, cex = pointsize)
points (x, smartcycler_oric$cerro, col="pink", pch = 16, cex = pointsize)
points (x, smartcycler_oric$hadar, col="grey", pch = 16, cex = pointsize)
points (x, smartcycler_oric$muenchen, col="black", pch = 16, cex = pointsize)

points (x2, abi_oric$typhimurium, col="blue", pch = 15, cex = pointsize)
points (x2, abi_oric$irumu, col="green", pch = 15, cex = pointsize)
points (x2, abi_oric$newport, col="purple", pch = 15, cex = pointsize)
points (x2, abi_oric$infantis, col="orange", pch = 15, cex = pointsize)
points (x2, abi_oric$X4..5...12.i..., col="yellow", pch = 15, cex = pointsize)
points (x2, abi_oric$montevideo, col="brown", pch = 15, cex = pointsize)
points (x2, abi_oric$cerro, col="pink", pch = 15, cex = pointsize)
points (x2, abi_oric$hadar, col="grey", pch = 15, cex = pointsize)
points (x2, abi_oric$muenchen, col="black", pch = 15, cex = pointsize)


#pos <- legend("bottomright", 
#       inset = c(0,0), 
#       cex = 1.1, 
#       bty = "n", 
#       legend = c("enterica", "typhimurium", "irumu", "newport", "infantis", "4,[5], 12:i:-", "montevideo", "cerro", "hadar", "muenchen"), 
#       text.col = c("red", "blue", "green", "purple", "orange", "yellow", "brown", "pink", "grey", "black"),
#       col = c("red", "blue", "green", "purple", "orange", "yellow", "brown", "pink", "grey", "black"), 
#       pch = 16)


#points(x=rep(pos$text$x, times=2)+250, 
#      y=rep(pos$text$y, times=2), 
#      pch= 15,
#      col = c("red", "blue", "green", "purple", "orange", "yellow", "brown", "pink", "grey", "black"))


legend("topleft", 
       inset = c(0,0), 
       cex = 1.5, 
       bty = "n", 
       legend = c("SmartCycler", "ABI 7500"), 
       pch = c(15,16))