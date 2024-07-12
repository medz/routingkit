/// Router context.
abstract interface class RouterContext<T> {
  /// Gets a root route node.
  Node<T> get root;

  /// Gets static nodes map for current router context.
  Map<String, Node<T>?> get static;
}

/// Route node indexed params.
typedef IndexedParams = Iterable<(int, Pattern)>;

/// Method data.
abstract interface class MethodData<T> {
  /// Gets a [T] type data for current method.
  T get data;

  /// Gets current method params.
  IndexedParams? get params;
}

/// Route node.
abstract interface class Node<T> {
  /// The node key name.
  String get key;

  /// Gets static nodes map for current node.
  Map<String, Node<T>> get static;

  /// gets method data map for current node.
  Map<String, List<MethodData<T>>?> get methods;

  /// Get/set current params node.
  Node<T>? param;

  /// Get/set current wildcard node.
  Node<T>? wildcard;
}

/// Matched route.
abstract interface class MatchedRoute<T> {
  /// Returns a data for current matched route.
  T get data;

  /// Returns a params map for current matched route.
  Map<String, String>? get params;
}
