#!/usr/bin/env bash

set -e

SECRET=$1
SQUAD=$2
PUBLISH=$3

DATE=`date "+%y/%m/%d %M"`
if [ -f jiraR-$SQUAD.html ]
then


parentPage=

if [[ "$SQUAD" == "TS" || "$SQUAD" == "PE" || "$SQUAD" == "TSI" ]]
then 
    parentPage=26676200
fi

if [[ "$SQUAD" == "VBS" || "$SQUAD" == "HRS" || "$SQUAD" == "NGU" || "$SQUAD" == "SBP" ]]
then 
    parentPage=
fi

if [[ "$SQUAD" == "BCT" ]]
then 
    parentPage=
fi

printf '{\"type\":\"page\",\"title\":\"' > publishTemplate.json
printf "$SQUAD JiraR stats $DATE" >> publishTemplate.json
printf '\", \"ancestors\":[{\"id\":' >> publishTemplate.json
printf "$parentPage" >> publishTemplate.json
printf '}], \"space\":{\"key\":\"TBT\"},\"body\":{\"storage\":{\"value\":\"<ac:structured-macro ac:name=\\"html\\"><ac:plain-text-body><![CDATA[<div>' >> publishTemplate.json
sed 's/"/\\"/g' jiraR-$SQUAD.html >> publishTemplate.json
printf '</div>]]></ac:plain-text-body></ac:structured-macro>\",\"representation\":\"storage\"}}}' >> publishTemplate.json


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

    fi

else

    echo "Report not found so cannot publish jiraR-$SQUAD.html"
    exit 1
fi
