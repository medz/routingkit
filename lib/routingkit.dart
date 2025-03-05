/// RoutingKit is a lightweight, high-performance router for Dart.
///
/// This library provides flexible and efficient routing capabilities with support for:
/// - Static routes (/users)
/// - Parameter routes (/users/:id)
/// - Optional parameters (/files/:name?)
/// - Wildcard routes (/assets/**)
/// - Named wildcard segments (/docs/**:path)
/// - HTTP method-specific routing (GET, POST, etc.)
/// - Case sensitivity configuration
///
/// It's designed to be fast, flexible, and have a clean interface with
/// minimal dependencies, making it suitable for both web servers and client-side
/// applications.
library routingkit;

export 'src/create_router.dart';
export 'src/types.dart';
