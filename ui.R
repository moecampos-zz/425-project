#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(here)
library(leaflet)
library(shiny)
library(shinydashboard)
library(tidyverse)


source(here("R", "cleaning.R"), local = TRUE)
source(here("R", "text_model.R"), local = TRUE)


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
                  min = 0.1, max = 2, value = 0.1, step = 0.1),
      box(width = NULL, solidHeader = TRUE,
        leaflet::leafletOutput("map", height = 500))
    ),
    column(width = 6,
      selectInput("neighborhood", "Neighborhood:",
                  choices = bigNineNeighborhoods),
      tabBox(
        width = NULL, height = 500,
        tabPanel("Important Terms", plotOutput('word_cloud', height = 500)),
        tabPanel("Room Types", plotOutput('hist_room_type', height = 500)),
        tabPanel("Predicted Prices", plotOutput('fit_hist', heigh = 500))
      )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)