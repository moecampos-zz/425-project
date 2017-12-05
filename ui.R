#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(leaflet)
library(shinydashboard)

header <- dashboardHeader(
  title = "Venice Pirates!"
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  fluidRow(
    column(width = 8,
      box(width = NULL, solidHeader = TRUE,
        leaflet::leafletOutput("map", height = 500)
      )
    ),
    column(width = 4,
      sliderInput('search_radius', 'Radius (km)',
                  min = 1, max = 10, value = 1, step = 1),
      tabBox(
        width = NULL,
        tabPanel("Room Types", plotOutput('hist_room_type')),
        tabPanel("Other Plot", "Other STuff")
      )
    )
  ),
  fluidRow(
    column(width = 8,
      box(width = NULL,
          DT::dataTableOutput('view_data')
      )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)