import '../_utils.dart';
import '../types.dart';

/// Remove a route from the router context.
void removeRoute<T>(RouterContext<T> context, String methodOrPath,
    [String? path]) {
  final segments = splitPath(path ?? methodOrPath);
  final method = path != null ? normalizeMethod(methodOrPath) : null;

  _remove(context.root, 0, segments, method);
}

void _remove<T>(
    Node<T> node, int index, Iterable<String> segments, String? method) {
  if (index == segments.length) {
    node.methods.remove(method);
    return;
  }

  final segment = segments.elementAtOrNull(index);
  final cleanup = switch (segment) {
    '*' => () {
        if (node.param == null) return;

        _remove(node.param!, index + 1, segments, method);
        if (_isEmptyNode(node.param!)) {
          node.param = null;
        }
      },
    '**' => () {
        if (node.wildcard == null) return;

        _remove(node.wildcard!, index + 1, segments, method);
        if (_isEmptyNode(node.wildcard!)) {
          node.wildcard = null;
        }
      },
    String path => () {
        final static = node.static[path];
        if (static == null) return;

        _remove(static, index + 1, segments, method);
        if (_isEmptyNode(static)) {
          node.static.remove(path);
        }
      },
    _ => null,
  };

  cleanup?.call();
}

bool _isEmptyNode<T>(Node<T> node) {
  return node.methods.isEmpty &&
      node.static.isEmpty &&
      node.param == null &&
      node.wildcard == null;
}
