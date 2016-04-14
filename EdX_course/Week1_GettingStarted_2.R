install.packages("gapminder")
library(gapminder)
data(gapminder)

lifeExpect_1952 <- filter(gapminder, year == 1952) %>% select(lifeExp)
lifeExpect_1952 <- unlist(lifeExpect_1952)

x <- lifeExpect_1952

prop = function(q) {
  mean(x <= q)
}

qs = seq(from=min(x), to=max(x), length=20)

props = sapply(qs, prop)

