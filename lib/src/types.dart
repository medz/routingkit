/// Matched route result
///
/// Generic type [T] represents the data type associated with the route
class MatchedRoute<T> {
  /// Creates a new matched route result
  ///
  /// [data] The data associated with the matched route
  /// [params] Parameters of the matched route, can be null
  MatchedRoute({
    required this.data,
    this.params,
  });

  /// Data associated with the matched route
  final T data;

  /// Parameters extracted from the route, null if no parameters
  final Map<String, String>? params;

  @override
  String toString() => 'MatchedRoute(data: $data, params: $params)';
}

/// Router interface for route management and matching
///
/// Generic type [T] represents the data type associated with routes
abstract class Router<T> {
  /// Token used to represent any HTTP method
  String get anyMethodToken;

  /// Adds a new route to the router
  ///
  /// [method] HTTP method like 'GET', 'POST', etc. If null, matches any method
  /// [path] Route path pattern
  /// [data] Data associated with this route
  void add(String? method, String path, T data);

  /// Find the first route matching the given path and method
  ///
  /// [method] HTTP method to match. If null, matches any method
  /// [path] Path to match
  /// [includeParams] Whether to include matched parameters in the result, defaults to true
  ///
  /// Returns [MatchedRoute<T>] if a match is found, null otherwise
  MatchedRoute<T>? find(String? method, String path,
      {bool includeParams = true});

  /// Find all routes matching the given path and method
  ///
  /// [method] HTTP method to match. If null, matches any method
  /// [path] Path to match
  /// [includeParams] Whether to include matched parameters in the result, defaults to true
  ///
  /// Returns a list of all matching routes
  List<MatchedRoute<T>> findAll(String? method, String path,
      {bool includeParams = true});

  /// Remove a route from the router
  ///
  /// [method] HTTP method to remove. If null, matches any method
  /// [path] Route path to remove
  /// [data] Optional, if provided, only removes the route if the route data matches
  ///
  /// Returns whether a route was removed
  bool remove(String? method, String path, [T? data]);
}
