<h1 align="center" style="font-size: 36px">RoutingKit</h1>

<p align="center">
  <a href="https://pub.dev/packages/routingkit"><img alt="Pub Version" src="https://img.shields.io/pub/v/routingkit?logo=dart"/></a>
  <a href="https://github.com/medz/routingkit/actions/workflows/test.yml"><img alt="Test" src="https://github.com/medz/routingkit/actions/workflows/test.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/medz/routingkit?tab=MIT-1-ov-file"><img alt="License" src="https://img.shields.io/github/license/medz/routingkit" /></a>
  <a href="https://github.com/sponsors/medz"><img alt="Sponsors" src="https://img.shields.io/github/sponsors/medz?logo=githubsponsors" /></a>
  <a href="https://twitter.com/shiweidu"><img alt="X (formerly Twitter) Follow" src="https://img.shields.io/twitter/follow/shiweidu" /></a>
</p>

<p align="center">
Routing Kit - Lightweight and fast router for Dart.
</p>

## Installation

Run this command:

```bash
dart pub add routingkit
```

With Flutter:

```bash
flutter pub add routingkit
```

## Usage

### Create a router instance and insert routes

```dart
import "routingkit";

final router = createRouter<String>();

router.add('get', '/path', 'Static path');
router.add('get', '/path/:name', 'Param route');
router.add('get', '/path/*', 'Unnamed param route');
router.add('get', '/path/**', 'Wildcard Route');
router.add('get', '/path/**:rest', 'Named wildcard route');
router.add('get', '/files/:dir/:filename.:format,v:version', 'Mixed Route');
```

### Match route to access matched data

```dart
// {data: Static path}
router.find('get', '/path')

// {data: Param route, params: {name: seven}}
router.find('get', '/path/seven')

// {data: Wildcard Route, params: {_: foo/bar/baz}}
router.find('get', '/path/foo/bar/baz')

// {data: Mixed Route, params: {dir: dart, filename: pubspec, format: yaml, version: 1}}
router.find('get', '/files/dart/pubspec.yaml,v1')

// `null`, No match.
router.find('get', '/')
```

## License

RoutingKit is open-sourced software licensed under the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file).
