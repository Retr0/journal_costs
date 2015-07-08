library(data.table)
library(ggplot2)
library(shiny)
library(scales)

shinyServer(
  function(input, output) {
    data <- fread('journal_costs_melted.tab', header = T)
    institutes <- data[,unique(institute)]
    years <- data[,unique(year)]
    setkey(data, institute)
    
    output$yearSelector <- renderUI({
      selectInput(inputId = "inYear", "Choose Year:", 
                         years, 
                         selected = c(2014)) 
    })
    
    output$instSelector <- renderUI({
      checkboxGroupInput(inputId = "inInst", "Choose Institute:", 
                         institutes, 
                         selected = c("University of Manchester",
                                      "Open University")) 
    })
    
    output$plot1 <- renderPlot(expr = {
      if (!is.null(input$inInst)) {
        choices <- data.table(inst = input$inInst, key = "inst")
        p <- (ggplot(data[choices][year==input$inYear]) + geom_bar(
          aes(x = institute, y = cost, fill = publisher), stat = "identity")
        + scale_y_continuous(labels = comma) 
        +ylab("Total cost (£)")
        )
        print(p)
      }
    })
    
    output$dt1 <- renderDataTable(expr = {
      if (!is.null(input$inInst)) {
        dataDT <- data[year==input$inYear]
        inst_rank <- dataDT[,.(total=sum(cost, na.rm = T)), by=institute][order(-total), institute]
        dataDT[,rank:=match(institute, inst_rank)]
        choices <- data.table(inst = input$inInst, key = "inst")
        dataDT <- dataDT[choices][,.(total=sum(cost, na.rm = T)),by=.(rank,institute)][order(-total)]
        dataDT[,total := formatC(total, big.mark = ",", format = 'd')]
        setnames(dataDT, c('rank','institute','total'), c("Rank", "Institute", "Total (£)"))
        dataDT
      }
    }, options = list(searching = FALSE,
                      paging = FALSE))
    
  }
)