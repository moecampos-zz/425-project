library(here)
library(gclus)
library(leaps)
library(labelled)#for labels()
library(stats) #for TukeyHSD

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


bigNineNeighborhoods <- c("San Marco", "Castello", "Cannaregio", "Dorsoduro", "Giudecca", "Lido", "Santa Croce", "Murano", "San Polo")

#Using the big 9 neighborhoods
mor <- aov(price ~ nb, data = listings_with_id)

##THIS MODEL GIVES THE MEAN PREDICTED NEIGHBORHOOD PRICES

tukey <- TukeyHSD(x=mor, 'nb', conf.level = 0.95)
signif <- tukey$nb[,4]



newLabel <- str_split(labels(signif), "-")
namesOne <- c(rep(NA, length(signif)))#stores names of neighborhoods for comparison
namesTwo <- c(rep(NA, length(signif)))#stores names of neighborhoods for comparison
for (i in 1:length(signif)){
  namesOne[i] <- newLabel[[i]][1]
}
for (j in 1:length(signif)){
  namesTwo[j] <- newLabel[[j]][2]
}
pVals <- unname(tukey$nb[,4])
isSign <- ifelse(pVals < 0.05, 1, 0)
sigData <- data.frame(namesOne, namesTwo, pVals, isSign)


ggplot(sigData, aes(x=namesOne, y=namesTwo, fill=isSign,  col = "black")) + geom_tile(col="black")
