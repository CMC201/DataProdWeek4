

library(shiny)

# Define UI for application that draws different temperature data plots
shinyUI(fluidPage(
  
  # Application title
  titlePanel("New York City Temperatures"),
  
  # Sidebar with a slider to select the desired year 
  sidebarLayout(
    sidebarPanel(
      h4('Instructions:'),
      paste0(
        "Use the slider to select a year to view temperature data from New York City's Central Park. ",
        "Use the tabs in the main panel to select plots of different temperature variables. ",
        "Future years are predicted using a simple ARIMA model. "
      ),
      sliderInput("year",
                   "Selected Year:",
                   min = 2009,
                   max = 2021,
                   value = 2015,sep=''),
      hr(),
      tags$small('Data obtained from the National Climate Data Center')),
    
    # Use tabs to show monthy average temperatures, days above 90F, days below 32F
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Monthly Average Temperature", plotOutput("avgPlot")),
                  tabPanel("Monthly Days Exceeding 90F", plotOutput("hotPlot")),
                  tabPanel("Monthly Days With Highs Below 32F", plotOutput("coldPlot"))
      )
    )
  )
)
)