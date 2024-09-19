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
/// - [RouterContext]: The main router instance
/// - [addRoute]: Add new routes to the router
/// - [findRoute]: Find a single matching route
/// - [findAllRoutes]: Find all matching routes
/// - [removeRoute]: Remove a route from the router
///
/// ![Pub version](https://img.shields.io/pub/v/routingkit?logo=dart)
library routingkit;

export 'src/types.dart';
export 'src/context.dart';

export 'src/operations/add_route.dart';
export 'src/operations/find_all_routes.dart';
export 'src/operations/find_route.dart';
export 'src/operations/remove_route.dart';
