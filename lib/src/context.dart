import '_internal/node_impl.dart';
import 'types.dart';

final class _ContextImpl<T> implements RouterContext<T> {
  _ContextImpl(this.allMethodMark);

  @override
  final Node<T> root = NodeImpl("<root>");

  @override
  late final Map<String, Node<T>> static = {};

  @override
  final String allMethodMark;
}

/// Creates a new router context.
RouterContext<T> createRouter<T>({String allMethodMark = '*'}) =>
    _ContextImpl<T>(allMethodMark);
