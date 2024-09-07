import '../types.dart';

class NodeImpl<T> implements Node<T> {
  NodeImpl(
    this.key, {
    this.methods,
    this.param,
    this.static,
    this.wildcard,
  });

  @override
  final String key;

  @override
  Map<String, List<MethodData<T>>>? methods;

  @override
  Node<T>? param;

  @override
  Map<String, Node<T>>? static;

  @override
  Node<T>? wildcard;
}
