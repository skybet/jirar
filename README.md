# Summary

This project creates some pictures based on jira data and uploads the resulting html report to confluence.
These should allow squads to gain some insight into their development cycle. Hopefully provoking discussions on improving the flow of work.

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


## Build docker containers

The report container takes an especially long time to build

* docker build -t jirar-report report
* docker build -t jirar-extract extract

## Setup config

The first time RUNME.sh is run, it copies two example config files.
These need updating with your details.

The first: `atlassianDetails.sh` needs the url of the rest-endpoint for Jira and Confluence

The second: `extract/boardList.js` is a mapping from jira project keys to boardIds. Instuctions are in the example file

You may manually created these config files before the first run by removing the .example suffix from the filenames and populating them yourself


# Examples

...

# Todo list / Idea List

* When looking up spend+worktype from the epic, look at other project's boards too 
* Shiny http://rmarkdown.rstudio.com/authoring_shiny.html
* Extract blocked time
* Extract re-work time/counts
* Integrate with stash to apply codebase metrics
* publish docker files to dockerhub

* Tribe level reports

