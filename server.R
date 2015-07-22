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
ranks[,total := formatC(total, big.mark = ",", format = 'd')]
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
                         selected = c("University of Aberdeen",
                                      "Aberystwyth University")) 
    })
    
    output$plot1 <- renderPlot(expr = {
      if (!is.null(input$inInst)) {
        dataGraph <- data[J(as.numeric(input$inYear), input$inInst)]
        dataGraph[, institute := gsub("University of ", "", institute)]
        dataGraph[, institute := gsub(" University", "", institute)]
        dataGraph[, institute := gsub(" ", "\n", institute)]
        p <- (ggplot(dataGraph) + geom_bar(
          aes(x = institute, y = cost, fill = publisher), stat = "identity")
        + scale_y_continuous(labels = comma) 
        +ylab("Total cost (£)")
        +xlab(NULL)
        +theme(axis.text.x = element_text(colour="black"),
               axis.text.y = element_text(colour="black"))
        )
        print(p)
      }
    })
    
    output$dt1 <- renderDataTable(expr = {
      if (!is.null(input$inInst)) {
        dataDT <- ranks[J(as.numeric(input$inYear), input$inInst)][order(rank), .(rank, institute, total)]
        setnames(dataDT, c('rank','institute','total'), c("Rank", "Institute", "Total (£)"))
        dataDT
      }
    }, options = list(searching = FALSE,
                      paging = T,
                      lengthMenu = list(c(5, 10, -1), c('5', '10', 'All')),
                      pageLength = 5))
    
  }
)