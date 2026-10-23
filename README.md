# usage-swift

the usage pieces usaaage and swaaap share. by laaabs.

## what

a swift package (module `UsaaageKit`) with the pieces both apps draw the same way: the window meter, the plan badge, the status dot, the account row and card, the client marks, the formats and the menu bar glyph. usaaage and swaaap pin it by revision; it ships nothing on its own. the map entry is `usage-swift` in `map/map/services.yaml`.

## build it

```sh
git clone https://github.com/bylaaabs/usage-swift.git && cd usage-swift
git submodule update --init
swift build
swift test
```

requires macOS 27 and xcode 27; LaaabsKit (bylaaabs/ui-swift) is fetched by swift package manager.

## layout

- `Sources/UsaaageKit/` - the pieces and the client marks.
- `Tests/UsaaageKitTests/` - the tests.
- `map/` - the map, as a submodule.
- `service.yaml` - what this repo is; checked against the map.

## status

building. it moved here from usaaage's `mac/UsaaageKit` on 2026-10-23; next, the pieces swaaap needs too (the bell, the strip's figure, the reading line).
