source('./header.R')

within_radius <- function(lon, lat, coordinates, radius = 1000) {
  point <- cbind(lon, lat)
  distances <- geosphere::distm(point, coordinates, 
                                fun = geosphere::distVincentyEllipsoid)
  which(distances <= radius)
}
