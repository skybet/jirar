#!/usr/bin/env bash

#USAGE:   sh ./RUNME.sh <SECRETBASE64JIRADEETS> <SQUAD> PUBLISH
#E.G.     sh ./RUNME.sh c2VjcmV0dXNlcjpzZWNyZXRwYXNz TS PUBLISH

SECRET=$1
SQUAD=$2
PUBLISH=$3

set -x
set -e

node issueScrape.js $SECRET $SQUAD

cp jiraRDataset.csv jiraRDataset-$SQUAD.csv



dirname=`dirname $0`

if [ -d /Applications/RStudio.app/Contents/MacOS/pandoc ]
then
    export RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/MacOS/pandoc
fi

Rscript -e "rmarkdown::render('${dirname}/./jiraR.Rmd', params = list( ))"

mv jiraR.html jiraR-$SQUAD.html

sh ./publish.sh $SECRET $SQUAD $PUBLISH



