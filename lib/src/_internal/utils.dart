import 'node.dart';

Iterable<String> splitPath(String path) {
  return path.split('/').where((element) => element.isNotEmpty);
}

String parseMethod(String? method, String defaults) {
  method = method?.trim().toUpperCase();
  if (method == null || method.isEmpty) {
    return defaults;
  }

  return method;
}

Map<String, String> parseMatchParams(
    Iterable<String> segments, Iterable<Param>? params) {
  if (params == null || params.isEmpty) {
    return const {};
  }

  final result = <String, String>{};
  for (final Param(:index, :name) in params) {
    final segment = index < 0
        ? segments.skip(-1 * index).join('/')
        : segments.elementAtOrNull(index);
    if (segment == null) continue;
    if (name case final String name) {
      result[name] = segment;
      continue;
    }
    if (name is RegExp) {
      for (final match in name.allMatches(segment)) {
        final entries = match.groupNames
            .map((name) => MapEntry(name, match.namedGroup(name)))
            .where((e) => e.value != null)
            .cast<MapEntry<String, String>>();
        result.addEntries(entries);
      }
    }
  }

  return result;
}
