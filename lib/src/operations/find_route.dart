import '../_internal/utils.dart';
import '../types.dart';

/// Finds the first matching route for the given path and method.
///
/// [ctx] The router context to search in.
/// [method] The HTTP method to match. If null, matches any method.
/// [path] The path to match against.
/// [params] Whether to include matched parameters in the result. Defaults to true.
///
/// Returns a [MatchedRoute<T>] if a match is found, or null if no match is found.
/// The [MatchedRoute] includes the associated data and, if [params] is true,
/// any matched path parameters.
MatchedRoute<T>? findRoute<T>(
  RouterContext<T> ctx,
  String? method,
  String path, {
  bool params = true,
}) {
  final segments = toPathSegments(path);
  final normalizedPath = toSegmentsPath(segments);

  // 0. global static matched.
  if (ctx.static[normalizedPath]
      case Node<T>(methods: final Map<String, List<MethodData<T>>> methodMap)) {
    final values = methodMap[method] ?? methodMap[''];
    if (values?.firstOrNull?.data case final data when data is T) {
      return MatchedRoute(data: data);
    }
  }

  // 1. lookup tree.
  final match = _lookupTree(ctx, ctx.root, method, segments, 0)?.firstOrNull;
  if (match == null) return null;

  return MatchedRoute(
    data: match.data,
    params: params ? toMatchedRouteParams(match.params, segments) : null,
  );
}

Iterable<MethodData<T>>? _lookupTree<T>(
  RouterContext<T> ctx,
  Node<T> node,
  String? method,
  Iterable<String> segments,
  int index,
) {
  // 0. Ends
  if (index == segments.length) {
    if (node.methods != null) {
      final values = node.methods?[method] ?? node.methods?[''];
      if (values != null) return values;
    }

    // Fallback to dynamic for last child (/test and /test/ matches /test/*)
    if (node.param case Node<T>(methods: final methodMap)
        when methodMap != null) {
      final values = methodMap[method] ?? methodMap[''];

      // The reason for only checking first here is that findRoute only returns the first match.
      if (values != null &&
          values.firstOrNull?.params?.lastOrNull?.optional == true) {
        return values;
      }
    }

    if (node.wildcard case Node<T>(methods: final methodMap)
        when methodMap != null) {
      final values = methodMap[method] ?? methodMap[''];

      // The reason for only checking first here is that findRoute only returns the first match.
      if (values != null &&
          values.firstOrNull?.params?.lastOrNull?.optional == true) {
        return values;
      }
    }

    return null;
  }

  final segment = segments.elementAtOrNull(index);

  // 1. static
  if (node.static?[segment] case final Node<T> node) {
    final values = _lookupTree(ctx, node, method, segments, index + 1);
    if (values != null) return values;
  }

  // 2. param
  if (node.param case final Node<T> node) {
    final values = _lookupTree(ctx, node, method, segments, index + 1);
    if (values != null) return values;
  }

  // 3. wildcard
  if (node.wildcard case Node<T>(methods: final methodMap)
      when methodMap != null) {
    return methodMap[method] ?? methodMap[''];
  }

  // No match
  return null;
}
