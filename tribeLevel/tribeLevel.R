library(tidyverse)
library(forcats)

files <- list.files(pattern="jiraRDataset-.*.csv", path="/Users/grovesro/Desktop/jiraR/")
#filesBCT <- c("jiraRDataset-CT.csv", "jiraRDataset-BCT.csv", "jiraRDataset-BCTDR.csv", "jiraRDataset-PT.csv")
#filesTS <- c("jiraRDataset-TR.csv", "jiraRDataset-TS.csv", "jiraRDataset-TFS.csv", "jiraRDataset-TSI.csv", "jiraRDataset-PE.csv")

filePaths <- paste(c("/Users/grovesro/Desktop/jiraR/"), files, sep="")

tribeTickets <- lapply(filePaths, readr::read_csv) %>% 
  lapply(function(ts) { select(ts, -starts_with("SecondsInColumn")) }) %>%
  bind_rows() %>%
  mutate(
    project = sub("-.*", "", key),
    resolutionDate = as.POSIXct(resolutionDate),
    resolutionMonthDisplay = format(resolutionDate, format="%Y %B"),
    resolutionMonth = as.numeric(format(resolutionDate, format="%Y%m")),
    totalTime = resolutionDate - created
  ) %>% 
  #filter(status != "Closed") %>% 
  filter(status != "to do") %>% 
  filter(status != "open") %>%
  filter(ticketType != "Epic")


tribeTickets$resolutionMonthDisplay <- fct_reorder(tribeTickets$resolutionMonthDisplay, tribeTickets$resolutionMonth)

unique(tribeTickets$project)

ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay)) + 
  geom_bar(stat="count") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Velocity") + xlab("Resolution Month") + ylab("Tickets Resolved") 

ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay, fill=project)) + 
  geom_bar(stat="count") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Velocity - Squad Stack") + xlab("Resolution Month") + ylab("Tickets Resolved") 

ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay, fill=project)) + 
  geom_bar(stat="count", position="dodge") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Velocity - Squad Dodge") + xlab("Resolution Month") + ylab("Tickets Resolved") 



ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay, fill=project)) + 
  geom_bar(stat="count", position="fill") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Velocity - Squad Percentage") + xlab("Resolution Month") + ylab("Tickets Resolved") 


ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay, fill=workType)) + 
  geom_bar(stat="count", position="fill") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Work Type") + xlab("Resolution Month") + ylab("Tickets Resolved") 

ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay, fill=spend)) + 
  geom_bar(stat="count", position="fill") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Spend Type") + xlab("Resolution Month") + ylab("Tickets Resolved") 

ggplot(filter(tribeTickets, ! is.na(resolutionMonthDisplay) & ! is.na(spend)), aes(x=resolutionMonthDisplay, fill=spend)) + 
  geom_bar(stat="count", position="fill") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Tribe Spend Type - Excluding NA") + xlab("Resolution Month") + ylab("Tickets Resolved")

violinData <- tribeTickets %>% 
  filter(! is.na(resolutionMonthDisplay)) %>% 
  filter(status != "Closed")
ggplot(violinData, aes(x=resolutionMonthDisplay, y=totalTime/24/60/60)) + 
  geom_violin(scale="width", draw_quantiles=c(0.5,0.75)) + #geom_jitter(height=0, size=0.2, width=0.2) +
  theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Velocity Violin Distribution - created to resolved") + xlab("Resolution Month") + ylab("Days")

