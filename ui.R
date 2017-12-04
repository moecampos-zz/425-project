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
  fluidRow(
    column(width = 8,
      box(width = NULL, solidHeader = TRUE,
        leaflet::leafletOutput("map", height = 500)
      )
    ),
    column(width = 4,
      tabBox(
        width = NULL,
        tabPanel("Room Types", plotOutput('hist_room_type')),
        tabPanel("Other Plot", "Other STuff")
      )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)