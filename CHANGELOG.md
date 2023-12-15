## 0.1.0

- Fixed `CatchAll` to `Catchall` correctly
- Removed unused logger from `Parameters` class
- Changed `toPathComponentsString` helper method to `path` getter
- Changed `toPathComponents` method to `pathComponents` getter
- Added `pathComponent` getter to `String` type
- Changed assertion to throw `ArgumentError` when catchall path segment is not the last one
- Changed Dart SDK version constraint from `^3.2.3` to `>=3.0.0 <3.3.0`
