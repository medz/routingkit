import 'types.dart';

final class _MethodDataImpl<T> implements MethodData<T> {
  const _MethodDataImpl(this.data, [this.params]);

  @override
  final T data;

  @override
  final Iterable<IndexedParam>? params;
}

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
  const _MatchedRouteImpl(this.data, this.params);

  @override
  final T data;

  @override
  final Params params;
}

MethodData<T> createMethodData<T>(T data, [Iterable<IndexedParam>? params]) =>
    _MethodDataImpl(data, params);

Node<T> createNode<T>(String key) => _NodeImpl<T>(key);

MatchedRoute<T> createMatchedRoute<T>(T data, Params params) =>
    _MatchedRouteImpl(data, params);

bool _isNotEmpty(String? element) => element?.isNotEmpty == true;

Iterable<String> splitPath(String path) {
  return path.split('/').where(_isNotEmpty);
}

String joinPath(Iterable<String> segments) =>
    segments.where(_isNotEmpty).join('/');

String normalizeMethod(String method) => method.trim().toUpperCase();

Params getMatchParams(
    Iterable<String> segments, Iterable<IndexedParam>? indexedParams) {
  final params = _ParamsImpl();
  if (indexedParams == null || indexedParams.isEmpty) {
    return params;
  }

  for (final param in indexedParams) {
    final value = switch (param.index) {
      < 0 => joinPath(segments.skip(-1 * param.index)),
      _ => segments.elementAtOrNull(param.index),
    };

    if (value == null || value.isEmpty) continue;

    switch (param) {
      case NameIndexedParam(name: final name):
        params.named[name] = value;
        break;
      case UnnameIndexedParam _:
        params.unnamed.add(value);
      case CatchallIndexedParam(name: final name):
        params.catchall = value;
        if (name != null) {
          params.named[name] = value;
        }
        break;
      case RegExpIndexedParam(regex: final regex):
        for (final match in regex.allMatches(value)) {
          final entries =
              match.groupNames.map((e) => MapEntry(e, match.namedGroup(e)!));
          params.named.addEntries(entries);
        }
        break;
    }
  }

  return params;
}

class _ParamsImpl implements Params {
  final named = <String, String>{};

  @override
  String? catchall;

  @override
  String? get(String name) => named[name];

  @override
  List<String> unnamed = <String>[];
}
