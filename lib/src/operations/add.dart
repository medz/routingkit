import '../_utils.dart';
import '../types.dart';

/// Adds a route to the router context.
void addRoute<T>(RouterContext<T> context, String method, String path, T data) {
  final segments = splitPath(path);
  final params = <(int, Pattern)>[];

  Node<T> node = context.root;
  int unnamedParamIndex = 0;

  for (final (index, segment) in segments.indexed) {
    // Wildcard
    if (segment.startsWith('**')) {
      node = node.wildcard ??= createNode('**');
      params.add((-index, segment.split(':').elementAtOrNull(1) ?? '_'));
      break;
    }

    // Param
    if (segment == '*' || segment.contains(':')) {
      node = node.param ??= createNode('*');
      params.add((
        index,
        switch (segment) {
          '*' => '_${unnamedParamIndex++}',
          _ => _getParamMatcherOf(segment),
        }
      ));
      continue;
    }

    // Static
    final child = node.static[segment];
    if (child != null) {
      node = child;
    } else {
      final staticNode = createNode<T>(segment);
      node.static[segment] = staticNode;
      node = staticNode;
    }
  }

  final hasParams = params.isNotEmpty;
  final normalizedMethod = normalizeMethod(method);
  node.methods.putIfAbsent(normalizedMethod, () => []);
  node.methods[normalizedMethod]!
      .add(_MethodDataImpl(data, hasParams ? params : null));

  if (!hasParams) {
    context.static[joinPath(segments)] = node;
  }
}

final _paramRegexp = RegExp(r':(\w+)');
Pattern _getParamMatcherOf(String segment) {
  if (!segment.contains(':', 1)) {
    return segment.substring(1);
  }

  final source = segment.replaceAllMapped(_paramRegexp, (match) {
    return '(?<${match.group(1)}>\\w+)';
  });

  return RegExp(source);
}

final class _MethodDataImpl<T> implements MethodData<T> {
  const _MethodDataImpl(this.data, [this.params]);

  @override
  final T data;

  @override
  final IndexedParams? params;
}
