source('./R/cleaning.R')
library(magrittr)

listings$pq <- 1
listings$pq[listings$price > 92 & listings$price <= 120] <- 2
listings$pq[listings$price > 120 & listings$price <= 160] <- 3
listings$pq[listings$price > 160] <- 4

mod1 <- lm(price ~ avail + num_reviews + rpm + min_nights + nb + room_type, 
           data = listings)
summary(mod1)

mod2 <- lm(price ~ avail + rpm + min_nights + nb + room_type, 
           data = listings)
summary(mod2)

####Diagnostics####
n <- nrow(listings)
p <- length(mod1$coefficients)

plot(mod1)
abline(v = 2*p/n, col = "blue", lty = 3)

num.out <- sum(sort(abs(rstudent(mod1)), decreasing = T) > qt(1-0.05/(n*2), n-p))
outliers <- sort(abs(rstudent(mod1)), decreasing = T)[1:num.out] %>% names() %>% as.numeric()
listings[outliers,c("avail","num_reviews","rpm","min_nights","nb","room_type","price")]

cook <- cooks.distance(mod1)
sort(abs(cook), decreasing = T)[1:5]

hat <- hatvalues(mod1)

length(hat[hat > 2*p/n])

####Random Forest####

library(randomForest)

rf <- randomForest(price~., data = listings[,-1])


