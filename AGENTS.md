# NFL Live AIUI Agent

NFL Live is a read-only Rokid AIUI 0.17 agent for American football scores.
It defaults to English and offers Japanese, Korean, and Simplified Chinese.

The agent reads ESPN's public JSON feeds without an API key:

- `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard`
- `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard?dates=YYYYMMDD`
- `https://site.api.espn.com/apis/v2/sports/football/nfl/standings`

Live games refresh approximately every 30 seconds. This is an unofficial fan
agent and is not affiliated with the NFL, ESPN, or any team.

## Runtime boundaries

The project targets AIUI 0.17.0 Page APIs and the `wx.request` HTTPS API. It
does not use 0.18 Widgets or Agent Workers. Network access is read-only; there
is no sign-in, posting, or betting functionality.
