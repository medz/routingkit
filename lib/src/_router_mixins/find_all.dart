import '../_utils.dart';
import '../types.dart';

mixin FindAll<T> on Router<T> {
  @override
  Iterable<MatchedRoute<T>> findAll(String? method, String path) {
    final segments = splitPath(path);

    // match all method data.
    final matches =
        _findAllRoutes(context.root, normalizeHttpMethod(method), segments, 0);

    return matches
        .map((e) => MatchedRoute(e.data, toParams(e.params, segments)));
  }

  static Iterable<MethodData<T>> _findAllRoutes<T>(
      Node<T> node, String? method, Iterable<String> segments, int index) {
    final results = <MethodData<T>>[];

    // Step 1, Wildcard
    if (node.wildcard != null) {
      final values = node.wildcard!.methods?[method];
      if (values != null) results.addAll(values);
    }

    // Step 2, Param
    if (node.param != null) {
      results.addAll(_findAllRoutes(node.param!, method, segments, index + 1));

      if (index == segments.length) {
        final values = node.param!.methods?[method];
        if (values?.firstOrNull?.params.lastOrNull?.$3 == true) {
          results.addAll(values!);
        }
      }
    }

    // Step 3, Static
    final static = node.static?[segments.elementAtOrNull(index)];
    if (static != null) {
      results.addAll(_findAllRoutes(static, method, segments, index + 1));
    }

    // End of path.
    if (index == segments.length) {
      final values = node.methods?[method];
      if (values != null) results.addAll(values);
    }

    return results;
  }
}
