# NFL Live for Rokid AIUI

NFL Live is a glanceable, read-only American football agent for Rokid AIUI 0.17. It shows current scores, the upcoming schedule, AFC/NFC standings, and quarter-by-quarter detail. English is the default interface; Japanese, Korean, and Simplified Chinese are available in Settings.

The cover follows the compact black-and-green composition of [Pong's splash reference](https://raw.githubusercontent.com/nickustinov/paddle-even-g2/main/screenshot-splash.png): tap to start or wait five seconds for automatic entry.

## Data

The app uses ESPN's public JSON feeds without an API key:

- Scoreboard and schedule: `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard`
- Standings: `https://site.api.espn.com/apis/v2/sports/football/nfl/standings`

During live games the scoreboard refreshes every 30 seconds. A failed request preserves the last successful snapshot and exposes Retry. ESPN may change or rate-limit these unofficial public feeds.

## Studio import

Repository: `https://github.com/BreezeLife/AIUI-NFLLive`  
Ref: `main`  
AIUI project directory: `/`  
Target: AIUI 0.17.0; Pages support `_blank` and compact `_current` layouts.

## Local checks

```bash
npm test
npm run validate
npm run pack
```

The AIX artifact is written to `artifacts/nfl-live-en-ja-ko-zh.aix`; its SHA-256 is next to it. AIX packaging is not platform publication. Review and physical-glasses testing still belong in AIUI Studio and the Rokid AI App.
