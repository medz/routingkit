import 'types.dart';

final class _NodeImpl<T> implements Node<T> {
  _NodeImpl(this.key);

  @override
  final String key;

  @override
  final methods = <String, List<MethodData<T>>?>{};

  @override
  final static = <String, Node<T>>{};

  @override
  Node<T>? param;

  @override
  Node<T>? wildcard;
}

final class _MatchedRouteImpl<T> implements MatchedRoute<T> {
  const _MatchedRouteImpl(this.data, [this.params]);

  @override
  final T data;

  @override
  final Map<String, String>? params;
}

Node<T> createNode<T>(String key) => _NodeImpl<T>(key);

MatchedRoute<T> createMatchedRoute<T>(T data, [Map<String, String>? params]) =>
    _MatchedRouteImpl(data, params);

bool _isNotEmpty(String? element) => element?.isNotEmpty == true;

Iterable<String> splitPath(String path) {
  return path.split('/').where(_isNotEmpty);
}

String joinPath(Iterable<String> segments) =>
    segments.where(_isNotEmpty).join('/');

String normalizeMethod(String method) => method.trim().toUpperCase();

Map<String, String>? getMatchParams(
    Iterable<String> segments, IndexedParams? indexedParams) {
  if (indexedParams == null) return null;

  final params = <String, String>{};

  for (final (index, name) in indexedParams) {
    final segment = switch (index) {
      < 0 => joinPath(segments.skip(-1 * index)),
      _ => segments.elementAtOrNull(index),
    };

    if (segment == null || segment.isEmpty) continue;
    if (name is RegExp) {
      final matches = name.allMatches(segment);
      for (final match in matches) {
        final entries =
            match.groupNames.map((e) => MapEntry(e, match.namedGroup(e)!));

        params.addEntries(entries);
      }

      continue;
    }

    params[name.toString()] = segment;
  }

  return params;
}