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


#ggplot(tsTickets, aes(x=as.POSIXct(created), y=secondsInColumns.3.Amigos.In/60/60/24/1000)) + geom_point() + geom_smooth(method="lm")
#ggplot(tsTickets, aes(x=as.POSIXct(created), y=secondsInColumns.Implementation.In)) + geom_point() + geom_smooth()

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

