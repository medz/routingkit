import '../_utils.dart';
import '../types.dart';

Iterable<MatchedRoute<T>> findAllRoutes<T>(
    RouterContext<T> context, String method, String path,
    {bool params = true}) {
  final segments = splitPath(path);
  final results = <MethodData<T>>[];

  _findAll<T>(
      context, context.root, normalizeMethod(method), segments, 0, results);

  if (!params) {
    return results.map((e) => createMatchedRoute(e.data));
  }

  return results.map(
      (e) => createMatchedRoute(e.data, getMatchParams(segments, e.params)));
}

void _findAll<T>(RouterContext<T> context, Node<T> node, String method,
    Iterable<String> segments, int index, List<MethodData<T>> results) {
  final segment = segments.elementAtOrNull(index);

  // Step 1, Wildcard
  if (node.wildcard != null) {
    final match = node.wildcard!.methods[method];
    if (match != null) results.addAll(match);
  }

  // Step 2, Param
  if (node.param != null) {
    _findAll(context, node.param!, method, segments, index + 1, results);
    if (index == segments.length) {
      final match = node.param?.methods[method];
      if (match != null) results.addAll(match);
    }
  }

  // Step 3, Static
  final static = node.static[segment];
  if (static != null) {
    _findAll(context, static, method, segments, index + 1, results);
  }

  // Step 4, End of path
  if (index == segments.length) {
    final match = node.methods[method];
    if (match != null) results.addAll(match);
  }
}
