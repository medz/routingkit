class Param {
  Param(this.index, this.name, this.optional);

  final int index;
  final Pattern name;
  final bool optional;
}

class MethodData<T> {
  MethodData(this.data, [this.params]);

  final T data;
  List<Param>? params;
}

class Node<T> {
  Node(this.key, {this.static, this.param, this.wildcard, this.methods});

  final String key;
  Map<String, Node<T>>? static;
  Node<T>? param;
  Node<T>? wildcard;
  Map<String, List<MethodData<T>>>? methods;
}
