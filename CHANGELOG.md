## 5.1.1

### Documentation

- Improved pubspec.yaml with more descriptive information and optimized topics

## 5.1.0

### New Features

- Added `caseSensitive` parameter to `createRouter` function to configure case sensitivity for path matching (defaults to `true`)
- Added `caseSensitive` property to the `Router` interface to indicate the router's case sensitivity setting
- Parameter names (like `:ID`) maintain their original case even in case-insensitive mode

## 5.0.1

### Bug Fixes

- Fixed duplicated results in `findAll` method by implementing a deduplication mechanism
- Added configurable `anyMethodToken` parameter to `createRouter` function with a default value of 'routerkit-method://any'
- Enhanced wildcard and parameter matching with more reliable route priority handling

## 5.0.0

### Breaking Changes

- Complete API restructuring from functional to object-oriented style
- Core operations are now methods of the Router class instead of standalone functions
- Removed exported operation functions such as addRoute, findRoute, etc.

### New Features

- Introduced Router class as the main entry point
- Provided a more concise chainable API
- Optimized internal implementation with clearer code structure

### Migration Guide

Migrating from v4.x to v5.0.0:

```diff
import 'package:routingkit/routingkit.dart';

- const router = createRouter();
+ final router = createRouter<String>();

- addRoute(router, 'get', '/path', 'data');
+ router.add('get', '/path', 'data');

- findRoute(router, 'get', '/path');
+ router.find('get', '/path');

- findAllRoutes(router, 'get', '/path');
+ router.findAll('get', '/path');

- removeRoute(router, 'get', '/path');
+ router.remove('get', '/path');
```

## 4.1.1

- **fix**: fix: remove named wildcard routes
- **chrome**: bump lints from 4.0.0 to 5.1.0

## v4.1.0

- **feat**: Support nullable method.

## v4.0.0

[compare changes](https://github.com/medz/routingkit/compare/v3.0.3...v4.0.0)

### 🩹 Fixes

- Find all ([7d1e06b](https://github.com/medz/routingkit/commit/7d1e06b))

### 💅 Refactors

- Done ([245ff49](https://github.com/medz/routingkit/commit/245ff49))

### ✅ Tests

- - ([1fbcb5c](https://github.com/medz/routingkit/commit/1fbcb5c))

### ❤️ Contributors

- Seven Du <shiweidu@outlook.com>
