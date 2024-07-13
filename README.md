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
import from "routingkit";

const router = createRouter();

addRoute(router, "GET", "/path", 'this path');
addRoute(router, "POST", "/path/:name", 'named route');
addRoute(router, "GET", "/path/foo/**", 'wildcard route');
addRoute(router, "GET", "/path/foo/**:name", 'named wildcard route');
```

### Match route to access matched data

```dart
// Returns [{data: 'This path'}]
findRoute(router, "GET", "/path");

// Returns [{ data: 'named route', params: { name: 'fooval' } }]
findRoute(router, "POST", "/path/fooval");

// Returns [{ data: 'wildcard route' }]
findRoute(router, "GET", "/path/foo/bar/baz");

// Returns undefined (no route matched for/)
findRoute(router, "GET", "/");
```

## License

RoutingKit is open-sourced software licensed under the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file).
