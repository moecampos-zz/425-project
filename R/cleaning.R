library(dplyr)
library(magrittr)

listings <- read.csv("./data/listings.csv", header = TRUE) %>%
  select(-id, -name, -host_name, -last_review, -calculated_host_listings_count) %>%
  transmute(host = host_id, nb_group = neighbourhood_group, nb = neighbourhood,
            lat = latitude, lon = longitude, room_type = room_type, price = price,
            min_nights = minimum_nights, num_reviews = number_of_reviews,
            rpm = reviews_per_month, avail = availability_365)
