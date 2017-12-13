#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(here)
library(leaflet)
library(shiny)
library(tidyverse)

# data cleaning. This loads listings data.frame with the data
source(here("R", "cleaning.R"), local = TRUE)
source(here("R", "spatial.R"), local = TRUE)
source(here("R", "text_model.R"), local = TRUE)

# load models
text_model <- readRDS(here("data", "text_model.rds"))

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # holds the current position used for querying
  current_position <- reactiveValues(lat = NA, lon = NA)

  # Reactive expression for the data subsetted to what the user selected
  rentalsInBounds <- reactive({
    coords <- listings %>%
      filter(nb == input$neighborhood) %>%
      select(lon, lat)

    selected_points <- within_radius(
      lat = current_position$lat, lon = current_position$lon, coords,
      radius = input$search_radius * 1000)

    listings[selected_points, ]
  })

  # Make the intial map
  output$map <- renderLeaflet({
    leaflet(data = listings) %>%
      addTiles() %>%
      fitBounds(~min(lon), ~min(lat),
                ~max(lon), ~max(lat)) %>%
      addMarkers(~lon, ~lat, group = 'markers',
        clusterOptions = markerClusterOptions())
  })

  # an example of how to render a plot on selected data
  output$hist_room_type <- renderPlot({
    if (nrow(rentalsInBounds()) == 0) {
      return(NULL)
    }

    ggplot(rentalsInBounds(), aes(x = room_type)) +
      geom_bar(fill = 'steelblue', color = 'steelblue') +
      coord_flip()
  })

  output$word_cloud <- renderPlot({
    plot(text_model, input$neighborhood)
  })

  # for debugging I included the data table to make sure the selection makes
  # sense
  output$view_data <- DT::renderDataTable(
    rentalsInBounds(),
    options = list(scrollX = TRUE)
  )

  # observe mouse clicks and add a circle (radius in meters)
  observeEvent(input$map_click, {
    clicked <- input$map_click
    current_position$lat <- clicked$lat
    current_position$lon <- clicked$lng

    leafletProxy('map') %>%
      # delete old circle
      clearGroup(group = 'circles') %>%
      addCircles(lng = current_position$lon, lat = current_position$lat, group = 'circles',
                 weight = 1, radius = input$search_radius * 1000,
                 color = 'black', fillColor = 'orange',
                 fillOpacity = 0.5, opacity = 1)
  })

  # observe a change in the neighborhood group
  observeEvent(input$neighborhood, {
    nb <- listings %>%
      filter(nb == input$neighborhood)

    leafletProxy('map') %>%
      clearGroup(group = 'markers') %>%
      addMarkers(nb$lon, nb$lat, group = 'markers',
        clusterOptions = markerClusterOptions())
  })
  # observe a change in the radius of the circle
  observeEvent(input$search_radius, {
    if (is.na(current_position$lat) || is.na(current_position$lon)) {
      return()
    }

    leafletProxy('map') %>%
      # delete old circle
      clearGroup(group = 'circles') %>%
      addCircles(lng = current_position$lon, lat = current_position$lat,
        group = 'circles',
        weight = 1, radius = input$search_radius * 1000,
        color = 'black', fillColor = 'orange',
        fillOpacity = 0.5, opacity = 1)
  })

  # observe an event to clear the shape when clicked on
  observeEvent(input$map_shape_click, {
    click <- input$map_shape_click

    if (is.null(click$group)) {
      return()
    }

    if (click$group == 'circles') {
      leafletProxy('map') %>%
        clearGroup(group = 'circles')
    }
  })
}
