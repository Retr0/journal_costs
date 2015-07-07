library(data.table)
library(ggplot2)
library(shiny)
library(scales)

shinyServer(
  function(input, output) {
    data <- fread('journal_costs_melted.tab', header = T)
    data <- data[year==2014]
    institutes <- data[,unique(institute)]
    setkey(data, institute)
    inst_rank <- data[,.(total=sum(cost, na.rm = T)), by=institute][order(-total), institute]
    data[,rank:=match(institute, inst_rank)]
    
    output$instSelector <- renderUI({
      checkboxGroupInput(inputId = "choices", "Choose Institute:", 
                         institutes, 
                         selected = c("University of Manchester",
                                      "Open University")) 
    })
    
    output$plot1 <- renderPlot(expr = {
      if (!is.null(input$choices)) {
        choices <- data.table(inst = input$choices, key = "inst")
        p <- (ggplot(data[choices]) + geom_bar(
          aes(x = institute, y = cost, fill = publisher), stat = "identity")
        + scale_y_continuous(labels = comma) 
        +ylab("Total cost (£)")
        )
        print(p)
      }
    })
    
    output$dt1 <- renderDataTable(expr = {
      if (!is.null(input$choices)) {
        choices <- data.table(inst = input$choices, key = "inst")
        d <- data[choices][,.(total=sum(cost, na.rm = T)),by=.(rank,institute)][order(-total)]
        d[,total := prettyNum(total, big.mark = ",")]
        setnames(d, c('rank','institute','total'), c("Rank", "Institute", "Total (£)"))
        d
      }
    }, options = list(searching = FALSE,
                      paging = FALSE))
    
  }
)