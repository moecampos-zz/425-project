library(here)
library(tidyverse)



bigNineNeighborhoods <- c("San Marco", "Castello", "Cannaregio", "Dorsoduro", 
                          "Giudecca", "Lido", "Santa Croce", "Murano", 
                          "San Polo")

listings_with_id <- read.csv(here("data", "listings.csv"), header = TRUE) %>%
  dplyr::select(-name, -host_name, -last_review, -calculated_host_listings_count) %>%
  transmute(id = id, host = host_id, nb = neighbourhood, 
            lat = latitude, lon = longitude, 
            room_type = room_type, price = price, min_nights = minimum_nights, 
            num_reviews = number_of_reviews,
            rpm = reviews_per_month, avail = availability_365) %>% 
  filter(nb %in% bigNineNeighborhoods)

listings_with_id[is.na(listings_with_id)] <- 0
listings_with_id$nb <- droplevels(listings_with_id$nb)

listings <- listings_with_id %>% 
  dplyr::select(-id) %>%
  mutate(price.bc = price^-0.4)