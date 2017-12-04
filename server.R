#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(leaflet)

#venice <- readr::read_csv('./data/listings.csv')

# data cleaning. This loads listings data.frame with the data
source('./R/cleaning.R', local = TRUE)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  rentalsInBounds <- reactive({
    if (is.null(input$map_bounds)) {
      return(listings[FALSE,])
    }
    bounds <- input$map_bounds
    lat_range <- range(bounds$north, bounds$south)
    lon_range <- range(bounds$east, bounds$west)

    listings %>%
      filter(lat >= lat_range[1] & lat <= lat_range[2] &
          lon >= lon_range[1] & lon <= lon_range[2])
  })

  output$map <- renderLeaflet({
    leaflet(data = listings) %>%
      addTiles() %>%
      fitBounds(~min(lon), ~min(lat),
                ~max(lon), ~max(lat)) %>%
      addMarkers(~lon, ~lat,
        clusterOptions = markerClusterOptions())
  })

  output$hist_room_type <- renderPlot({
    if (nrow(rentalsInBounds()) == 0) {
      return(NULL)
    }

    ggplot(rentalsInBounds(), aes(x = room_type)) +
      geom_bar(fill = 'steelblue', color = 'steelblue') +
      coord_flip() +
      loyalr::theme_pub()
  })
}
