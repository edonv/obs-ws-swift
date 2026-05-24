#  obs-ws-swift

Spiritual successor to `OBSwiftSocket`.

## Usage

### Regenerating Typings

1. `cd` into package directory.
2. Run `swift package generate`.

## To-Do's

- [ ] Add generated section that makes enums of all enums, requests, and events
    - [ ] Add to shared protocols that they must have a static property with that type.
    - [ ] Maybe also generated functions that convert a generic message to a typed message
    - [ ] Once done, reference type for `OBSOpData.Event` and `Request`.
- [ ] Maybe move `Protocols` into new `Protocols` folder and split protocols into separate files?
    - Stash changes first or something
