import '../_internal/node_impl.dart';
import '../_internal/utils.dart';
import '../types.dart';

/// Adds a new route to the router context.
///
/// [ctx] The router context to add the route to.
/// [method] The HTTP method for this route (e.g., 'GET', 'POST'). If null, matches any method.
/// [path] The path pattern for this route.
/// [data] The data associated with this route.
///
/// This function handles static routes, parameterized routes, and wildcard routes.
/// It updates the routing tree structure and adds appropriate metadata for route matching.
void addRoute<T>(RouterContext<T> ctx, String? method, String path, T data) {
  final segments = toPathSegments(path);
  final ParamsMetadata params = [];

  Node<T> node = ctx.root;
  int unmamedParamIndex = 0;

  for (final (index, segment) in segments.indexed) {
    // Wildcard
    if (segment.startsWith('**')) {
      node = node.wildcard ??= NodeImpl<T>('**');
      params.add((
        index: index,
        name: segment.split(':').elementAtOrNull(1) ?? '_',
        optional: segment.length == 2,
      ));

      break;
    }

    // Param
    if (segment == '*' || segment.startsWith(':')) {
      final optional = segment == '*';

      node = node.param ??= NodeImpl<T>('*');
      params.add((
        index: index,
        name: optional
            ? '_${unmamedParamIndex++}'
            : _createParamsMatcher(segment),
        optional: optional
      ));

      continue;
    }

    // Static
    node = (node.static ??= {}).putIfAbsent(segment, () => NodeImpl(segment));
  }

  // Assign params and data to the node.
  (node.methods ??= {}).putIfAbsent(method ?? '', () => []).add(MethodData(
        data: data,
        params: params.isNotEmpty ? params : null,
      ));

  // All segments is static.
  if (params.isEmpty) {
    ctx.static[toSegmentsPath(segments)] = node;
  }
}

Pattern _createParamsMatcher(String segment) {
  if (!segment.contains(':', 1)) {
    return segment.substring(1);
  }

  final source = segment.replaceAllMapped(
    RegExp(r':(\w+)'),
    (match) => '(?<${match.group(1)}>\\w+)',
  );

  return RegExp(source);
}
