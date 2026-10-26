# changelog

all notable changes to usage-swift are documented in this file.

the format is based on [keep a changelog](https://keepachangelog.com/en/1.1.0/). the package is pinned by revision, so there are no releases; entries say what changed for the apps.

## [unreleased]

### added

- `NoticeBell` and `NoticeLine`, moved from usaaage's panel unchanged in look: the bell with the unseen badge (9+ past nine) and a notice in one line, the body on hover, with an optional action in cyan (swaaap's "sign in"), so swaaap's panel draws the same ones (#3).
- the strip at the top of a dashboard, moved from usaaage's dashboard unchanged in look: `FigureStrip`, `StripFigure`, `StripDivider`, `FigureValue` and `FigureCaption`, so swaaap's dashboard draws its figures the same way (#3).
- the package, moved from usaaage's `mac/UsaaageKit` (usaaage main d73016c) byte for byte: the window meter, the plan badge, the status dot, the in use treatment, the refresh button, the account row and card, the client marks, the formats and the menu bar glyph, with their tests (#1).
### changed

- ui-swift at `e2477a8`, whose brand has swaaap's draft wordmark; the apps pin the same (#5).

