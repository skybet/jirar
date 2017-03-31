#!/usr/bin/env bash

#USAGE:   sh ./RUNME.sh <SECRETBASE64JIRADEETS> <SQUAD> PUBLISH
#E.G.     sh ./RUNME.sh c2VjcmV0dXNlcjpzZWNyZXRwYXNz TS PUBLISH

SECRET=$1
SQUAD=$2
PUBLISH=$3

set -x
set -e

SECRET=$SECRET PROJECT=$SQUAD docker run -e SECRET -e PROJECT -v $(pwd)/jiraData/:/usr/src/app/jiraData/ jirar-extract

PROJECT=$SQUAD docker run -e PROJECT -v $(pwd):/home/user/jiraR jirar-report

mv report/jiraR.html jiraReport/jiraR-$SQUAD.html

sh ./publish.sh $SECRET $SQUAD $PUBLISH



