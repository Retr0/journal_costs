library(data.table)
library(ggplot2)
library(shiny)
library(scales)

data <- fread('journal_costs_melted.tab', header = T)
institutes <- data[,unique(institute)]
years <- data[,unique(year)]
setkey(data, year, institute)

# precompute the ranks
ranks <-
  data[,.(total = sum(cost, na.rm = T)),by = .(institute, year)][, .(institute, total, rank =
                   frank(-total, ties.method = "min")), by = year]
ranks[,total := formatC(total, big.mark = ",", format = 'd')]
setkey(ranks, year, institute)

shinyServer(function(input, output, session) {
  output$yearSelector <- renderUI({
    year = 2014
    query <- parseQueryString(session$clientData$url_search)
    if ("year" %in% names(query)) {
      if (query$year %in% years) {
        year <- query$year
      }
    }
    selectInput(inputId = "inYear", "Choose Year:",
                years,
                selected = year)
  })
  
  output$instSelector <- renderUI({
    inst_sel = c(1, 3)
    query <- parseQueryString(session$clientData$url_search)
    if ("inst" %in% names(query)) {
      inst_string <- as.numeric(strsplit(query$inst, ",")[[1]])
      if (all(inst_string %in% 1:length(institutes))) {
        inst_sel <- inst_string
      }
    }
    checkboxGroupInput(inputId = "inInst", "Choose Institute:",
                       institutes,
                       selected = institutes[inst_sel])
  })
  
  output$plot1 <- renderPlot(expr = {
    if (!is.null(input$inInst)) {
      dataGraph <- data[J(as.numeric(input$inYear), input$inInst)]
      dataGraph[, institute := gsub("University of ", "", institute)]
      dataGraph[, institute := gsub(" University", "", institute)]
      dataGraph[, institute := gsub(" ", "\n", institute)]
      p <- (
        ggplot(dataGraph) + geom_bar(aes(
          x = institute, y = cost, fill = publisher
        ), stat = "identity")
        + scale_y_continuous(labels = comma)
        + ylab("Total cost (£)")
        + xlab(NULL)
        + theme(
          axis.text.x = element_text(colour = "black"),
          axis.text.y = element_text(colour = "black")
        )
      )
      print(p)
    }
  })
  
  output$dt1 <- renderDataTable(
    expr = {
      if (!is.null(input$inInst)) {
        dataDT <-
          ranks[J(as.numeric(input$inYear), input$inInst)][order(rank), .(rank, institute, total)]
        setnames(dataDT, c('rank','institute','total'), c("Rank", "Institute", "Total (£)"))
        dataDT
      }
    }, options = list(
      searching = FALSE,
      paging = T,
      lengthMenu = list(c(5, 10,-1), c('5', '10', 'All')),
      pageLength = 10
    )
  )
  
  observe({
    inst_ids <-
      paste(which(institutes %in% input$inInst), sep = "" ,collapse = ",")
    updateTextInput(
      session, inputId = "save_text", label = "Link to current state:",
      value = paste(
        session$clientData$url_protocol, "//",
        session$clientData$url_hostname,
        session$clientData$url_pathname,
        "?year=", input$inYear,
        "&inst=", inst_ids,
        sep = ""
      )
    )
  })
})