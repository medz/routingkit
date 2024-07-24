/// Method data indexed params.
typedef IndexedParams = List<(int index, Pattern name, bool optional)>;

/// Mappable interface.
abstract interface class Mappable {
  /// Creates a map for the [Mappable] impl.
  Map<String, dynamic> toMap();
}

/// Method data
class MethodData<T> implements Mappable {
  /// Creates a new method data.
  const MethodData(this.data, this.params);

  /// Returns method data.
  final T data;

  /// Returns method data params.
  final IndexedParams params;

  @override
  Map<String, dynamic> toMap() => {'data': data, 'params': params};
}

/// Router node.
class Node<T> implements Mappable {
  /// Creates a new router node.
  Node(this.key, {this.methods, this.static, this.param, this.wildcard});

  /// The node type key.
  final String key;

  /// The node store method data.
  Map<String?, List<MethodData<T>>>? methods;

  /// The node static children nodes.
  Map<String, Node<T>>? static;

  /// The node param child node.
  Node<T>? param;

  /// The node wildcard node.
  Node<T>? wildcard;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (key.isNotEmpty) 'key': key,
      if (methods?.isNotEmpty == true)
        'methods': methods
            ?.map((key, value) => MapEntry(key, value.map((e) => e.toMap()))),
      if (static?.isNotEmpty == true)
        'static': static?.map((key, value) => MapEntry(key, value.toMap())),
      if (param != null) 'param': param?.toMap(),
      if (wildcard != null) 'wildcard': wildcard?.toMap(),
    };
  }
}

/// Router context.
class Context<T> implements Mappable {
  Context({required this.root, required this.static});

  /// The root node for context.
  Node<T> root;

  /// The static nodes map for context.
  Map<String, Node<T>> static;

  @override
  Map<String, dynamic> toMap() => {
        'root': root.toMap(),
        'static': static.map((key, value) => MapEntry(key, value.toMap())),
      };
}

/// Matched route params.
extension type Params._(Map<String, String> _) implements Map<String, String> {
  static final _unnamedNameRegex = RegExp(r'^_\d+');

  /// Returns matched unnamed params.
  Iterable<String> get unmamed => entries
      .where((e) => _unnamedNameRegex.hasMatch(e.key))
      .map((e) => e.value);

  /// Returns catchall param.
  String? get catchall => _['_'];
}

/// Matched route.
class MatchedRoute<T> implements Mappable {
  /// Creates a new mmatched route.
  const MatchedRoute(this.data, this.params);

  /// Matched route data.
  final T data;

  /// Matched route params.
  final Params params;

  @override
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      if (params.isNotEmpty) 'params': params,
    };
  }
}

/// RoutingKit router.
abstract interface class Router<T> {
  /// Returns the router context.
  Context<T> get context;

  /// Adds a new route.
  void add(String? method, String path, T data);

  /// Remove a added route.
  ///
  /// **NOTE**: Not support named param.
  void remove(String? method, String path);

  /// Find first added route.
  MatchedRoute<T>? find(String? method, String path);

  /// Find all added routes.
  ///
  /// If the [includeNonMethod] is `true`, the returns result include the [method] is `null` routes.
  Iterable<MatchedRoute<T>> findAll(String? method, String path,
      [bool includeNonMethod = false]);
}
