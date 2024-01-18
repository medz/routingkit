## 0.2.1

- Remove unused constants.
- `Catchall` path segment not in the last postion error message to be logger.

## 0.2.0

BREAKING CHANGE: Refactor all

## 0.1.2

- Rename `Iterable` extension `path` to `description`.

## 0.1.1

- Fixed path component `toString` method to return correct value

## 0.1.0

- Fixed `CatchAll` to `Catchall` correctly
- Removed unused logger from `Parameters` class
- Changed `toPathComponentsString` helper method to `path` getter
- Changed `toPathComponents` method to `pathComponents` getter
- Added `pathComponent` getter to `String` type
- Changed assertion to throw `ArgumentError` when catchall path segment is not the last one
- Changed Dart SDK version constraint from `^3.2.3` to `>=3.0.0 <3.3.0`
