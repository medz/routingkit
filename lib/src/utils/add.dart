import '../_utils.dart';
import '../types.dart';

/// Adds a route to the router context.
void addRoute<T>(RouterContext<T> context, String method, String path, T data) {
  final segments = splitPath(path);
  final params = <IndexedParam>[];

  Node<T> node = context.root;

  for (final (index, segment) in segments.indexed) {
    // Wildcard
    if (segment.startsWith('**')) {
      node = node.wildcard ??= createNode('**');
      params.add(
          CatchallIndexedParam(-index, segment.split(':').elementAtOrNull(1)));
      break;
    }

    // Param
    if (segment == '*' || segment.contains(':')) {
      node = node.param ??= createNode('*');
      params.add(switch (segment) {
        '*' => UnnameIndexedParam(index),
        String name => _createIndexedParam(index, name),
      });

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
      .add(createMethodData(data, hasParams ? params : null));

  if (!hasParams) {
    context.static[joinPath(segments)] = node;
  }
}

final _paramRegexp = RegExp(r':(\w+)');
IndexedParam _createIndexedParam(int index, String segment) {
  if (!segment.contains(':', 1)) {
    return NameIndexedParam(index, segment.substring(1));
  }

  final source = segment.replaceAllMapped(_paramRegexp, (match) {
    return '(?<${match.group(1)}>\\w+)';
  });

  return RegExpIndexedParam(index, RegExp(source));
}
