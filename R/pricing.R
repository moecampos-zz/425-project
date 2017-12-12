source('./R/cleaning.R')

listings %<>% na.omit()
listings %<>% select(-rpm)

mod1 <- lm(price ~ avail + num_reviews + min_nights + lat + lon, data = listings)
summary(mod1)

####Diagnostics####

num.out <- sum(sort(abs(rstudent(mod1)), decreasing = T) > qt(1-0.05/(6027*2), 6021))
outliers <- sort(abs(rstudent(mod1)), decreasing = T)[1:num.out] %>% names() %>% as.numeric()
listings[outliers,c("avail","num_reviews","min_nights","lat","lon","price")]



cook <- cooks.distance(mod1)
sort(abs(cook), decreasing = T)[1:5]

b <- regsubsets(price ~ avail + num_reviews + min_nights + lat + lon, data = listings)
rs <- summary(b)
rs$which
