import '_internal/node_impl.dart';
import 'types.dart';

final class _ContextImpl<T> implements RouterContext<T> {
  @override
  final Node<T> root = NodeImpl("<root>");

  @override
  late final Map<String, Node<T>> static = {};
}

/// Creates and returns a new router context.
///
/// The generic type [T] represents the type of data associated with routes.
///
/// Returns a [RouterContext<T>] that can be used to manage routes and perform routing operations.
RouterContext<T> createRouter<T>() => _ContextImpl<T>();
