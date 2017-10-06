var assert = require("assert");

var issueScraper = require("../issueScrape");



describe("customFields 1", function() {
var customFields = {
    spend: {type: 'list', field: 'customfield_11701' },
    workType: { type: 'value', field: 'customfield_10905' },
    epicLink: { type: 'basic', field: 'customfield_10103' }
}

    describe('epicLink, workType', function() {
        var sampleIssue = require('./singleIssue-TS-1020');

        it("has the expected results", function() {
            var returnedFields = issueScraper.extractCustomFields(customFields, sampleIssue);
            var expectedFields = { epicLink: "TS-1019", spend: null, workType: "Bet Tribe Roadmap"};
            assert.deepEqual(returnedFields, expectedFields);
        });
    });

    describe('epicLink', function() {
        var sampleIssue = require('./singleIssue-VBS-327');

        it("has the expected results", function() {
            var returnedFields = issueScraper.extractCustomFields(customFields, sampleIssue);
            var expectedFields = { epicLink: "VBS-247", spend: null, workType: null};
            assert.deepEqual(returnedFields, expectedFields);
        });
    });
    describe('spend, workType', function() {
        var sampleIssue = require('./singleIssue-TS-1088');

        it("has the expected results", function() {
            var returnedFields = issueScraper.extractCustomFields(customFields, sampleIssue);
            var expectedFields = { epicLink: null, spend: "CAPEX", workType: "Bet Tribe Roadmap"};
            assert.deepEqual(returnedFields, expectedFields);
        });
    });

});
