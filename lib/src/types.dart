/// Represents the context of a router, holding the structure of routes.
abstract interface class RouterContext<T> {
  /// The root node of the routing tree.
  Node<T> get root;

  /// A map of static routes, where keys are full paths and values are corresponding nodes.
  Map<String, Node<T>> get static;
}

/// Metadata for route parameters.
///
/// Each element in the list represents a route parameter with the following properties:
/// - [index]: The position of the parameter in the route.
/// - [name]: The name or pattern of the parameter.
/// - [optional]: Whether the parameter is optional.
typedef ParamsMetadata = List<({int index, Pattern name, bool optional})>;

/// Represents data associated with a specific route.
class MethodData<T> {
  /// Creates a new instance of [MethodData].
  ///
  /// [data] is the payload associated with this route.
  /// [params] contains metadata about the route parameters, if any.
  const MethodData({required this.data, this.params});

  /// The payload data associated with this route.
  final T data;

  /// Metadata about the parameters for this route, if any.
  final ParamsMetadata? params;
}

/// Represents a node in the routing tree structure.
abstract interface class Node<T> {
  /// The unique identifier for this node in the current layer of the routing tree.
  String get key;

  /// A map of child nodes for static route segments.
  Map<String, Node<T>>? static;

  /// The child node for parameterized route segments.
  Node<T>? param;

  /// The child node for wildcard route segments.
  Node<T>? wildcard;

  /// A map of HTTP methods to their corresponding MethodData for this node.
  Map<String, List<MethodData<T>>>? methods;
}

/// Represents a successfully matched route in the routing system.
class MatchedRoute<T> {
  /// Creates a new instance of [MatchedRoute].
  ///
  /// [data] is the payload associated with the matched route.
  /// [params] is an optional map of extracted route parameters.
  const MatchedRoute({required this.data, this.params});

  /// The payload data associated with the matched route.
  final T data;

  /// A map of route parameters extracted from the matched route, if any.
  final Map<String, String>? params;

  @override
  String toString() =>
      {'data': data, if (params != null) 'params': params}.toString();
}
