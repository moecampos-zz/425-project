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
library(stringr)

# data cleaning. This loads listings data.frame with the data
source(here("R", "cleaning.R"), local = TRUE)
source(here("R", "spatial.R"), local = TRUE)
source(here("R", "text_model.R"), local = TRUE)
source(here("R", "significance.R"), local = TRUE)

# load models
text_model <- readRDS(here("data", "text_model.rds"))
pricing_model <- readRDS(here("data", "pricing_model.rds"))

# Add predictions to listings
listings$fit <- fitted(pricing_model)^(-1/0.4)

gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

neighborhood_hues <- function() {
  hues <- gg_color_hue(9)
  names(hues) <- bigNineNeighborhoods
  hues
}

which_neighborhood_hue <- function(neighborhood) {
  hues <- neighborhood_hues()
  hues[[neighborhood]]
}

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # holds the current position used for querying
  current_position <- reactiveValues(lat = NA, lon = NA)

  # Reactive expression for the data subsetted to what the user selected
  rentalsInBounds <- reactive({
    if(input$neighborhood == 'All') {
      selected_listings <- listings
    } else {
      selected_listings <- listings %>%
      filter(nb == input$neighborhood)
    }
    
   if (!is.na(current_position$lat) && !is.na(current_position$lon)) {
     coords <- selected_listings %>%
       select(lon, lat)

      selected_points <- within_radius(
        lat = current_position$lat, lon = current_position$lon, coords,
        radius = input$search_radius * 1000)
      return(listings[selected_points, ])
    }

    selected_listings
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

  output$neighborhood_boxplot <- renderPlot({
    if (input$neighborhood != 'All') {
     g <- ggplot(rentalsInBounds()) +
      geom_histogram(aes(fit), fill = which_neighborhood_hue(input$neighborhood), alpha = 0.75) +
      labs(x = "Predicted Price", y = "Listings", 
           title = paste("Predicted Prices for", input$neighborhood, collapse = ' ')) +
      theme_hc()
    } else {
      g <- ggplot(listings, aes(x = nb, y = price, color = nb)) +
        geom_boxplot() +
        coord_flip() +
        scale_color_manual(values=neighborhood_hues()) +
        scale_color_discrete("") +
        xlab('Venice Neighborhood') +
        ylab('Actual Price Per Night ($)') +
        ggthemes::theme_hc()
    }

    g
  })

  # an example of how to render a plot on selected data
  output$scatter_plot <- renderPlot({
    if (nrow(rentalsInBounds()) == 0) {
      return(NULL)
    }
    
    x_labels <- c("Room Type"="room_type", 
      'Minimum Nights Per Stay'='min_nights',
      'Reviews Per Month'='rpm', 
      'Number of Reviews'='num_reviews',
      'Nights Available Per Year'='avail')
    
    ggplot(rentalsInBounds(), aes_string(x = x_labels[[input$plot_variable]], y = 'fit')) +
      geom_point(color = 'steelblue', alpha = 0.1) + 
      ylab('Predicted Price') +
      xlab(input$plot_variable) +
      ggthemes::theme_hc()
  })

  output$word_cloud <- renderPlot({
    if (input$neighborhood == 'All') {
      return()
    }
    plot(text_model, input$neighborhood)
  })
  
  output$neighborhood_waffle <- renderPlot({
    ggplot(sigData, aes(x=namesOne, y=namesTwo, fill=isSign,  col = "black")) + 
      geom_tile(col="black") + 
      scale_fill_manual(values = c("#F1BB7B", "#FD6467"), name="Significant") + 
      labs(x = "Neighborhood", y = "Neighborhood", title = "Significance") + 
      ggthemes::theme_hc()
  })

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
    if (input$neighborhood == 'All') {
      nb <- listings
    } else {
      nb <- listings %>%
        filter(nb == input$neighborhood)
    }

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
