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
library(ggthemes)


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
                  choices = c('All', bigNineNeighborhoods), selected = "All"),
      tabBox(
        width = NULL, height = 500,
        tabPanel("Price per Neighborhood", plotOutput('neighborhood_boxplot', height = 500)),
        tabPanel("Price Comparison", plotOutput('neighborhood_waffle', height = 500)),
        tabPanel("Important Terms", plotOutput('word_cloud', height = 500)),
        tabPanel("Price per Feature", 
          selectInput("plot_variable", "Variable Name:", 
                      choices = c("Room Type", 
                        'Minimum Nights Per Stay',
                        'Reviews Per Month', 
                        'Number of Reviews',
                        'Nights Available Per Year')),
          plotOutput('scatter_plot', height = 400))
      )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)