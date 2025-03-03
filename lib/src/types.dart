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
