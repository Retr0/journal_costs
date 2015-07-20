library(data.table)
library(ggplot2)
library(shiny)
library(scales)

data <- fread('journal_costs_melted.tab', header = T)
institutes <- data[,unique(institute)]
years <- data[,unique(year)]
setkey(data, year, institute)

# precompute the ranks
ranks <- data[,.(total=sum(cost, na.rm = T)),by=.(institute, year)][, .(institute, total, rank=frank(-total, ties.method = "min")), by=year]
setkey(ranks, year, institute)

shinyServer(
  function(input, output) {
    
    output$yearSelector <- renderUI({
      selectInput(inputId = "inYear", "Choose Year:", 
                         years, 
                         selected = 2014 ) 
    })
    
    output$instSelector <- renderUI({
      checkboxGroupInput(inputId = "inInst", "Choose Institute:", 
                         institutes, 
                         selected = c("University of Manchester",
                                      "Open University")) 
    })
    
    output$plot1 <- renderPlot(expr = {
      if (!is.null(input$inInst)) {
        p <- (ggplot(data[J(as.numeric(input$inYear), input$inInst)]) + geom_bar(
          aes(x = institute, y = cost, fill = publisher), stat = "identity")
        + scale_y_continuous(labels = comma) 
        +ylab("Total cost (£)")
        )
        print(p)
      }
    })
    
    output$dt1 <- renderDataTable(expr = {
      if (!is.null(input$inInst)) {
        dataDT <- ranks[J(as.numeric(input$inYear), input$inInst)][order(-total), .(rank, institute, total)]
        dataDT[,total := formatC(total, big.mark = ",", format = 'd')]
        setnames(dataDT, c('rank','institute','total'), c("Rank", "Institute", "Total (£)"))
        dataDT
      }
    }, options = list(searching = FALSE,
                      paging = FALSE))
    
  }
)