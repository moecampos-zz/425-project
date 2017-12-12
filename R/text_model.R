library(wordcloud)
library(tidyverse)


top_n_coefs <- function(coefs, n = NULL) {
  coefs <- coefs[order(coefs, decreasing = TRUE), ]
  if (!is.null(n)) {
    coefs <- coefs[1:n]
  }
  coefs
}


init_text_model <- function(estimator, neighborhoods) {
  structure(list(coefs = coef(estimator), 
                 neighborhoods = neighborhoods),
            class = 'text_model')
}


plot.text_model <- function(object, neighborhood) {
  coef_index <- which(object$neighborhoods == neighborhood)
    
  as.tibble(top_n_coefs(object$coefs[[coef_index]])) %>% 
    rownames_to_column(var = 'term') %>% 
    with(wordcloud(term, value, scale = c(4, 0.5), max.words = 100, 
                   random.order = FALSE,
                   colors = brewer.pal(6, "Dark2")))
}