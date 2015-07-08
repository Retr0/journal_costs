library(shiny)

shinyUI(fluidPage(
  titlePanel("UK University Journal Costs"),
    
  sidebarLayout(
    sidebarPanel( uiOutput("yearSelector"),
                  uiOutput("instSelector")),
    
    mainPanel(plotOutput(outputId = "plot1"),
              dataTableOutput(outputId="dt1"))
  )
)
)
