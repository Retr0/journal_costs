library(shiny)

shinyUI(fluidPage(
  titlePanel("UK University Journal Costs"),
    
  sidebarLayout(
    sidebarPanel( uiOutput("yearSelector"),
                  uiOutput("instSelector")),
    
    mainPanel(plotOutput(outputId = "plot1"),
              dataTableOutput(outputId="dt1"),
              h5(tags$a(href="http://retr0.me/2015/07/07/UK-HEI-journal-subscriptions.html", "Blog post with more details")))
  )
)
)
