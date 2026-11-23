# usage-swift

the usage pieces usaaage and swaaap share. by laaabs.

## what

a swift package (module `UsaaageKit`) with the pieces both apps draw the same way: the window meter, the plan badge, the status dot, the account row and card, the client marks, the notice bell and line, the dashboard strip, the formats and the menu bar glyph. it runs nowhere on its own. issues: github.com/bylaaabs/usage-swift/issues; the map entry is `usage-swift` in `map/map/services.yaml`.

## run it

```sh
git clone https://github.com/bylaaabs/usage-swift.git && cd usage-swift
git submodule update --init
swift build
swift test
```

requires macOS 27 and xcode 27; LaaabsKit (bylaaabs/ui-swift) is fetched by swift package manager.

## build and ship

- `swift build` - the package.
- `swift test` - the tests.
- ships by being pinned: usaaage and swaaap take it by revision in `mac/project.yml`; there are no releases.

## layout

- `Sources/UsaaageKit/` - the pieces and the client marks.
- `Tests/UsaaageKitTests/` - the tests.
- `service.yaml` - what this repo is.

## status

building. it moved here from usaaage's `mac/UsaaageKit` on 2026-10-23, and both apps use it. the notice bell and line and the dashboard strip came next, for swaaap's panel and dashboard.

## licence

[apache license 2.0](LICENSE) for the code. the laaabs. marks and the marks of the clients are not covered by it: see [LICENSE](LICENSE).
