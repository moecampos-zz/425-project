source(here('R', 'cleaning.R'), local = TRUE)

#Using the big 9 neighborhoods
mor <- aov(price ~ nb, data = listings)

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
isSign <- as.factor(ifelse(pVals < 0.05, "Yes", "No"))
sigData <- data.frame(namesOne, namesTwo, pVals, isSign)




