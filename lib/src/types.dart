/// The Router interface defines the contract for router implementations.
///
/// The generic type [T] represents the type of data associated with each route.
/// This allows for type-safe route handlers such as functions, controllers,
/// or any other data type depending on your application needs.
///
/// Implementations of this interface typically use a trie-based structure
/// for efficient route matching.
abstract interface class Router<T> {
  /// Token used to represent any HTTP method.
  ///
  /// When a route is registered with a null or this token as its method,
  /// it will match any HTTP method during route matching.
  String get anyMethodToken;

  /// Whether path matching should be case-sensitive.
  ///
  /// When set to true (default), paths like '/users' and '/Users' are considered different.
  /// When set to false, case is ignored during matching.
  bool get caseSensitive;

  /// Finds the first route that matches the given [method] and [path].
  ///
  /// The [method] represents the HTTP method (e.g., 'GET', 'POST'), or null to use [anyMethodToken].
  /// The [path] is the URL path to match against routes.
  ///
  /// Returns a [MatchedRoute] if a matching route is found, otherwise null.
  MatchedRoute<T>? find(String? method, String path);

  /// Finds all routes that match the given [method] and [path].
  ///
  /// This is useful for middleware-style processing where multiple handlers might apply.
  /// The [method] represents the HTTP method (e.g., 'GET', 'POST'), or null to use [anyMethodToken].
  /// The [path] is the URL path to match against routes.
  ///
  /// Returns an iterable of [MatchedRoute] objects for all matching routes.
  Iterable<MatchedRoute<T>> findAll(String? method, String path);

  /// Adds a new route to the router.
  ///
  /// The [method] represents the HTTP method for the route, or null to use [anyMethodToken].
  /// The [path] defines the route pattern, which can include:
  /// - Static segments (/users)
  /// - Parameter segments (/users/:id)
  /// - Optional parameters (/files/:name?)
  /// - Wildcards (/assets/**)
  /// - Named wildcards (/docs/**:path)
  ///
  /// The [data] is the value associated with this route, of type [T].
  void add(String? method, String path, T data);

  /// Removes a route with the specified [method] and [path].
  ///
  /// The [method] represents the HTTP method of the route to remove, or null to use [anyMethodToken].
  /// The [path] is the exact route pattern to remove.
  void remove(String? method, String path);
}

/// Represents a matched route with associated data and extracted parameters.
///
/// The generic type [T] represents the type of data associated with the matched route.
class MatchedRoute<T> {
  /// Creates a new matched route with the given [data] and [params].
  ///
  /// The [data] is the value associated with the matched route, of type [T].
  /// The [params] is a map of parameter names to their extracted values from the path.
  MatchedRoute(this.data, this.params);

  /// The data associated with the matched route.
  final T data;

  /// The parameters extracted from the path.
  ///
  /// For example, if a route '/users/:id' matches the path '/users/123',
  /// then params would contain {'id': '123'}.
  ///
  /// For wildcard segments, unnamed captures are represented with underscore + index,
  /// like '_0', '_1', etc.
  final Map<String, String> params;
}
