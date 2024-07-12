abstract interface class RouterContext<T> {
  Node<T> get root;
  Map<String, Node<T>?> get static;
}

typedef IndexedParams = Iterable<(int, Pattern)>;

abstract interface class MethodData<T> {
  T get data;
  IndexedParams? get params;
}

abstract interface class Node<T> {
  String get key;
  Map<String, Node<T>> get static;
  Map<String, List<MethodData<T>>?> get methods;

  Node<T>? param;
  Node<T>? wildcard;
}

abstract interface class MatchedRoute<T> {
  T get data;
  Map<String, String>? get params;
}
