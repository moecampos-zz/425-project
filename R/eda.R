library(here)
library(gclus)
library(leaps)
libary(ggplot2) #for grid.arrange()

source(here("R", "cleaning.R"), local = TRUE)

pairs(listings[,-c(1,3)])

lis <-na.omit(listings[,-c(1,2,3,6)])
lis.r <- abs(cor(lis))
lis.col <- dmat.color(lis.r)
lis.o <- order.single(lis.r)
cpairs(lis, lis.o, panel.colors=lis.col, gap=.5,
       main="Variables Ordered and Colored by Correlation" )

mod1 <- lm(price ~ avail + num_reviews + min_nights + lat + lon, data = listings)
summary(mod1)

sum(sort(abs(rstudent(mod1)), decreasing = T) > qt(1-0.05/(6027*2), 6021))

cook <- cooks.distance(mod1)
sort(abs(cook), decreasing = T)[1:5]

b <- regsubsets(price ~ avail + num_reviews + min_nights + lat + lon, data = listings)
rs <- summary(b)
rs$which


#high vs low availability at 90 days (<= 90 is low)
#calculated_host_listings_count is the number of listings a specific host has to his/her name
#price is calculated per nigh



#let's consider how to bring down the number of factors in nb (without losing usefulness)

#first 9 neighborhoods encompass 2/3 of the listings, will this be enough?



#Using the big 9 neighborhoods
mod5 <- lm(price ~ nb, data = listings)
summary(mod5)
anova(mod5)
##THIS MODEL GIVES THE MEAN PREDICTED NEIGHBORHOOD PRICES


tukey <- TukeyHSD(aov(price ~nb, data = listings), level = 0.95)

#cell comparison for significance
which(tukey$nb[,4] < 0.05)

plot(tukey)

ggplot(tukey$nb[,4])
grid.arrange()


