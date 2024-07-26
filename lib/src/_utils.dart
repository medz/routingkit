import 'types.dart';

/// Normalize http method.
String? normalizeHttpMethod(String? method) => method?.toUpperCase();

/// Split path
Iterable<String> splitPath(String path) =>
    path.split('/').where((e) => e.isNotEmpty);

/// Join path.
String joinPath(Iterable<String> segments) => segments.join('/');

/// The [IndexedParams] to [Params].
Params toParams(IndexedParams params, Iterable<String> segments) {
  final result = <String, String>{} as Params;

  for (final (index, pattern, _) in params) {
    final value = switch (index) {
      < 0 => joinPath(segments.skip(-1 * index)),
      _ => segments.elementAtOrNull(index),
    };

    if (value == null) continue;
    if (pattern is RegExp) {
      for (final match in pattern.allMatches(value)) {
        result.addEntries(
            match.groupNames.map((e) => MapEntry(e, match.namedGroup(e)!)));
      }

      continue;
    }

    result[pattern.toString()] = value;
  }

  return result;
}
