library(shiny)

shinyUI(fluidPage(
  titlePanel(
    HTML(
      "<h5><h5><style>h2,h4 { display: inline; }</style><h2>UK University Journal Costs</h2><h4><span style=float:right><a href=\"http://retr0.me/2015/07/07/UK-HEI-journal-subscriptions.html\">About</a></span></h4><h5></h5>"
    ),
    windowTitle = "UK University Journal Costs"
  ),
  
  column(3,
         wellPanel(
           uiOutput("yearSelector"),
           uiOutput("instSelector")
         )),
  
  column(9,
         absolutePanel(
           tabsetPanel(
             tabPanel("Graph", plotOutput(outputId = "plot1")),
             tabPanel("Table", dataTableOutput(outputId = "dt1")),
             textInput("save_text", label = "Link to current state:", value =
                         "")
           ), fixed = T, right = 0, width = "75%"
         ))
))