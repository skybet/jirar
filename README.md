#Summary

#Usage

1. get Jira Access Token
2. Run issue scraper
3. Run R Script within RStudio

e.g.
```
echo -n Username:Password | base64
node issueScrape.js <JIRAACCESSTOKEN> <PROJECT>
node issueScrape.js <randombase64hash> TS
```
