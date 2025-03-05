import '../types.dart';
import 'context.dart';
import 'node.dart';
import 'utils.dart';

mixin RemoveRoute<T> on Context<T> implements Router<T> {
  @override
  void remove(String? method, String path) {
    final segments = splitPath(path);
    method = parseMethod(method, anyMethodToken);
    nestedClear(root, method, segments);
  }
}

extension<T> on RemoveRoute<T> {
  void nestedClear(Node<T> node, String method, Iterable<String> segments,
      [int index = 0]) {
    if (index == segments.length) {
      node.methods?.remove(method);
      if (node.methods?.isEmpty == true) {
        node.methods = null;
      }

      return;
    }

    final segment = segments.elementAt(index);

    if (segment == "*") {
      if (node.param case final Node<T> nextNode) {
        nestedClear(nextNode, method, segments, index + 1);
        if (nextNode.isEmpty) {
          node.param = null;
        }
      }
      return;
    }

    if (segment == "**") {
      if (node.wildcard case final Node<T> nextNode) {
        nestedClear(nextNode, method, segments, index + 1);
        if (nextNode.isEmpty) {
          node.wildcard = null;
        }
      }
      return;
    }

    if (node.static?[method] case final Node<T> nextNode) {
      nestedClear(nextNode, method, segments, index + 1);
      if (nextNode.isEmpty) {
        node.static?.remove(method);
        if (node.static?.isEmpty == true) {
          node.static = null;
        }
      }
    }
  }
}

extension<T> on Node<T> {
  bool get isEmpty =>
      methods == null && static == null && param == null && wildcard == null;
}
