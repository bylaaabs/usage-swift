# usage-swift repo implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** the swift package usaaage and swaaap share (`UsaaageKit`) lives in its own private repo, `bylaaabs/usage-swift`, and usaaage takes it from there by url at a pinned revision, with nothing visible changing.

**Architecture:** three pull requests in order, each merged by Marco before the next is final, because the org merges by squash (a revision pinned on a branch dies with the branch): (1) bylaaabs/map gets the `usage-swift` entry; (2) usage-swift gets the package exactly as in `usaaage/mac/UsaaageKit` at usaaage main d73016c, plus the house files; (3) usaaage pins it by url and deletes its copy. the package keeps its name and module, `UsaaageKit`.

**Tech Stack:** swift 6.2 package (macOS 27), xcodegen, gh.

**Spec:** `swaaap/docs/superpowers/specs/2026-10-22-usage-family-design.md` (#48), decision 1 and part 1. moving more pieces into the kit happens in the step that first needs them, not here.

## Global Constraints

- house rules (map `templates/AGENTS.md`): lowercase, english, no em or en dashes, an issue per piece of work, `<type>/<slug>` branches, conventional commits, pull requests only, never merge without Marco's yes.
- the repo is **private** (Marco, 2026-10-23), like usaaage, swaaap, ui-swift and map.
- the package is copied byte for byte from usaaage main d73016c `mac/UsaaageKit` (sources, the client svgs with their cc0 readme, the tests); its LaaabsKit pin stays `094de0f9ecd14c28edd3ccd9f44d7dd14246146f`.
- actions has no minutes: every check runs locally and each pull request lists it.
- usaaage looks the same before and after: demo screenshots of the dashboard, the panel and settings, compared.

## Review Focus

- `swift build` and `swift test` of the package outside usaaage, from a clean clone (private LaaabsKit fetched with the local git credentials).
- the client svgs still load (`Bundle.module`): the marks show in the usaaage demo after the move.
- usaaage's scheme no longer runs the package tests; they run in usage-swift; nothing else in usaaage's build depended on the local path.
- the pinned revision in usaaage is a commit on usage-swift `main`, not on a branch.
- docs in usaaage that pointed at `mac/UsaaageKit` point at the repo.

---

### Task 1: the map entry

**Files:** bylaaabs/map `map/services.yaml` (after `ui-swift`).

- [ ] an issue in bylaaabs/map; branch `feat/usage-swift`; the entry: `name: usage-swift`, `hostname: null`, `repo: bylaaabs/usage-swift`, `kind: data`, `language: swift`, `runs_on: null`, `port: null`, `exposes: []`, `depends_on: [ui-swift]`, `used_by: [usaaage, swaaap]`, `data: []`, `owner: product`, `status: building`, `notes: the usage pieces usaaage and swaaap share (meters, dots, rows, cards, formats, the menu bar glyph), a swift package on the kit; module UsaaageKit.`
- [ ] map's own check passes (the script map uses on itself, if any); pull request. Marco merges.

### Task 2: the repo and the package

**Files:** new repo: `Package.swift`, `Sources/`, `Tests/`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `service.yaml`, `.github/workflows/service-check.yml`, `.gitignore`, `map` (submodule), `CHANGELOG.md`, `docs/superpowers/plans/` (this plan).

- [ ] `gh repo create bylaaabs/usage-swift --private --add-readme --description "the usage pieces usaaage and swaaap share. by laaabs."` (the initial commit is github's, as usaaage's was).
- [ ] issue "feat: the shared usage package, from usaaage"; branch `feat/bootstrap`; copy the package; `service.yaml` (`name: usage-swift`, `hostname: null`, `kind: data`, `language: swift`, `build: swift build && swift test`, `deploy: none, pinned by revision in usaaage and swaaap`, `runs_on: null`, `owner: product`); `AGENTS.md` from the template with this repo's paragraph, layout and the rule "a change here is checked in both apps: build usaaage and swaaap against the branch before asking for a merge"; `CLAUDE.md` = `@AGENTS.md`; `README.md` from the template; `map` at the commit with the entry.
- [ ] `swift build` and `swift test` green (output kept); `node map/scripts/check.mjs service.yaml` green once task 1 is merged.
- [ ] pull request; a fresh reviewer; Marco merges.

### Task 3: usaaage on the repo

**Files:** usaaage `mac/project.yml`, delete `mac/UsaaageKit/`, `mac/README.md`, `design/DESIGN-SYSTEM.md`, `CHANGELOG.md`.

- [ ] before screenshots (demo: dashboard, panel, settings) from usaaage main.
- [ ] issue; branch `build/usage-swift`; `project.yml`: `UsaaageKit: url: https://github.com/bylaaabs/usage-swift, revision: <usage-swift main after task 2>`; the scheme's `package: UsaaageKit/UsaaageKitTests` line goes; delete `mac/UsaaageKit/`; the docs say where the package lives; changelog line under changed.
- [ ] `CODE_SIGN_IDENTITY=- mac/scripts/build.sh --test` green; the rust checks unchanged and green; after screenshots identical to before.
- [ ] pull request with both sets of screenshots; a fresh reviewer; Marco merges; install on his mac.
