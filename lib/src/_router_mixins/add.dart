import '../_utils.dart';
import '../types.dart';

mixin Add<T> on Router<T> {
  @override
  void add(String? method, String path, T data) {
    final segments = splitPath(path);
    final IndexedParams params = [];

    int unmamedIndex = 0;
    Node<T> node = context.root;

    for (final (index, segment) in segments.indexed) {
      // Wildcard
      if (segment.startsWith('**')) {
        node = node.wildcard ??= Node('**');
        params.add((
          -index,
          segment.split(':').elementAtOrNull(1) ?? '_',
          segment == '**',
        ));
        break;
      }

      // Param
      else if (segment == '*' || segment.contains(':')) {
        final isOptional = segment == '*';
        node = node.param ??= Node('*');
        params.add((
          index,
          isOptional ? '_${unmamedIndex++}' : _createParamPattern(segment),
          isOptional,
        ));
        continue;
      }

      // Static
      node = (node.static ??= {}).putIfAbsent(segment, () => Node(segment));
    }

    // Sets the method data.
    (node.methods ??= {})
        .putIfAbsent(normalizeHttpMethod(method), () => [])
        .add(MethodData(data, params));

    // If no params, set static into context.
    if (params.isEmpty) {
      context.static[joinPath(segments)] = node;
    }
  }

  static final _paramRegexp = RegExp(r':(\w+)');
  static Pattern _createParamPattern(String segment) {
    if (!segment.contains(':', 1)) {
      return segment.substring(1);
    }

    final source = segment.replaceAllMapped(_paramRegexp, (match) {
      return '(?<${match.group(1)}>\\w+)';
    });

    return RegExp(source);
  }
}
