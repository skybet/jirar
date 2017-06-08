#!/usr/bin/env bash

set -e

SECRET=$1
SQUAD=$2
PUBLISH=$3

DATE=`date "+%Y/%m/%d"`
if [ -f jiraReport/jiraR-$SQUAD.html ]
then


parentPage=

if [[ "$SQUAD" == "TS" || "$SQUAD" == "PE" || "$SQUAD" == "TSI" ]]
then
    parentPage=26676200
fi

if [[ "$SQUAD" == "VBS" || "$SQUAD" == "HRS" || "$SQUAD" == "NGU" || "$SQUAD" == "SBP" ]]
then
    parentPage=46269728
fi

if [[ "$SQUAD" == "BCT" ]]
then
    parentPage=46269728
fi

printf '{\"type\":\"page\",\"title\":\"' > publishTemplate.json
printf "$SQUAD JiraR stats $DATE" >> publishTemplate.json
printf '\", \"ancestors\":[{\"id\":' >> publishTemplate.json
printf "$parentPage" >> publishTemplate.json
printf '}], \"space\":{\"key\":\"TBT\"},\"body\":{\"storage\":{\"value\":\"<ac:structured-macro ac:name=\\"listlabels\\"></ac:structured-macro><ac:structured-macro ac:name=\\"html\\"><ac:plain-text-body><![CDATA[<div>' >> publishTemplate.json
sed 's/"/\\"/g' jiraReport/jiraR-$SQUAD.html >> publishTemplate.json
printf '</div>]]>ViewTracker here</ac:plain-text-body></ac:structured-macro><ac:structured-macro ac:name=\\"viewtracker\\"></ac:structured-macro>\",\"representation\":\"storage\"}}}' >> publishTemplate.json


    if [[ "$PUBLISH" == "PUBLISH" && $parentPage ]]
    then
        echo "WILL PUBLISH under page: $parentPage"


        response=`curl -s -S -H "Authorization: Basic $SECRET" -X POST -H 'Content-Type: application/json' -d"@publishTemplate.json" https://confluence.example.com/confluence/rest/api/content/`


        pageId=`echo $response | python -c 'import sys, json; print json.load(sys.stdin)[sys.argv[1]]' id`

        if [ $pageId ]
        then
            #labels
            labels="jiraR"
            labelPost="[$( echo $labels | sed 's/\([^,]*\)/{"prefix": "global", "name":"\1"}/g')]"
            curl -s -S -H "Authorization: Basic $SECRET" -X POST -H 'Content-Type: application/json' -d"$labelPost" https://confluence.example.com/confluence/rest/api/content/$pageId/label

        fi

    else
        echo "Not set to publish, or parent page is not set... $SQUAD parent is: $parentPage"
    fi

else

    echo "Report not found so cannot publish jiraReport/jiraR-$SQUAD.html"
    exit 1
fi
