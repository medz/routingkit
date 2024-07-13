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

  @override
  Map<String, Object?> toDebugInfo() {
    return {
      'root': root.toDebugInfo(),
      if (static.isNotEmpty == true)
        'static': static.map(
          (key, value) => MapEntry(key, value?.toDebugInfo()),
        ),
    };
  }

  @override
  String get debugName => 'RouterContext<$T>';

  @override
  toString() => createDebugString(this);
}
