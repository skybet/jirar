library(ggplot2)
library(dplyr)
library(reshape2)

tsTickets <- read.csv("/Users/grovesro/Desktop/jiraR/jiraRDataset.csv", header=T, skipNul=T, na.strings="") %>%
  mutate(
        created = as.POSIXct(created), 
        createdMonthDisplay = format(created, format="%Y %B"),
        createdMonth = as.numeric(format(created, format="%Y%m")),
        resolutionDate = as.POSIXct(resolutionDate), 
        resolutionMonthDisplay = format(resolutionDate, format="%Y %B"),
        resolutionMonth = as.numeric(format(resolutionDate, format="%Y%m"))
  )

#tsTickets$createdMonthDisplay <- factor(tsTickets[order(tsTickets$createdMonth), "createdMonthDisplay"], levels=unique(tsTickets[order(tsTickets$createdMonth), "createdMonthDisplay"]))
#tsTickets$resolutionMonthDisplay <- factor(tsTickets[order(tsTickets$resolutionMonth), "resolutionMonthDisplay"], levels=unique(tsTickets[order(tsTickets$resolutionMonth), "resolutionMonthDisplay"]))


statusColours <- c("secondsInColumns.Open" = "white", 
                   "secondsInColumns.Analysis.In" = "red", "secondsInColumns.Analysis.Out" = "white",
                   
                   "secondsInColumns.Test.Analysis.In" = "red", "secondsInColumns.Test.Analysis.Out" = "white",
                   "secondsInColumns.Elaboration.In" = "red", "secondsInColumns.Elaboration.Out" = "white",
                   
                   "secondsInColumns.3.Amigos.In" = "red", "secondsInColumns.3.Amigos.Out" = "white",
                   "secondsInColumns.Implementation.In" = "orange", "secondsInColumns.Implementation.Out" = "white",
                   "secondsInColumns.Review.In" = "#ffc966", "secondsInColumns.Review.Out" = "white",
                   "secondsInColumns.Demo.In" = "#ffc966", "secondsInColumns.Demo.Out" = "white",
                   "secondsInColumns.UAT.In" = "#ffc966", "secondsInColumns.UAT.Out" = "white",
                   
                   "secondsInColumns.Test.In" = "yellow", "secondsInColumns.Test.Out" = "white",
                   "secondsInColumns.Merged" = "green",
                   "secondsInColumns.Deploy.To.Test.In" = "#00dd00",
                   "secondsInColumns.Deploy.to.Test.Out" = "white",
                   
                   "secondsInColumns.Deployed.to.Test.Environment" = "#00dd00",
                   "secondsInColumns.Deployed.to.Staging.Environment" = "#00bb00",
                   "secondsInColumns.Release" = "#55bb55",
                   "secondsInColumns.Release.Validation" = "#22bb22",
                   
                   "secondsInColumns.Closed" = "#666666",
                   "secondsInColumns.Resolved" = "#666666"
)

resolvedTickets <- tsTickets %>% arrange(resolutionMonth)
resolvedTickets$resolutionMonthDisplay <- factor(tsTickets[order(tsTickets$resolutionMonth), "resolutionMonthDisplay"], levels=unique(tsTickets[order(tsTickets$resolutionMonth), "resolutionMonthDisplay"]))

ggplot(filter(resolvedTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay)) + 
  geom_freqpoly(stat="count", group=1) + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Velocity") + xlab("Resolution Month") + ylab("Tickets Resolved")

ggplot(filter(resolvedTickets, ! is.na(resolutionMonthDisplay)), aes(x=resolutionMonthDisplay)) + 
  geom_bar(stat="count") + theme(axis.text.x = element_text(angle=60, hjust=1)) +
  ggtitle("Velocity") + xlab("Resolution Month") + ylab("Tickets Resolved")

#Pretty but broken
createdTickets <- tsTickets %>% arrange(createdMonth)
createdTickets$createdMonthDisplay <- factor(tsTickets[order(tsTickets$createdMonth), "createdMonthDisplay"], levels=unique(tsTickets[order(tsTickets$createdMonth), "createdMonthDisplay"]))

ggplot(tsTickets, aes(x=createdMonthDisplay, group=!is.na(resolution), color=!is.na(resolution))) + stat_ecdf(geom="line") + scale_color_discrete("Resolved") +
  theme(axis.text.x = element_text(angle=60, hjust=1)) + ggtitle("Burnup Percentage") + ylab("Percentage Burnup") + xlab("Month")



summary <- tsTickets %>% 
  select( -created, -summary, -key, -resolution, -resolutionDate, -resolutionMonthDisplay, -resolutionMonth) %>% 
  arrange(createdMonth) %>%
  group_by(createdMonth, createdMonthDisplay) %>% 
  summarise_each(funs(mean(., na.rm = TRUE)))

summaryMelt <- melt(summary, id=c("createdMonthDisplay", "createdMonth")) %>% arrange(createdMonth)
#Factorise and sort the columns in reverse, so that 3Amigos is towards the left/bottom
summaryMelt$variable <- factor(summaryMelt$variable, levels = rev(levels(summaryMelt$variable)))
summaryMelt$createdMonthDisplay <- factor(summaryMelt[order(summaryMelt$createdMonth), "createdMonthDisplay"], levels=unique(summaryMelt[order(summaryMelt$createdMonth), "createdMonthDisplay"]))


summaryMelt %>%
  filter(variable != "secondsInColumns.Open") %>%
  filter(variable != "secondsInColumns.Analysis.In") %>%
  filter(variable != "secondsInColumns.Analysis.Out") %>%
  filter(variable != "secondsInColumns.Elaboration.In") %>%
  filter(variable != "secondsInColumns.Elaboration.Out") %>%
  filter(variable != "secondsInColumns.Test.Analysis.In") %>%
  filter(variable != "secondsInColumns.Test.Analysis.Out") %>%
  filter(variable != "secondsInColumns.Reopened") %>%
  filter(variable != "secondsInColumns.Resolved") %>%
  filter(variable != "secondsInColumns.Closed") %>%
  ggplot(aes(x=createdMonthDisplay, y=value/24/60/60/1000)) + 
  geom_bar(stat="identity", aes(fill=variable)) + ylab("days") + xlab("month") +
  theme(legend.position = "bottom") + scale_fill_manual(values=statusColours) + coord_flip() +
  guides(fill=guide_legend(reverse=TRUE)) + ggtitle("Phased Cycle Time - from ticket created date")


summaryResolved <- tsTickets %>% 
  select( -created, -createdMonth, -createdMonthDisplay, -summary, -key, -resolution, -resolutionDate) %>% 
  arrange(resolutionMonth) %>%
  group_by(resolutionMonth, resolutionMonthDisplay) %>% 
  summarise_each(funs(mean(., na.rm = TRUE)))

summaryResolvedMelt <- melt(summaryResolved, id=c("resolutionMonthDisplay", "resolutionMonth")) %>% arrange(resolutionMonth)
#Factorise and sort the columns in reverse, so that 3Amigos is towards the left/bottom
summaryResolvedMelt$variable <- factor(summaryResolvedMelt$variable, levels = rev(levels(summaryResolvedMelt$variable)))
summaryResolvedMelt$resolutionMonthDisplay <- factor(summaryResolvedMelt[order(summaryResolvedMelt$resolutionMonth), "resolutionMonthDisplay"], levels=unique(summaryResolvedMelt[order(summaryResolvedMelt$resolutionMonth), "resolutionMonthDisplay"]))

summaryResolvedMelt %>%
  filter(! is.na(resolutionMonth)) %>% #Only show resolved tickets
  filter(variable != "secondsInColumns.Open") %>%
  filter(variable != "secondsInColumns.Analysis.In") %>%
  filter(variable != "secondsInColumns.Analysis.Out") %>%
  filter(variable != "secondsInColumns.Elaboration.In") %>%
  filter(variable != "secondsInColumns.Elaboration.Out") %>%
  filter(variable != "secondsInColumns.Test.Analysis.In") %>%
  filter(variable != "secondsInColumns.Test.Analysis.Out") %>%
  filter(variable != "secondsInColumns.Reopened") %>%
  filter(variable != "secondsInColumns.Resolved") %>%
  filter(variable != "secondsInColumns.Closed") %>%
  ggplot(aes(x=resolutionMonthDisplay, y=value/24/60/60/1000)) + 
  geom_bar(stat="identity", aes(fill=variable)) + ylab("days") + xlab("month") +
  theme(legend.position = "bottom") + scale_fill_manual(values=statusColours) + coord_flip() +
  guides(fill=guide_legend(reverse=TRUE)) + ggtitle("Phased Cycle Time - Resolved Date")




#BURNUP

createdTickets <- tsTickets %>%
  arrange(createdMonth) %>%
  group_by(createdMonth, createdMonthDisplay) %>%
  dplyr::summarise(created=n()) %>% ungroup() %>%
  arrange(createdMonth) %>%
  mutate(cum_created=cumsum(created))
  

resolvedTickets <- tsTickets %>%
  group_by(resolutionMonth, resolutionMonthDisplay) %>%
  dplyr::summarise(resolved=n()) %>% ungroup() %>%
  arrange(resolutionMonth) %>%
  mutate(cum_resolved=cumsum(resolved))

burnupTickets <- full_join(createdTickets, resolvedTickets, by=c("createdMonth"="resolutionMonth", "createdMonthDisplay"="resolutionMonthDisplay"))



burnupTicketsMelt <- burnupTickets %>%
  filter(!is.na(createdMonth)) %>%
  select(-created, -resolved) %>%
  melt(id=c("createdMonthDisplay", "createdMonth")) %>% 
  arrange(createdMonth)
  
burnupTicketsMelt$createdMonthDisplay <- factor(burnupTicketsMelt[order(burnupTicketsMelt$createdMonth), "createdMonthDisplay"], levels=unique(burnupTicketsMelt[order(burnupTicketsMelt$createdMonth), "createdMonthDisplay"]))

ggplot(burnupTicketsMelt, aes(x=createdMonthDisplay, y=value, group=variable, color=variable)) + 
  geom_line(na.rm=T) + 
  theme(axis.text.x = element_text(angle=60, hjust=1)) + 
  ggtitle("Burn-up (tickets created and resolved)") + scale_color_discrete("Resolved", breaks=c("cum_created", "cum_resolved"), labels=c("Created", "Resolved")) + ylab("Number of tickets") + xlab("Month")


burnupTicketsMelt <- burnupTickets %>%
  filter(!is.na(createdMonth)) %>%
  select(-cum_created, -cum_resolved) %>%
  melt(id=c("createdMonthDisplay", "createdMonth")) %>% 
  arrange(createdMonth)

burnupTicketsMelt$createdMonthDisplay <- factor(burnupTicketsMelt[order(burnupTicketsMelt$createdMonth), "createdMonthDisplay"], levels=unique(burnupTicketsMelt[order(burnupTicketsMelt$createdMonth), "createdMonthDisplay"]))

ggplot(burnupTicketsMelt, aes(x=createdMonthDisplay, y=value, group=variable, color=variable)) + 
  geom_line(na.rm=T) + 
  theme(axis.text.x = element_text(angle=60, hjust=1)) + 
  ggtitle("tickets created and resolved") + scale_color_discrete("Resolved", breaks=c("created", "resolved"), labels=c("Created", "Resolved")) + ylab("Number of tickets") + xlab("Month")
