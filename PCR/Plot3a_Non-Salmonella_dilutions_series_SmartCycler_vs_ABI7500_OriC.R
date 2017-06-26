setwd("C:\\Users\\DickinsG\\Desktop\\PCR")

oric = read.csv('non-salm_smartcycler_oric.csv', header = T)
gfp = read.csv('non-salm_smartcycler_gfp.csv', header = T)


x <- oric$serotype


original.parameters<- par(no.readonly = TRUE)
par(xact="n")


plot(0:45, xact="n",
     main="OriC & gfp assays",
     ylab = "ct",
     xlab = "",
     xlim=c(1,10),
     ylim=c(0,45),
     type = "n",
     tick = FALSE,
     labels = FALSE)

axis(1, labels=FALSE, tick = FALSE)
text(x, par("usr")[3] - 0.2, labels = x, srt = 60, pos = 2, cex = 0.8, xpd = TRUE)
axis(2)

points(oric$serotype, oric$SmartCycler, col="blue", pch = 16, cex = 1.5)
points(oric$serotype, oric$ABI.7500, col="red", pch = 17, cex = 1.3)

points(gfp$serotype, gfp$SmartCycler, col="blue", pch = 1, cex = 1.5)
points(gfp$serotype, gfp$ABI.7500, col="red", pch = 2, cex = 1.3)


pos <- legend("topright", 
       inset = c(0,0), 
       cex = 1.5, 
       bty = "n", 
       legend = c("ABI 7500", "SmartCycler"), 
       text.col = c("red", "blue"),
       col = c("red", "blue"), 
       pch = c(17,16))

#legend("topleft", 
#       inset = c(0,0), 
#       cex = 1.5, 
#       bty = "n", 
#       legend = c("OriC", "gfp"), 
#       pch = c(16,1))

points(x=rep(pos$text$x, times=2)-0.8, 
      y=rep(pos$text$y, times=2), 
      cex = 1.5,
      pch= c(2,1),
      col = c("red", "blue"))


par(original.parameters)