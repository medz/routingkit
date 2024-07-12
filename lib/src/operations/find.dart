import '../_utils.dart';
import '../types.dart';

/// Find a routes.
Iterable<MatchedRoute<T>>? findRoute<T>(
    RouterContext<T> context, String method, String path,
    {bool params = true}) {
  final normalizedMethod = normalizeMethod(method);
  final segments = splitPath(path);

  MatchedRoute<T> createMatchedRouteOf(MethodData<T> element) {
    if (!params) {
      return createMatchedRoute(element.data);
    }

    return createMatchedRoute(
        element.data, getMatchParams(segments, element.params));
  }

  // If full path is static
  final static = context.root.static[joinPath(segments)];
  if (static != null) {
    final match = static.methods[normalizedMethod];
    if (match != null) {
      return match.map(createMatchedRouteOf);
    }
  }

  return _lookupTree(context, context.root, method, segments, 0)
      ?.map(createMatchedRouteOf);
}

Iterable<MethodData<T>>? _lookupTree<T>(RouterContext<T> context, Node<T> node,
    String method, Iterable<String> segments, int index) {
  // Step 0, end of path.
  if (index == segments.length) {
    final match = node.methods[method];
    if (match != null) return match;
    if (node.param != null) {
      final match = node.param!.methods[method];
      if (match != null) return match;
    }
    if (node.wildcard != null) {
      return node.wildcard!.methods[method];
    }

    return null;
  }

  final segment = segments.elementAt(index);

  // Step 1, static
  final static = node.static[segment];
  if (static != null) {
    final match = _lookupTree(context, static, method, segments, index + 1);
    if (match != null) return match;
  }

  // Step 2, param
  if (node.param != null) {
    final match =
        _lookupTree(context, node.param!, method, segments, index + 1);
    if (match != null) return match;
  }

  // Step 3, wildcard
  if (node.wildcard != null) {
    return node.wildcard!.methods[method];
  }

  // No match
  return null;
}
