setwd("C:\\Users\\DickinsG\\Desktop\\PCR")

smartcycler_oric = read.csv('smartcycler_oric_2.csv', header = T)
abi_oric = read.csv('abi7500_oric_2.csv', header = T)

smartcycler_gfp = read.csv('smartcycler_gfp_2.csv', header = T)
abi_gfp = read.csv('abi7500_gfp_2.csv', header = T)

x <- smartcycler_oric$serotype


original.parameters<- par(no.readonly = TRUE)
par(xact="n")

pointsize = 1.5

plot(0:45, xact="n",
     main="gfp assay",
     xlab='serotype',
     ylab = "ct",
     xlim=c(1,10),
     ylim=c(20,45),
     type = "n",
     tick = FALSE,
     labels = FALSE)

axis(1, labels=FALSE, tick = FALSE)
text(x, par("usr")[3] - 0.2, labels = x, srt = 60, pos = 2, cex = 0.8, xpd = TRUE)
axis(2)

points(smartcycler_oric$serotype, smartcycler_gfp$X1, col="blue", pch = 16, cex = pointsize)
points(smartcycler_oric$serotype, smartcycler_gfp$X10, col="blue", pch = 16, cex = pointsize)
points(smartcycler_oric$serotype, smartcycler_gfp$X100, col="blue", pch = 16, cex = pointsize)
points(smartcycler_oric$serotype, smartcycler_gfp$X1000, col="blue", pch = 16, cex = pointsize)

points(abi_oric$serotype, abi_gfp$X1, col="red", pch = 16, cex = pointsize)
points(abi_oric$serotype, abi_gfp$X10, col="red", pch = 16, cex = pointsize)
points(abi_oric$serotype, abi_gfp$X100, col="red", pch = 16, cex = pointsize)
points(abi_oric$serotype, abi_gfp$X1000, col="red", pch = 16, cex = pointsize)


#legend("topleft", 
#       inset = c(0,0), 
#       cex = 1.5, 
#       bty = "n", 
#       legend = c("ABI 7500", "SmartCycler"), 
#       text.col = c("red", "blue"),
#       col = c("red", "blue"), 
#       pch = c(16,16))

par(original.parameters)