/// Routing kit debuging interface.
abstract interface class RoutingKitDebuging {
  /// Gets current object debug name.
  String get debugName;

  /// Creates a debug map from this.
  Map<String, Object?> toDebugInfo();

  /// Creates a debug string,
  String toDebugString();
}

/// Router context.
abstract interface class RouterContext<T> implements RoutingKitDebuging {
  /// Gets a root route node.
  Node<T> get root;

  /// Gets static nodes map for current router context.
  Map<String, Node<T>?> get static;
}

/// Route node indexed params.
typedef IndexedParams = Iterable<(int, Pattern)>;

/// Method data.
abstract interface class MethodData<T> implements RoutingKitDebuging {
  /// Gets a [T] type data for current method.
  T get data;

  /// Gets current method params.
  IndexedParams? get params;
}

/// Route node.
abstract interface class Node<T> implements RoutingKitDebuging {
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
abstract interface class MatchedRoute<T> implements RoutingKitDebuging {
  /// Returns a data for current matched route.
  T get data;

  /// Returns a params map for current matched route.
  Map<String, String>? get params;
}
