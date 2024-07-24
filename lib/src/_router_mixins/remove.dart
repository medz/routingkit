import '../_utils.dart';
import '../types.dart';

mixin Remove<T> on Router<T> {
  @override
  void remove(String? method, String path) {
    _nestRemove(context.root, normalizeHttpMethod(method), splitPath(path), 0);
  }

  static void _nestRemove(
      Node node, String? method, Iterable<String> segments, int index) {
    if (index == segments.length) {
      node.methods?.remove(method);

      // Clean up.
      if (node.methods == null || node.methods?.isEmpty == true) {
        node.methods = null;
      }

      return;
    }

    final segment = segments.elementAt(index);

    // Param
    if (segment == '*') {
      if (node.param != null) {
        _nestRemove(node.param!, method, segments, index + 1);
        if (_isEmptyNode(node.param!)) {
          node.param = null;
        }
      }

      return;
    }

    // Wildcard
    else if (segment == '**') {
      if (node.wildcard != null) {
        _nestRemove(node.wildcard!, method, segments, index + 1);
        if (_isEmptyNode(node.wildcard!)) {
          node.wildcard = null;
        }
      }

      return;
    }

    final static = node.static?[segment];
    if (static != null) {
      _nestRemove(static, method, segments, index + 1);
      if (_isEmptyNode(static)) {
        node.static?.remove(segment);
        if (node.static == null || node.static?.isEmpty == true) {
          node.static = null;
        }
      }
    }
  }

  static bool _isEmptyNode(Node node) {
    return (node.methods == null || node.methods?.isEmpty == true) &&
        (node.static == null || node.static?.isEmpty == true) &&
        node.param == null &&
        node.wildcard == null;
  }
}
