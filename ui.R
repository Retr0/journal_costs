library(shiny)

shinyUI(fluidPage(
  titlePanel("UK University Journal Costs for 2014"),
    
  sidebarLayout(
    sidebarPanel( uiOutput("instSelector") ),
    mainPanel(plotOutput(outputId = "plot1"),
              dataTableOutput(outputId="dt1"))
  )
))
