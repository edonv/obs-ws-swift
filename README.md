#  obs-ws-swift

Spiritual successor to `OBSwiftSocket`.

## Usage

### Regenerating Typings

1. `cd` into package directory.
2. Run `swift package generate`.

## To-Do's

- [ ] Figure out coding for MsgPack
    - there's an issue when decoding from data and a value is a string
- [x] Add generated section that makes enums of all enums, requests, and events
    - [x] Add to shared protocols that they must have a static property with that type.
    - [x] Maybe also generated functions that convert a generic message to a typed message
    - [x] Once done, reference type for `OBS.OpData.Event` and `Request`.
- [x] Maybe move `Protocols` into new `Protocols` folder and split protocols into separate files?
    - Stash changes first or something
