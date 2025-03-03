/// RoutingKit: A lightweight and high-performance routing library for Dart.
///
/// This library provides a flexible and efficient routing system, ideal for
/// both web and command-line applications. It offers:
///
/// - Fast route matching and parameter extraction
/// - Support for static, parameterized, and wildcard routes
/// - Efficient memory usage through a trie-based route storage
/// - Type-safe route handlers
///
/// Key components:
/// - [Router]: The main router class for managing routes
/// - [createRouter]: Creates a new router instance
///
/// Example usage:
/// ```dart
/// final router = createRouter<String>();
/// router.add('GET', '/path', 'static route');
/// router.add('POST', '/path/:name', 'name route');
/// print(router.find('GET', '/path')); // => {data: static route}
/// ```
///
/// ![Pub version](https://img.shields.io/pub/v/routingkit?logo=dart)
library routingkit;

export 'src/router.dart';
export 'src/types.dart' show MatchedRoute;
