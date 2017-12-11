source('./clearning.R', local = TRUE)

pairs(listings[,-c(1,3)])

library(gclus)
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

library(leaps)
b <- regsubsets(price ~ avail + num_reviews + min_nights + lat + lon, data = listings)
rs <- summary(b)
rs$which


#high vs low availability at 90 days (<= 90 is low)
#calculated_host_listings_count is the number of listings a specific host has to his/her name
#price is calculated per nigh



#let's consider how to bring down the number of factors in nb (without losing usefulness)
length(listings$nb)
isole <- listings$nb[listings$nb_group =="Isole"] #neighborhoods on the island
length(isole) #5000 / 6000 listings are on the island
isole2 <- isole[isole!="San Marco"]
length(isole2) 
isole3 <- isole2[isole2 != "Castello"]
length(isole3) 
isole4 <- isole3[isole3 != "Cannaregio"]
length(isole4) 
isole5 <- isole4[isole4 != "Dorsoduro"]
length(isole5) 
isole6 <- isole5[isole5 != "Giudecca"]
length(isole6)
isole7 <- isole6[isole6 != "Lido"]
length(isole7)
#first 7 neighborhoods encompass 2/3 of the listings, will this be enough?
big6Neighborhoods <- c("San Marco", "Castello", "Cannaregio", "Dorsoduro", "Giudecca", "Lido")
list <- as.character(listings$nb)
for (i in 1:length(listings$nb)){
  if (!(list[i] %in% big6Neighborhoods)){
    list[i] <- as.factor(0)
  }
}
list <- as.factor(list)

#taking out nb here drops R^2 by about 0.04. Not a rigorous analysis, but maybe nb won't be worth keeping anyway
mod2 <- lm(price ~ avail + num_reviews + min_nights + lat + lon + nb + nb_group, data = listings)
summary(mod2)
mod3 <- lm(price ~ avail + num_reviews + min_nights + lat + lon +  nb_group, data = listings)
summary(mod3)
#Using the big 6 neighborhoods improves R^2 here by 0.01, not substantial. Can do better
mod4 <- lm(price ~ avail + num_reviews + min_nights + lat + lon +  list + nb_group, data = listings)
summary(mod4)


