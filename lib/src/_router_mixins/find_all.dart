import '../_utils.dart';
import '../types.dart';

mixin FindAll<T> on Router<T> {
  @override
  Iterable<MatchedRoute<T>> findAll(String? method, String path,
      [bool includeNonMethod = false]) {
    // Resolve inclide non method, if the method is `null` the value always is false.
    includeNonMethod = method == null ? false : includeNonMethod;

    final segments = splitPath(path);

    // match all method data.
    final matches = _findAllRoutes(context.root, normalizeHttpMethod(method),
        segments, 0, includeNonMethod);

    return matches
        .map((e) => MatchedRoute(e.data, toParams(e.params, segments)));
  }

  static Iterable<MethodData<T>> _findAllRoutes<T>(Node<T> node, String? method,
      Iterable<String> segments, int index, bool includeNonMethod) {
    final results = <MethodData<T>>[];

    // Step 1, Wildcard
    if (node.wildcard != null) {
      final values = node.wildcard!.methods?[method];
      if (values != null) results.addAll(values);
      if (includeNonMethod) {
        final include = node.wildcard!.methods?[null];
        if (include != null) results.addAll(include);
      }
    }

    // Step 2, Param
    if (node.param != null) {
      results.addAll(_findAllRoutes(
          node.param!, method, segments, index + 1, includeNonMethod));

      if (index == segments.length) {
        final values = node.param!.methods?[method];
        if (values != null) results.addAll(values);
        if (includeNonMethod) {
          final include = node.param!.methods?[null];
          if (include != null) results.addAll(include);
        }
      }
    }

    // Step 3, Static
    final static = node.static?[segments.elementAtOrNull(index)];
    if (static != null) {
      results.addAll(_findAllRoutes(
          static, method, segments, index + 1, includeNonMethod));
    }

    // End of path.
    if (index == segments.length) {
      final values = node.methods?[method];
      if (values != null) results.addAll(values);
      if (includeNonMethod) {
        final include = node.methods?[null];
        if (include != null) results.addAll(include);
      }
    }

    return results;
  }
}
