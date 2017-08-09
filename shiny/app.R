# Can be run from this directory with
# R -e "shiny::runApp('jiraRShiny.R', port=8100, host='0.0.0.0')"
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
#library(Cairo)   # For nicer ggplot2 output when deployed on Linux
#setwd("~/Desktop/jiraR/shiny/")
dataPath <- "./jiraData/"

files <- list.files(pattern="jiraRDataset-.*.csv", path=dataPath)
choices <- gsub(".csv", "", gsub("jiraRDataset-", "", files))

ui <- fluidPage(
  fluidRow(
    inputPanel(
      selectInput("squad", label = "Squad:",
                  choices = choices, selected = "TS"),
      
      dateRangeInput("dateRange", label = "Date Range:", start="2014-01-01"),
      selectInput("binWidth", label = "BinWidth:",
                  choices = c("Daily"=1, "Weekly"=7, "Monthly"=31), selected = 31)
    )
  ),
  fluidRow(
    plotlyOutput("plotVelocity", height = 300)
  ),
  fluidRow(
    plotlyOutput("plotWorkType", height = 400)
  )
)

server <- function(input, output) {
  
  tsTicketsR <- reactive({
    
  #input = NULL; input$squad = "TS"; input$binWidth = 31
    tsFilename <- paste0(dataPath, "jiraRDataset-", input$squad, ".csv")
    tsTickets <- read.csv(tsFilename, header=T, skipNul=T, na.strings="") %>%
      mutate(
        created = as.POSIXct(created), 
        createdMonthDisplay = format(created, format="%Y %B"),
        createdMonth = as.numeric(format(created, format="%Y%m")),
        resolutionDate = as.POSIXct(resolutionDate), 
        resolutionMonthDisplay = format(resolutionDate, format="%Y %B"),
        resolutionMonth = as.numeric(format(resolutionDate, format="%Y%m")),
        totalTime = resolutionDate - created
      ) %>% 
      filter(status != "Closed") %>% 
      filter(status != "to do") %>% 
      filter(status != "open") %>%
      filter(ticketType != "Epic") %>%
      filter(resolutionDate > as.POSIXct(input$dateRange)[1]) %>%
      filter(resolutionDate < as.POSIXct(input$dateRange)[2])
    
  })
  
  output$plotVelocity <- renderPlotly({

    tsTickets <- tsTicketsR()
    
    resolvedTickets <- tsTickets %>% arrange(resolutionMonth)
    resolvedTickets$resolutionMonthDisplay <- factor(tsTickets[order(tsTickets$resolutionMonth), "resolutionMonthDisplay"], levels=unique(tsTickets[order(tsTickets$resolutionMonth), "resolutionMonthDisplay"]))
    
    title <- paste0(input$squad, " - Velocity")
    v <- ggplot(filter(resolvedTickets, ! is.na(resolutionMonthDisplay)), aes(x=as.POSIXct(resolutionDate))) + 
      geom_bar(stat="count", binwidth=as.numeric(input$binWidth)*60*60*24) + #theme(axis.text.x = element_text(angle=60, hjust=1)) +
      ggtitle(title) + xlab("Resolution Month") + ylab("Tickets Resolved") 
    v
    ggplotly(v, tooltip="y")
  })
  
  output$plotWorkType <- renderPlotly({
    tsTickets <- tsTicketsR()
    #"Count:", ..count.., 
  p <- ggplot(filter(tsTickets, ! is.na(resolutionMonthDisplay)), aes(x=as.POSIXct(resolutionDate), fill=workType, text=paste("Count:", ..count..))) + 
    scale_fill_discrete(name=NULL, drop=F) + #Scale fill discrete had drop=F incase a single level is present but unused?
    geom_bar(stat="identity", position="fill", binwidth=as.numeric(input$binWidth)*60*60*24) + theme(legend.position = "bottom", axis.text.x = element_text(angle=60, hjust=1)) + 
    ggtitle(paste0(input$squad, " - Work Type Distribution")) + xlab("Resolution Month") + ylab("Work Type %") + scale_y_continuous(breaks=seq(0,1,0.25), labels=seq(0,100,25))
    
 # p <- ggplot(filter(tsTickets, ! is.na(resolutionMonthDisplay)), aes(x=as.Date(resolutionDate), y=totalTime, color=workType)) + 
 #   scale_fill_discrete(name=NULL, drop=F) + #Scale fill discrete had drop=F incase a single level is present but unused?
 #   geom_point(aes(text = paste("ticket:", key))) + theme(legend.position = "bottom", axis.text.x = element_text(angle=60, hjust=1)) + 
 #   ggtitle(paste0(input$squad, " - Work Type Distribution")) + xlab("Resolution Month") + ylab("Work Type %") + scale_y_continuous(breaks=seq(0,1,0.25), labels=seq(0,100,25))
  #p <- ggplot(data.frame(x=c(0,1,2,0,1,2,2.1), y=c(1,1,2,2,3,3,3)), aes( text=paste(..count.., "<br>", as.POSIXct(x, origin="2017-01-01")), x=as.POSIXct(x, origin="2017-01-01"), fill=as.factor(y))) + geom_bar(stat="identity", position="fill", binwidth=0.5) + scale_fill_discrete(name=NULL, drop=F)
  #p
  ggplotly(p, tooltip=c("fill", "text")) %>% layout(legend = list(orientation = 'h', y=-0.5))
  })
  
  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) "Hover on a point!" else d
  })
}

shinyApp(ui, server)
