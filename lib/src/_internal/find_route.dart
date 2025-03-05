import '../types.dart';
import 'context.dart';
import 'node.dart';
import 'utils.dart';

mixin FindRoute<T> on Context<T> implements Router<T> {
  @override
  MatchedRoute<T>? find(String? method, String path) {
    final segments = splitPath(path);
    path = segments.join('/');
    method = parseMethod(method, anyMethodToken);

    // Static
    if (static[path] case Node<T>(:final methods)
        when methods != null && methods.isNotEmpty) {
      final match = methods[method] ?? methods[anyMethodToken];
      if (match != null && match.isNotEmpty) {
        return MatchedRoute(match.first.data, const {});
      }
    }

    final match = lookupTree(root, method, segments)?.first;
    if (match == null) return null;
    return MatchedRoute(match.data, parseMatchParams(segments, match.params));
  }
}

extension<T> on FindRoute<T> {
  Iterable<MethodData<T>>? lookupTree(
    Node<T> node,
    String method,
    Iterable<String> segments, [
    int index = 0,
  ]) {
    // End of path
    if (index == segments.length) {
      if (node.methods != null) {
        final match = node.methods![method] ?? node.methods![anyMethodToken];
        if (match != null) {
          return match;
        }
      }

      final methods = switch (node) {
        Node<T>(param: Node<T>(:final methods)) => methods,
        Node<T>(wildcard: Node<T>(:final methods)) => methods,
        _ => null,
      };
      final match = methods?[method] ?? methods?[anyMethodToken];
      if (match != null &&
          match.firstOrNull?.params?.lastOrNull?.optional == true) {
        return match;
      }

      return null;
    }

    final segment = segments.elementAt(index);
    final nextNode = switch (node) {
      Node<T>(:final static)
          when static != null && static.containsKey(segment) =>
        static[segment],
      Node<T>(:final Node<T> param) => param,
      _ => null,
    };

    if (nextNode != null) {
      final match = lookupTree(nextNode, method, segments, index + 1);
      if (match != null) return match;
    }

    if (node.wildcard case Node<T>(:final methods) when methods != null) {
      return methods[method] ?? methods[anyMethodToken];
    }

    return null;
  }
}
