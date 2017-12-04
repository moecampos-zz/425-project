library(dplyr)
library(magrittr)
listings <- read.csv("./data/listings.csv", header = TRUE) %>%
  select(-id, -name, -host_name, -last_review, -calculated_host_listings_count) %>%
  transmute(host = host_id, nb_group = neighbourhood_group, nb = neighbourhood,
            lat = latitude, lon = longitude, room_type = room_type, price = price,
            min_nights = minimum_nights, num_reviews = number_of_reviews,
            rpm = reviews_per_month, avail = availability_365)

x11()
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
