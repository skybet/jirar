#Shiny experiment 


docker build -t jirar-shiny shiny
docker run -p3838:3838 -v $(pwd)/jiraData/:/srv/shiny-server/jirar/jiraData  -v $(pwd)/log:/var/log/shiny-server/ jirar-shiny


For running locally, change:

start of app.R to:
    setwd("~/Desktop/jiraR/shiny/")
    dataPath <- "../jiraData/"
