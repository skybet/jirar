var request = require('request');
var async = require('async');
var moment = require("moment");
require("moment-duration-format");

var json2csv = require("json2csv");
var fs = require('fs');


function getTransitions(bootstrap, next) {
    var project = bootstrap.bootstrap.project;
    var jiraApi = bootstrap.bootstrap.jiraApi;
    var authHeader = bootstrap.bootstrap.authHeader;

    // https://jira.example.com/jira/rest/api/2/issue/TS-1020/transitions
    console.log("Requesting transitions for project: " + project);
    var req = request({
        baseUrl: jiraApi,
        uri: "issue/" + project + "-1/transitions",
        headers: {
            "Content-Type": "application/json",
            "Authorization": authHeader
        },
        json: true
    }, function(err, res, body) {
        if (err) { console.log("ERR"); console.log(err); return next(err); }
        console.log("Got %s response from jira @ %j", res.statusCode, req.uri.href);
        var unOrderedProjectCategories = body.transitions.map(function(cat) {
            return cat.name;
        });

        var orderedIndexes = [4,5, 9,10,11,12,13,14, 28,29, 15,16, 19,20, 17,18, 21,22, 23,24, 25,26, 33, 30,31, 27,32,   6,7,8];

        projectCategories = orderedIndexes.map(function(i) {
            return unOrderedProjectCategories[i - 4];
        });

        return next(err, projectCategories);

    })
}

function getNumberOfTickets(bootstrap, next) {
    var project = bootstrap.bootstrap.project;
    var jiraApi = bootstrap.bootstrap.jiraApi;
    var authHeader = bootstrap.bootstrap.authHeader;

    console.log("Requesting number of tickets in project: " + project);
    var req = request({
        baseUrl: jiraApi,
        uri: "search?jql=project=" + project + "&maxResults=1&startAt=0",
        headers: {
            "Content-Type": "application/json",
            "Authorization": authHeader
        },
        json: true
    }, function(err, res, body) {
        if (err) { console.log("ERR"); console.log(err); return next(err); }
        console.log("Got %s response from jira @ %j", res.statusCode, req.uri.href);

        return next(err, body.total);
        })
}

function getIssues(bootstrap, next) {
    var project = bootstrap.bootstrap.project;
    var jiraApi = bootstrap.bootstrap.jiraApi;
    var authHeader = bootstrap.bootstrap.authHeader;
    var totalTickets = bootstrap.getNumberOfTickets;

    console.log("Requesting %s tickets in project: %s", totalTickets, project);

    var bucketSize = 100;
    var numBuckets = Math.ceil(totalTickets / bucketSize);

    async.timesLimit(numBuckets, 10, getIssuesBucket, function(err, data) {
        // Flatten the returned array
        return next(err, [].concat.apply([], data))
    });


    function getIssuesBucket(bucketNum, nextBucket) {
        var bucketOffset = bucketNum*bucketSize;
        console.log("Requesting bucket %s of %s tickets in project: %s", bucketNum, bucketSize, project);
        var req = request({
            baseUrl: jiraApi,
            uri: "search?jql=project=" + project + "&expand=changelog&maxResults=" + bucketSize + "&startAt=" + bucketOffset,
            headers: {
                "Content-Type": "application/json",
                "Authorization": authHeader
            },
            json: true
        }, function(err, res, body) {
            if (err) { console.log("ERR"); console.log(err); return nextBucket(err); }
            console.log("Got %s response from jira @ %j", res.statusCode, req.uri.href);
//console.log(body);

            var issueData = body.issues.map(extractIssueData);
            return nextBucket(err, issueData);
        });
    };

};

function writeCSVOutput(bootstrap, next) {

    var ticketKeys = bootstrap.getIssues.map(function(ticket) { return ticket.key; });
    var ticketKeySet = new Set(ticketKeys);
    if (ticketKeySet.size != ticketKeys.length) {
        console.log("WARN");
        console.log("getIssues returned %i tickets", ticketKeys.length);
        console.log("unique tickets were %i tickets", ticketKeySet.size);
    };

//console.log(issueData[0]);
    var fields = ["key", "summary", "created", "resolution", "resolutionDate", "workType"];

    var fields = fields.concat(bootstrap.getTransitions.map(function(k) {
        //if (k == "previousTime") return null;
        return "secondsInColumns."+k })
    );
    var fields = fields.filter(function(f) { return f });

    writeCSV(bootstrap.getIssues, fields, next)
};


function extractIssueData(issue) {

    var change = issue.changelog.histories

    var firstCreated = issue.fields.created;
    var workType = null;
    if (issue.fields.customfield_10905) { 
        workType = issue.fields.customfield_10905.value;
    }
    var timeInColumns = change.filter(function(changeHist) {

//WARNING Filter modifies changeHist.items
        changeHist.items = changeHist.items.filter(function(chi) {
           return chi.field == "status";
        });

        return changeHist.items.length == 1 && changeHist.items[0].field == 'status';
    }).reduce(function(timeInColumns, changeHist) {
        if (changeHist.items.length > 1) {
            console.log("WARN");
            console.log("changelog.items has more than one item:");
            console.log(changeHist.items);
        }

        var oldColumn = changeHist.items[0].fromString;
        var newDate = moment(changeHist.created);
        var prevDate = moment(timeInColumns.previousTime);

        var nonWorking = 0;
        if (newDate.weeks() > prevDate.weeks()) { 
            //console.log(oldColumn + " over a weekend");
            nonWorking = 2*24*60*60*1000 ;
        };

        timeInColumns[oldColumn] = timeInColumns[oldColumn] || 0;
        timeInColumns[oldColumn] += (newDate - prevDate - nonWorking);

        timeInColumns.previousTime = changeHist.created;
        return timeInColumns;
    },
    //Initialise reduce with the firstCreated time
    {"previousTime": firstCreated}
    )

//Do we want csv to include a pretty printed time? probably not
//    var formatTimeInColumns = JSON.parse(JSON.stringify(timeInColumns));
//    delete formatTimeInColumns.previousTime;
//    Object.keys(formatTimeInColumns).map(function(key, index) {
//       formatTimeInColumns[key] = moment.duration(formatTimeInColumns[key], "milliseconds").format("dd[d] hh:mm:ss", {trim: false});
//    });

    delete timeInColumns.previousTime

process.stdout.write(".");

    return {
        key: issue.key,
        summary: issue.fields.summary,
        resolution: issue.fields.resolution,
        resolutionDate: issue.fields.resolutiondate,
        created: firstCreated,
        secondsInColumns: timeInColumns,
        //timeInColumns: formatTimeInColumns
        workType: workType
    }
};


var writeCSV = function writeCSV(finalCSV, fields, next) {
    console.log("Writing csv file...");
    json2csv({ data: finalCSV, fields: fields}, function(err, csv) {
      if (err) { console.log(err); return next(err); }
      fs.writeFile('jiraRDataset.csv', csv + "\n", function(err) {
        if (err) { console.log(err); }
        console.log("Wrote csv");
        return next(err);
      });
    });
}

async.auto({
    "bootstrap": function(next) {
        bootstrap = {
            project: process.argv[3],
            jiraApi: "https://jira.example.com/jira/rest/api/2/",
            authHeader: "Basic "+ process.argv[2]
        };
        return next(null, bootstrap);
    },
    "getTransitions": ["bootstrap", getTransitions],
    "getNumberOfTickets": ["bootstrap", getNumberOfTickets],
    "getIssues": ["getNumberOfTickets", getIssues],

    "writeCSVOutput": ["getTransitions", "getIssues", writeCSVOutput],

}, function(err, results) {
    console.log('err = ', err);
});

module.exports = {
    extractIssueData: extractIssueData
}
