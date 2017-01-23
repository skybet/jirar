var assert = require('assert');

var issueScraper = require("../issueScrape");

describe("singleIssue", function() { 
    var sampleIssue = require('./singleIssue-TS-1020');
    it("works", function() { assert(true); })

    it("test data has a title", function() { 
        assert.equal("Investigation into Double Price update messages", sampleIssue.fields.summary);
    });

    describe("extractIssueData", function() { 
        it("works on a single issue with two columns - uncompleted", function() { 
            var res = issueScraper.extractIssueData(sampleIssue);
            var exp = {
                key: "TS-1020", 
                summary: "Investigation into Double Price update messages",
                created: "2016-12-05T13:37:16.000+0000",
                resolution: null,
                resolutionDate: null,
                workType: "Bet Tribe Roadmap",
                secondsInColumns: { 
                    "Open": 1582000,
                    "3 Amigos In": 1280870000
                }
            }
            assert.deepEqual(res, exp);
        });
    });
});
