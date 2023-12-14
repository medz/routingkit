<h1 align="center" style="font-size: 36px">RoutingKit</h1>

<p align="center">
  <a href="https://pub.dev/packages/routingkit"><img alt="Pub Version" src="https://img.shields.io/pub/v/routingkit?logo=dart"/></a>
  <a href="https://github.com/medz/routingkit/actions/workflows/test.yml"><img alt="Test" src="https://github.com/medz/routingkit/actions/workflows/test.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/medz/routingkit/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/medz/routingkit" /></a>
  <a href="https://github.com/sponsors/medz"><img alt="Sponsors" src="https://img.shields.io/github/sponsors/medz?logo=githubsponsors" /></a>
  <a href="https://twitter.com/shiweidu"><img alt="X (formerly Twitter) Follow" src="https://img.shields.io/twitter/follow/shiweidu" /></a>
</p>

<p align="center">
Routing Kit is a High-performance trie-node router.
</p>

## Installation

Install via command line:

```bash
# Dart Project
$ dart pub add routingkit

# Flutter
$ flutter pub add routingkit
```

Install via `pubspec.yaml` file:

```yaml
dependencies:
  routingkit: any
```

## Methods

- `register`: 注册路由
- `lookup`: 查找路由

- `register`: Register a value to a route
- `lookup`: Returns a value for a route

### Register

To register a value to a route, you need to provide a `path` and a `value`.

```dart
router.register(0, '/a/b/c'.toPathComponents());
// Or
router.register(1, [PathComponent('a'), PathComponent('b'), PathComponent('c')]);
```

### Lookup

To lookup a route, you need to provide a `path`, it will return a value of type `T?`.

```dart
final parameters = Parameters();

router.lookup('/a/b/c'.splitWithSlash(), parameters);
// Or
router.lookup(['a', 'b', 'c'], parameters);
```

## Path component

Each route registration method requires a `path`, which is a value of type `Iterable<PathComponent>`:

- `PathComponent.constant`: Used to register constant routes (`foo`)
- `PathComponent.parameter`: Used to register parameter routes (`:foo`)
- `PathComponent.anything`: Used to register wildcard routes (`*`)
- `PathComponent.catchAll`: Used to register catch-all routes (`**`)

### Constant

It is a static path component, which only allows a request string with a complete match to be registered at this location:

```dart
// represents the path `/foo/bar`
router.register(0, [PathComponent.constant('foo'), PathComponent.constant('bar')]);
```

### Parameter

This is a parameter path component, which allows any request string to be registered at this location. Parameter path components are specified with the `:` prefix, and the following string is used as the parameter name.

You can get the parameter value from the `Parameters` object after the route is matched:

```dart
// represents the path `/foo/:bar`
router.register(0, [PathComponent.constant('foo'), PathComponent.parameter('bar')]);

final parameters = Parameters();

router.lookup('/foo/123'.splitWithSlash(), parameters);

print(parameters.get('bar')); // 123
```

#### Anything

It is similar to Parameter, but it allows any request string to be registered at this location. However, it does not store the parameter value in the `Parameters` object.

```dart
// represents the path `/foo/*`
router.register(0, [PathComponent.constant('foo'), PathComponent.anything()]);

// or
router.register(0, '/foo/*'.toPathComponents());
```

#### Catch-all

It is similar to Anything, but it allows any request string to be registered at this location. However, Anyting only matches one path segment, while Catch-all matches all remaining path segments.

```dart
// represents the path `/foo/**`
router.register(0, [PathComponent.constant('foo'), PathComponent.catchAll()]);

// or
router.register(0, '/foo/**'.toPathComponents());
```

## Case sensitivity routing

By default, Routing Kit is case-insensitive, but you can control whether it is case-sensitive through the `caseSensitive` parameter.

```dart
final router = TrieRouter(
    options: ConfigurationOptions(caseSensitive: true),
);
```

## License

Routing Kit is licensed under the MIT license. See the [LICENSE](https://github.com/medz/routingkit/blob/main/LICENSE) file for more info.
