library(shiny)

shinyUI(fluidPage(
  titlePanel("UK University Journal Costs"),
  
  column(3,
         wellPanel(
           uiOutput("yearSelector"),
           uiOutput("instSelector")
         )),
  
  column(9,
         absolutePanel(
           tabsetPanel(
             tabPanel("Graph", plotOutput(outputId = "plot1"),
                      tags$br()),
             tabPanel("Table", dataTableOutput(outputId = "dt1")),
             tabPanel(
               "About",
               tags$p(
                 "Data from freedom of information requests submitted by Stuart Lawson and Ben Meghreblian available",
                 tags$a(href = "http://dx.doi.org/10.12688/f1000research.5706.3", "here")
               ),
               tags$p(
                 "For more information see my ",
                 tags$a(href = "http://retr0.me/2015/07/07/UK-HEI-journal-subscriptions.html", "blog post")
               ),
               tags$p(
                 "Code for this shiny app and data processing are at my ",
                 tags$a(href = "https://github.com/Retr0/journal_costs", "github")
               ),tags$br(),tags$br(),tags$br()
             ),
             textInput("save_text", label = "Link to current state:", value = "")
           ), fixed = T, right = 0, width = "75%"
         ))
))