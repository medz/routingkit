import '../_internal/utils.dart';
import '../types.dart';

/// Remove a route from the router context.
void removeRoute<T>(RouterContext<T> ctx, String method, String path) {
  return _remove(ctx.root, method, toPathSegments(path), 0);
}

void _remove<T>(
    Node<T> node, String method, Iterable<String> segments, int index) {
  if (index == segments.length) {
    node.methods?.remove(method);
    if (node.methods?.isEmpty == true) {
      node.methods = null;
    }

    return;
  }

  final segment = segments.elementAtOrNull(index);

  // param
  if (segment == '*') {
    if (node.param != null) {
      _remove(node.param!, method, segments, index + 1);
      if (_isEmpry(node.param!)) {
        node.param = null;
      }
    }

    return;
  }

  // wildcard
  if (segment == "**") {
    if (node.wildcard != null) {
      _remove(node.wildcard!, method, segments, index + 1);
      if (_isEmpry(node.wildcard!)) {
        node.wildcard = null;
      }
    }

    return;
  }

  // static
  if (node.static?[segment] != null) {
    _remove(node.static![segment]!, method, segments, index + 1);
    if (_isEmpry(node.static![segment]!)) {
      node.static?.remove(segment);
      if (node.static?.isEmpty == true) {
        node.static = null;
      }
    }
  }
}

bool _isEmpry<T>(Node<T> node) {
  return node.methods == null &&
      node.static == null &&
      node.param == null &&
      node.wildcard == null;
}
