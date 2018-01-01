n = 10
size = 1
prob = 0.5
rbinom(n,1,prob)

#simuation
flips <- rbinom(100000,10,0.5)
flips == 5
##number of flips heads = 5
mean(flips ==5)
##number of flips heads  = 4 or less
mean(flips <= 4)

#direct calculation of density
number_heads = 5
dbinom(number_heads,10,.5)

#direct calculation of cumulative density
number_heads_cum = 4
pbinom(number_heads_cum,10,.5)
