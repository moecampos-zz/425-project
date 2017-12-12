#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source('./header.R')

source('./R/cleaning.R', local = TRUE)
source('./R/text_model.R', local = TRUE)

# load models
text_model <- readRDS('./data/text_model.rds')

header <- dashboardHeader(
  title = "Venice Pirates!"
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  fluidRow(
    column(width = 6,
      sliderInput('search_radius', 'Radius (km)',
                  min = 1, max = 10, value = 1, step = 1),
      box(width = NULL, solidHeader = TRUE,
        leaflet::leafletOutput("map", height = 500))
    ),
    column(width = 6,
      selectInput("neighborhood", "Neighborhood:",
                  choices = text_model$neighborhoods),
      tabBox(
        width = NULL, height = 500,
        tabPanel("Important Terms", plotOutput('word_cloud', height = 500)),
        tabPanel("Room Types", plotOutput('hist_room_type', height = 500))
      )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)