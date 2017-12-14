source('./R/cleaning.R')
library(magrittr)
library(MASS)

og <- ls()

bc <- boxcox(lm(price ~ avail + num_reviews + rpm + nb + room_type, 
          data = listings), lambda = seq(-0.5,0,by = 0.01))
bc$x[bc$y == max(bc$y)]
#I'll use a lambda of -0.4 since it lies in the CI

listings %<>% mutate(price.bc = price^-0.4)

mod1 <- lm(price.bc ~ avail + num_reviews + rpm + nb + room_type, 
           data = listings) #Best AIC and BIC model
summary(mod1)
drop1(mod1, test = "F")


####Diagnostics####
plot(mod1, which = 1:6)

n <- nrow(listings)
p <- length(mod1$coefficients)

plot(mod1, which = 5)
abline(v = 2*p/n, col = "blue", lty = 3)

num.out <- sum(sort(abs(rstudent(mod1)), decreasing = T) > qt(1-0.05/(n*2), n-p))
outliers <- sort(abs(rstudent(mod1)), decreasing = T)[1:num.out] %>% names() %>% as.numeric()
listings[outliers,c("avail","num_reviews","rpm","min_nights","nb","room_type","price")]

cook <- cooks.distance(mod1)
sort(abs(cook), decreasing = T)[1:5]
plot(mod1, which = 4)

hat <- hatvalues(mod1)
length(hat[hat > 2*p/n])
hat[c(1902,4640)] > 2*p/n

#Observations 1902 and 4640 are outliers with high leverage values.
#They also have the highest two Cook's Distance values

listings[c(1902,4640),c("price", "price.bc", "avail", "num_reviews", 
"rpm", "nb","room_type")]

mod2 <- lm(price.bc ~ avail + num_reviews + rpm + nb + room_type, 
           data = listings[-c(1902,4640),])
summary(mod2)
drop1(mod2, test = "F")

####Random Forest####

library(randomForest)
listings2 <- listings[,-c(1,3,4,6)]

rf <- randomForest(price.bc~., data = listings2)


sum((mod1$residuals)^2)
sum((listings2$price.bc - predict(rf))^2)

pricing <- mod1
saveRDS(pricing, here("data", "pricing_model.rds"))
final <- ls()[!(ls()%in%c("pricing","rf"))&!(ls()%in%og)]
rm(list = final)
rm(final)
