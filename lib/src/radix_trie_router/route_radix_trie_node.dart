class RouteRadixTrieNode<T> {
  final constants = <String, RouteRadixTrieNode<T>>{};

  RouteRadixTrieNode<T>? parent;
  WildcardRouteRadixTrieNode<T>? wildcard;
  RouteRadixTrieNode<T>? catchall;
  T? value;
}

class WildcardRouteRadixTrieNode<T> extends RouteRadixTrieNode<T> {
  final names = <RouteRadixTrieNode<T>, String>{};
}
