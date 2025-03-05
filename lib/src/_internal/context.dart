import 'node.dart' show Node;

abstract class Context<T> {
  final Node<T> root = Node('');
  final static = <String, Node<T>>{};
}
