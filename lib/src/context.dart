import '_internal/node_impl.dart';
import 'types.dart';

final class _ContextImpl<T> implements RouterContext<T> {
  @override
  final Node<T> root = NodeImpl("<root>");

  @override
  late final Map<String, Node<T>> static = {};
}

/// Creates a new router context.
RouterContext<T> createRouter<T>() => _ContextImpl<T>();
