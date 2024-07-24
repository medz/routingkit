import '../_utils.dart';
import '../types.dart';

mixin Find<T> on Router<T> {
  @override
  MatchedRoute<T>? find(String? method, String path) {
    final segments = splitPath(path);
    final normalizedMethod = normalizeHttpMethod(method);

    // Global static
    final static = context.static[joinPath(segments)];
    if (static != null) {
      final route = (static.methods?[normalizedMethod] ?? static.methods?[null])
          ?.firstOrNull;
      if (route != null) {
        return MatchedRoute(route.data, toParams(route.params, segments));
      }
    }

    // lookup
    final route =
        _lookup<T>(context.root, normalizedMethod, segments, 0)?.firstOrNull;
    if (route != null) {
      return MatchedRoute(route.data, toParams(route.params, segments));
    }

    return null;
  }

  static Iterable<MethodData<T>>? _lookup<T>(
      Node<T> node, String? method, Iterable<String> segments, int index) {
    // Step 1, End of path.
    if (index == segments.length) {
      final match = (node.methods?[method] ?? node.methods?[null]);
      if (match != null) return match;

      // Fallback to dynamic for last child (/test and /test/ matches /test/*)
      if (node.param != null) {
        final match =
            node.param!.methods?[method] ?? node.param!.methods?[null];
        if (match?.firstOrNull?.params.lastOrNull?.$3 == true) {
          return match;
        }
      }

      // Wildcard
      if (node.wildcard != null) {
        final match =
            node.wildcard!.methods?[method] ?? node.wildcard!.methods?[null];
        if (match?.firstOrNull?.params.lastOrNull?.$3 == true) {
          return match;
        }
      }

      // No match.
      return null;
    }

    // Step 2, static
    final static = node.static?[segments.elementAtOrNull(index)];
    if (static != null) {
      final match = _lookup(static, method, segments, index + 1);
      if (match != null) return match;
    }

    // Step 3, param
    if (node.param != null) {
      final match = _lookup(node.param!, method, segments, index + 1);
      if (match != null) return match;
    }

    // Setp 3, wildcard
    return node.wildcard?.methods?[method] ?? node.wildcard?.methods?[null];
  }
}
