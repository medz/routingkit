<h1 align="center" style="font-size: 36px">RoutingKit</h1>

<p align="center">
  <a href="https://pub.dev/packages/routingkit"><img alt="Pub Version" src="https://img.shields.io/pub/v/routingkit?logo=dart"/></a>
  <a href="https://github.com/medz/routingkit/actions/workflows/test.yml"><img alt="Test" src="https://github.com/medz/routingkit/actions/workflows/test.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/medz/routingkit?tab=MIT-1-ov-file"><img alt="License" src="https://img.shields.io/github/license/medz/routingkit" /></a>
  <a href="https://github.com/sponsors/medz"><img alt="Sponsors" src="https://img.shields.io/github/sponsors/medz?logo=githubsponsors" /></a>
  <a href="https://twitter.com/shiweidu"><img alt="X (formerly Twitter) Follow" src="https://img.shields.io/twitter/follow/shiweidu" /></a>
</p>

<p align="center">
Routing Kit - router abstractions and built-in high-performance Radix-Trie router driver.
</p>

- **High-performance**：Based on [Radix Tree](https://en.wikipedia.org/wiki/Radix_tree) implementation, efficient performance.
- **Accurate**：Using `/` to split trie-node nodes can accurately match routes.
- **Flexible**：Support dynamic routing matching

## Installation

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  routingkit: ^1.0.0
```

Or install it with `pub`:

```bash
dart pub add routingkit
# or
flutter pub add routingkit
```

## Sponsor RoutingKit

RoutingKit is an open source project based on the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file). If your Router implementation uses RoutingKit, or you find my work helpful to you, please sponsor me on [GitHub Sponsors](https://github.com/sponsors/medz). Your support is my biggest motivation.

## Getting Started

RoutingKit improves the performance of route matching and provides a simpler API. Here is a simple example:

```dart
import 'package:routingkit/routingkit.dart';

void main() {
    final router = createRouter(routes: {
        '/users/:name': 0,
    });

    final result = router.lookup('/users/seven');
    print('User name: ${result?.params('name')}'); // seven
    print('Matched user value: ${result?.value}'); // 0
}
```

### Create a router instance and register routes

```dart
final router = createRouter();

router.register('/path', 'static route'); // matches `/path`
router.register('/path/:name', 'named route'); // matches `/path/:name<any>`
router.register('/path/foo/*', 'unnamed route'); // matches `/path/foo/<any>`
router.register('/path/bar/**', 'catchall route'); // matches `/path/bar/<any>`
```

### Route Path Segment

- `<segment>`: Constant segment, for example `foo` only match `foo` string.
- `:name`: Param named segment, define a param name, match and store to `Params`.
- `*`: Unnamed segment, Similar to route naming segemnt, but does not store parameters in `Params`.
- `**`: Catchall segment, any segments are matched.

## The `Router` Methods

### `router.lookup(Srring path)

Returns a `Result<T>?` record, where Params stores all matched parameters and `T?` store value. If `T` is `null`, it means no correct match.

### `router.register(String route, T value)`

Register a route and store a value.

### `router.remove(String route)`

Remove a registered route.

## License

RoutingKit is open-sourced software licensed under the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file).
