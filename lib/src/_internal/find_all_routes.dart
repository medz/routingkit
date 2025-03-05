import '../types.dart';
import 'context.dart';
import 'node.dart';
import 'utils.dart';

mixin FindAllRoutes<T> on Context<T> implements Router<T> {
  @override
  Iterable<MatchedRoute<T>> findAll(String? method, String path) {
    method = parseMethod(method, anyMethodToken);

    final segments = splitPath(path);
    final matches = lookupTreeAll(root, method, segments);

    return matches.map(
      (e) => MatchedRoute(e.data, parseMatchParams(segments, e.params)),
    );
  }
}

extension<T> on FindAllRoutes<T> {
  Iterable<MethodData<T>> lookupTreeAll(
      Node<T> node, String method, Iterable<String> segments,
      [int index = 0]) {
    final segment = segments.elementAt(index);
    final result = <MethodData<T>>[];

    // Wildcard
    if (node.wildcard case Node<T>(:final methods) when methods != null) {
      final match = methods[method] ?? methods[anyMethodToken];
      if (match != null) result.addAll(match);
    }

    // Param
    if (node.param case final Node<T> node) {
      result.addAll(lookupTreeAll(node, method, segments, index + 1));
      if (index == segments.length && node.methods != null) {
        final match = node.methods?[method] ?? node.methods?[anyMethodToken];
        if (match != null &&
            match.firstOrNull?.params?.lastOrNull?.optional == true) {
          result.addAll(match);
        }
      }
    }

    // Static
    if (node.static?[segment] case final Node<T> node) {
      result.addAll(lookupTreeAll(node, method, segments, index + 1));
    }

    // End of path
    if (index == segments.length && node.methods != null) {
      final match = node.methods?[method] ?? node.methods?[anyMethodToken];
      if (match != null) result.addAll(match);
    }

    return result;
  }
}
