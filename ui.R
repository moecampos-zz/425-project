#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(leaflet)
library(shiny)

# Define UI for application that draws a histogram
ui <- shiny::bootstrapPage(
  tags$link(rel = "stylesheet", type = "text/css",  href = 'styles.css'),
  leaflet::leafletOutput("map", width = "100%", height = "100%"),
  fixedPanel(id = "controls", class = "panel panel-default",
             draggable = TRUE, top = 60, left = "auto", right = 20,
             bottom = "auto", width = 330, height = "auto",

    # start of html inside side-panel
    h2("Rental Explorer"),

    plotOutput("hist_room_type", height = 200)
  )
)
