import '_utils.dart';
import 'types.dart';

/// Create a new router context.
RouterContext<T> createRouter<T>() {
  final node = createNode<T>("");
  final context = _RouterContextImpl(node);

  return context;
}

final class _RouterContextImpl<T> implements RouterContext<T> {
  _RouterContextImpl(this.root);

  @override
  final Node<T> root;

  @override
  final static = <String, Node<T>?>{};
}