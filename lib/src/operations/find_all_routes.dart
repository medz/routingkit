import '../_internal/utils.dart';
import '../types.dart';

/// Finds all routes that match the given [path] and [method].
///
/// [ctx] is the router context to search in.
/// [method] is the HTTP method to match (e.g., 'GET', 'POST'). If null, matches all methods.
/// [path] is the URL path to match against.
/// [params] determines whether to extract and return route parameters. Defaults to true.
///
/// Returns an [Iterable] of [MatchedRoute<T>] containing all matching routes.
Iterable<MatchedRoute<T>> findAllRoutes<T>(
  RouterContext<T> ctx,
  String? method,
  String path, {
  bool params = true,
}) {
  final segments = toPathSegments(path);
  final matches = _findAllMethodData(ctx, ctx.root, method, segments, 0);

  return matches.map(
    (e) => MatchedRoute(
      data: e.data,
      params: params ? toMatchedRouteParams(e.params, segments) : null,
    ),
  );
}

Iterable<MethodData<T>> _findAllMethodData<T>(
  RouterContext<T> ctx,
  Node<T> node,
  String? method,
  Iterable<String> segments,
  int index,
) {
  final results = <MethodData<T>>[];

  // 0. wildcard
  if (node.wildcard?.methods
      case final Map<String, List<MethodData<T>>> methodMap) {
    final values = methodMap[method] ?? methodMap[''];
    if (values != null && values.isNotEmpty) {
      results.addAll(values);
    }
  }

  // 1. param
  if (node.param case final Node<T> node) {
    results.addAll(_findAllMethodData(ctx, node, method, segments, index + 1));
    if (node.methods case final Map<String, List<MethodData<T>>> methodMap
        when index == segments.length) {
      final values = methodMap[method] ?? methodMap[''];
      final optionalValues =
          values?.where((e) => e.params?.any((e) => e.optional) == true);
      if (optionalValues != null) {
        results.addAll(optionalValues);
      }
    }
  }

  // 2. static
  if (node.static?[segments.elementAt(index)] case final Node<T> node) {
    results.addAll(_findAllMethodData(ctx, node, method, segments, index + 1));
  }

  // 3. ends.
  if (node.methods case final Map<String, List<MethodData<T>>> methodMap
      when index == segments.length) {
    final values = methodMap[method] ?? methodMap[''];
    if (values != null && values.isNotEmpty) {
      results.addAll(values);
    }
  }

  // Returns found data.
  return results;
}
