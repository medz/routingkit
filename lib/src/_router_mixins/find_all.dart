import '../_utils.dart';
import '../types.dart';

mixin FindAll<T> on Router<T> {
  @override
  Iterable<MatchedRoute<T>> findAll(String? method, String path,
      [bool includeNonMethod = false]) {
    // Resolve inclide non method, if the method is `null` the value always is false.
    includeNonMethod = method == null ? false : includeNonMethod;

    final segments = splitPath(path);
    final matches = <MethodData<T>>[];

    // match all method data.
    _matchAll(context.root, normalizeHttpMethod(method), segments, 0,
        includeNonMethod, matches);

    return matches
        .map((e) => MatchedRoute(e.data, toParams(e.params, segments)));
  }

  static void _matchAll<T>(
      Node<T> node,
      String? method,
      Iterable<String> segments,
      int index,
      bool includeNonMethod,
      List<MethodData<T>> matches) {
    // Step 1, Wildcard
    if (node.wildcard != null) {
      final results = node.wildcard!.methods?[method];
      if (results != null) matches.addAll(results);
      if (includeNonMethod) {
        final include = node.wildcard!.methods?[null];
        if (include != null) matches.addAll(include);
      }
    }

    // Step 2, Param
    if (node.param != null) {
      _matchAll(node, method, segments, index + 1, includeNonMethod, matches);
      if (index == segments.length) {
        final results = node.param!.methods?[method];
        if (results != null) matches.addAll(matches);
        if (includeNonMethod) {
          final include = node.param!.methods?[null];
          if (include != null) matches.addAll(include);
        }
      }
    }

    // Step 3, Static
    final static = node.static?[segments.elementAtOrNull(index)];
    if (static != null) {
      _matchAll(node, method, segments, index + 1, includeNonMethod, matches);
    }

    // End of path.
    if (index == segments.length) {
      final results = node.methods?[method];
      if (results != null) matches.addAll(results);
      if (includeNonMethod) {
        final include = node.methods?[null];
        if (include != null) matches.addAll(include);
      }
    }
  }
}
