import '../types.dart';
import 'context.dart';
import 'node.dart';
import 'utils.dart';

mixin AddRoute<T> on Context<T> implements Router<T> {
  @override
  void add(String? method, String path, T data) {
    method = parseMethod(method, anyMethodToken);

    final segments = splitPath(path);
    final params = <Param>[];
    Node<T> node = root;
    int unnamedParamsIndex = 0;

    for (final (index, segment) in segments.indexed) {
      // Wildcard
      if (segment.startsWith('**')) {
        node = node.wildcard ??= Node('**');
        params.add(Param(
          -index,
          segment.split(':').elementAtOrNull(1) ?? '_',
          segment.length == 2,
        ));
        break;
      }

      // Param
      if (segment == '*' || segment.contains(':')) {
        node = node.param ??= Node('*');
        final isOptional = segment == '*';
        params.add(Param(
          index,
          isOptional ? '_${unnamedParamsIndex++}' : createParamMatcher(segment),
          isOptional,
        ));
        continue;
      }

      // Static
      final static = node.static ??= {};
      node = static[segment] ??= Node(segment);
    }

    final hasParams = params.isNotEmpty;
    final methods = node.methods ??= {};
    final methodData = methods[method] ??= [];
    methodData.add(MethodData(data, hasParams ? params : null));

    if (!hasParams) {
      static[segments.join('/')] = node;
    }
  }
}

extension<T> on AddRoute<T> {
  static final paramRegex = RegExp(r':(\w+)');

  Pattern createParamMatcher(String segment) {
    if (segment.startsWith(':') && !segment.contains(':', 1)) {
      return segment.substring(1);
    }

    final regex = segment.replaceAllMapped(
        paramRegex, (match) => '(?<${match.group(1)}>\\w+)');
    return RegExp('^$regex\$');
  }
}
