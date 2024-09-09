/// The router context.
abstract interface class RouterContext<T> {
  /// The context root node.
  Node<T> get root;

  /// all path segment is statice nodes.
  Map<String, Node<T>> get static;

  /// Defined all http method mark.
  String get allMethodMark;
}

/// Method data params metadata.
typedef ParamsMetadata = List<({int index, Pattern name, bool optional})>;

/// Method data.
class MethodData<T> {
  /// Creates a new method data.
  const MethodData({required this.data, this.params});

  /// The method data value.
  final T data;

  /// The method params metadata.
  final ParamsMetadata? params;
}

/// Router node.
abstract interface class Node<T> {
  /// The node unique key of current layer.
  String get key;

  /// The node static segment nodes map for children.
  Map<String, Node<T>>? static;

  /// The node param child.
  Node<T>? param;

  /// The node wildcard child.
  Node<T>? wildcard;

  /// The node mounted methods data。
  Map<String, List<MethodData<T>>>? methods;
}

/// Matched route.
class MatchedRoute<T> {
  /// Creates a new matched route.
  const MatchedRoute({required this.data, this.params});

  /// the matched route mounted data, type of [T].
  final T data;

  /// [Map<String, String>] of routing params for matched route.
  final Map<String, String>? params;

  @override
  String toString() =>
      {'data': data, if (params != null) 'params': params}.toString();
}
