import 'types.dart';

String createDebugProps(Map<String, Object?> props, [int indent = 0]) {
  final buffer = StringBuffer();
  buffer.write('{');
  if (props.isNotEmpty) buffer.writeln();

  for (final MapEntry(key: name, value: value) in props.entries) {
    buffer.write(''.padLeft(indent + 2));
    buffer.write(name);
    buffer.write(': ');
    buffer.write(createDebugString(value, indent + 2));
    buffer.writeln(',');
  }

  buffer.write(''.padLeft(indent));
  buffer.write('}');

  return buffer.toString();
}

String createDebugString(Object? value, [int indent = 0]) {
  return switch (value) {
    RoutingKitDebuging value =>
      '${value.debugName} ${createDebugString(value.toDebugInfo(), indent)}',
    Iterable values => createDebugString(values.toList().asMap(), indent),
    Map(map: final map) => createDebugProps(
        map(
          (key, value) => MapEntry(
            key.toString(),
            createDebugString(value, indent + 2),
          ),
        ),
        indent,
      ),
    _ => value.toString(),
  };
}

final class _MethodDataImpl<T> implements MethodData<T> {
  const _MethodDataImpl(this.data, [this.params]);

  @override
  final T data;

  @override
  final IndexedParams? params;

  @override
  toString() => createDebugString(this);

  @override
  Map<String, Object?> toDebugInfo() {
    return {
      'data': data,
      if (params?.isNotEmpty == true) 'params': params,
    };
  }

  @override
  String get debugName => 'MethodData<$T>';
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

  @override
  toString() => createDebugString(this);

  @override
  Map<String, Object?> toDebugInfo() {
    return {
      'key': key.isEmpty ? '<root>' : key,
      if (methods.isNotEmpty) 'methods': methods,
      if (static.isNotEmpty) 'static': static,
      if (param != null) 'param': param,
      if (wildcard != null) 'wildcard': wildcard,
    };
  }

  @override
  String get debugName => 'Node<$T>';
}

final class _MatchedRouteImpl<T> implements MatchedRoute<T> {
  const _MatchedRouteImpl(this.data, [this.params]);

  @override
  final T data;

  @override
  final Map<String, String>? params;

  @override
  Map<String, Object?> toDebugInfo() {
    return {
      'data': data,
      if (params?.isNotEmpty == true) 'params': params,
    };
  }

  @override
  toString() => createDebugString(this);

  @override
  String get debugName => 'MatchedRoute<$T>';
}

MethodData<T> createMethodData<T>(T data, [IndexedParams? params]) =>
    _MethodDataImpl(data, params);

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
