abstract interface class Router<T> {
  String get anyMethodToken;
  bool get caseSensitive;
  MatchedRoute<T>? find(String? method, String path);
  Iterable<MatchedRoute<T>> findAll(String? method, String path);
  void add(String? method, String path, T data);
  void remove(String? method, String path);
}

class MatchedRoute<T> {
  MatchedRoute(this.data, this.params);

  final T data;
  final Map<String, String> params;
}
