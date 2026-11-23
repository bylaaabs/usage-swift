# AGENTS.md

guidance for any agent, or human, working in this repository. the studio-wide rules live in the handbook (bylaaabs/handbook); this file is what applies here.

## laaabs.

three people in madrid making native tools, in the open, with no telemetry. the studio is `laaabs.` (lowercase, with the dot when it stands alone). products are lowercase too and are never typed in the web: baaar, haaarness, speaaak, islaaand, clipboaaard, terminaaal.

## rules of the house

- everything lowercase; english only; never an em dash or an en dash, use " - ".
- platforms in this order: macOS, windows, iOS / iPadOS, android.
- rust for cores and services, typescript for web front ends, swift / kotlin / winui only as the native layer on a rust core.
- one repo per product, all its platforms inside; services in their own repo.
- every piece of work has an issue; branches are `<type>/<slug>`; conventional commits; pull requests only, never a push to main; never merge without being asked.
- the map of everything (bylaaabs/map) is private and is not a submodule here: this repo is public. `service.yaml` at the root describes this repo; keep it in step with the map by hand.
- `CLAUDE.md` is just `@AGENTS.md`. edit this file, not that one.

## this repository

`usage-swift` is the swift package usaaage and swaaap share, so the two apps read as one family: the window meter, the plan badge, the status dot, the in use treatment, the refresh button, the account row and card, the client marks, the formats and the menu bar glyph. it ships nothing on its own: usaaage (bylaaabs/usaaage) pins it by revision in its `mac/project.yml`, and swaaap (bylaaabs/swaaap) will, in the next step of the design. the module is `UsaaageKit`, the name it had inside usaaage.

## layout

- `Sources/UsaaageKit/` - the pieces, view values only: each app maps its own model into them (`KitWindow`, `KitClient` and the like). `Resources/clients/` holds the client marks (cc0 svg data, see its readme).
- `Tests/UsaaageKitTests/` - the formats and the glyph.
- `service.yaml` - what this repo is; kept in step with bylaaabs/map by hand.

## conventions

- built only from the kit's tokens (LaaabsKit, bylaaabs/ui-swift), pinned at the same revision as usaaage's and swaaap's `project.yml`; bump all three together.
- the look follows usaaage's `design/DESIGN-SYSTEM.md`: only cyan and amber, the white ladder.
- a change here reaches two apps: build usaaage and swaaap against the branch before asking for a merge, and show their screens before and after in the pull request.
- the apps must be on the same revision of this package at a release; between releases one may run ahead.
- swift 6 language mode, macOS 27.
- github actions has no minutes in the org: run the checks below locally and list them in the pull request.

## commands

- `swift build` - build.
- `swift test` - test.

## read before changing things

- the handbook (bylaaabs/handbook): engineering.
- usaaage's `design/DESIGN-SYSTEM.md`, and the design for the two apps as one family: `docs/superpowers/specs/2026-10-22-usage-family-design.md` in bylaaabs/swaaap.
