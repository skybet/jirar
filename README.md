# Summary

This project creates some pictures based on jira data.
These should allow squads to gain some insight into their development cycle. Hopefully provoking some discussions on improving the flow of work.

# Usage

1. get Jira Access Token
2. Run script against project

e.g.
```
echo -n Username:Password | base64
sh ./RUNME.sh <JIRAACCESSTOKEN> <PROJECT> <PUBLISH?>
sh ./RUNME.sh <randombase64hash> TS PUBLISH
```

# Installation


## Docker version...

* docker build -t jirar-report report
* docker build -t jirar-extract extract

## Local version...

1. Install R https://cran.rstudio.com/
2. Install RStudio (Recommended) https://www.rstudio.com/products/rstudio/download/
3. Install R Libraries - within rstudio console type: ```install.packages(c("ggplot2", "lubridate", "dplyr", "forcats", "reshape2", "knitr", "rmarkdown", "gtools"));```
4. Install Nodejs https://nodejs.org/en/
5. ```npm install```
6. Run RUNME.sh against your squad -- See Usage above

 *Download an old version of the RUNME.sh script*

# Todo list / Idea List

* When looking up spend+worktype from the epic, look at other project's boards too 
* Shiny http://rmarkdown.rstudio.com/authoring_shiny.html
* Extract blocked time
* Display Dwell Percentage
* Extract re-work time/counts
* Integrate with stash to apply codebase metrics

* Tribe level reports

