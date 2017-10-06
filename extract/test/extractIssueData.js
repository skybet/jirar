var assert = require('assert');

var issueScraper = require("../issueScrape");


var customFields = {
    spend: {type: 'list', field: 'customfield_11701' },
    workType: { type: 'value', field: 'customfield_10905' },
    epicLink: { type: 'basic', field: 'customfield_10103' }
}

describe("singleIssue", function() {
    var sampleIssue = require('./singleIssue-TS-1020');

    it("test data has a title", function() {
        assert.equal("Investigation into Double Price update messages", sampleIssue.fields.summary);
    });

    describe("extractIssueData", function() {
        it("works on a single issue with two columns - uncompleted", function() {
            var res = issueScraper.extractIssueData(customFields, sampleIssue);
            var exp = {
                key: "TS-1020",
                summary: "Investigation into Double Price update messages",
                created: "2016-12-05T13:37:16.000+0000",
                status: "3 Amigos Out",
                spend: null,
                resolution: null,
                resolutionDate: null,
                epicLink: "TS-1019",
                ticketType: "Spike",
                workType: "Bet Tribe Roadmap",
                secondsInColumns: {
                    "Open": 1582000,
                    "3 Amigos In": 1108070000
                }
            }
            assert.deepEqual(res, exp);
        });
    });
});
describe("singleIssue - Multiple Transitions", function() {
    var sampleIssue = require('./singleIssue-VBS-327');

    describe("extractIssueData", function() {
        it("works on a single issue with two columns - uncompleted", function() {
            var res = issueScraper.extractIssueData(customFields, sampleIssue);
            var exp = {
                key: "VBS-327",
                summary: "Update default Virtual Sports URLs",
                created: "2016-11-16T10:30:33.000+0000",
                resolutionDate: "2016-11-28T11:19:56.000+0000",
                status: "Done",
                spend: null,
                epicLink: "VBS-247",
                ticketType: "User Story",
                workType: null,
                secondsInColumns: {
                   "Backlog": 106698000,
                   "Code Review / Demo In": 8911000,
                   "Code Review / Demo Out": 73272000,
                   "Deploy": 87314000,
                   "Elaboration  Out": 3000,
                   "Elaboration In": 63259000,
                   "Implementation In": 17541000,
                   "Implementation Out": 173884000,
                   "Test In": 78452000,
                   "Test Out": 84829000
                }
            }
            delete res.resolution;
            assert.deepEqual(res, exp);
        });
    });
});
describe("spend", function() {
    var sampleIssue = require('./singleIssue-TS-1088');

    it("test data has spend", function() {
        var res = issueScraper.extractIssueData(customFields, sampleIssue);
        assert.equal("CAPEX", res.spend);
    });
});
