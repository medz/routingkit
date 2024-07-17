/// Router context.
abstract interface class RouterContext<T> {
  /// Gets a root route node.
  Node<T> get root;

  /// Gets static nodes map for current router context.
  Map<String, Node<T>?> get static;
}

abstract base class IndexedParam {
  const IndexedParam(this.index);

  final int index;
}

final class NameIndexedParam extends IndexedParam {
  const NameIndexedParam(super.index, this.name);

  final String name;
}

final class RegExpIndexedParam extends IndexedParam {
  const RegExpIndexedParam(super.index, this.regex);

  final RegExp regex;
}

final class UnnameIndexedParam extends IndexedParam {
  const UnnameIndexedParam(super.index);
}

final class CatchallIndexedParam extends IndexedParam {
  const CatchallIndexedParam(super.index, [this.name]);

  final String? name;
}

/// Method data.
abstract interface class MethodData<T> {
  /// Gets a [T] type data for current method.
  T get data;

  /// Gets current method params.
  Iterable<IndexedParam>? get params;
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

abstract interface class Params {
  String? get(String name);
  Iterable<String> get unnamed;
  String? get catchall;
}

/// Matched route.
abstract interface class MatchedRoute<T> {
  /// Returns a data for current matched route.
  T get data;

  /// Returns a params map for current matched route.
  Params get params;
}
