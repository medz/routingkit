import '../types.dart';

Iterable<String> toPathSegments(String path) =>
    path.split('/').where((segment) => segment.isNotEmpty);

String toSegmentsPath(Iterable<String> segments) =>
    segments.where((segment) => segment.isNotEmpty).join('/');

Map<String, String>? toMatchedRouteParams(
    ParamsMetadata? params, Iterable<String> segments) {
  if (params == null) return null;

  final results = <String, String>{};
  for (final (:index, :name, optional: _) in params) {
    final value = switch (index) {
      < 0 => toSegmentsPath(segments.skip(-1 * index)),
      _ => segments.elementAtOrNull(index),
    };

    if (value == null) continue;
    if (name is RegExp) {
      for (final match in name.allMatches(value)) {
        final entries = match.groupNames
            .map((name) => MapEntry(name, match.namedGroup(name)))
            .where((e) => e.value != null)
            .cast<MapEntry<String, String>>();

        results.addEntries(entries);
      }

      continue;
    }

    results[name.toString()] = value;
  }

  return results;
}
