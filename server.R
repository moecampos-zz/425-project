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

# data cleaning. This loads listings data.frame with the data
source('./R/cleaning.R', local = TRUE)
source('./R/spatial.R', local = TRUE)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # Reactive expression for the data subsetted to what the user selected
  rentalsInBounds <- eventReactive(input$map_click, {
    clicked <- input$map_click
    coords <- listings %>% 
      select(lon, lat)
    
    selected_points <- within_radius(
      lat = clicked$lat, lon = clicked$lng, coords,
      radius = input$search_radius * 1000)
    
    listings[selected_points, ]
  })
  
  # Make the intial map
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
      coord_flip()
  })
  
  output$view_data <- DT::renderDataTable(
    rentalsInBounds(),
    options = list(scrollX = TRUE)
  )
  
  # observe mouse clicks and add a circle (radius in meters)
  observeEvent(input$map_click, {
    clicked <- input$map_click
    clicked_lat <- clicked$lat
    clicked_lng <- clicked$lng
    
    leafletProxy('map') %>% 
      # delete old circle
      clearGroup(group = 'circles') %>% 
      addCircles(lng = clicked_lng, lat = clicked_lat, group = 'circles',
                 weight = 1, radius = input$search_radius * 1000, 
                 color = 'black', fillColor = 'orange',
                 fillOpacity = 0.5, opacity = 1)
  })
}
