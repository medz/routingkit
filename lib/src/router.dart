import 'types.dart';
import '_internal/node_impl.dart';
import '_internal/utils.dart';

/// 创建一个新的路由器实例
///
/// 泛型类型 [T] 表示与路由关联的数据类型
Router<T> createRouter<T>() => Router<T>();

/// 路由器类，提供路由管理和匹配功能
class Router<T> {
  final RouterContext<T> _context;

  /// 创建一个新的路由器实例
  Router() : _context = _createContext<T>();

  /// 添加新路由到路由器
  ///
  /// [method] HTTP方法，如'GET'、'POST'等。如果为null，则匹配任何方法
  /// [path] 路由路径模式
  /// [data] 与此路由关联的数据
  void add(String? method, String path, T data) {
    final segments = toPathSegments(path);
    final ParamsMetadata params = [];

    Node<T> node = _context.root;
    int unmamedParamIndex = 0;

    for (final (index, segment) in segments.indexed) {
      // Wildcard
      if (segment.startsWith('**')) {
        node = node.wildcard ??= NodeImpl<T>('**');
        params.add((
          index: index,
          name: segment.split(':').elementAtOrNull(1) ?? '_',
          optional: segment.length == 2,
        ));

        break;
      }

      // Param
      if (segment == '*' || segment.startsWith(':')) {
        final optional = segment == '*';

        node = node.param ??= NodeImpl<T>('*');
        params.add((
          index: index,
          name: optional
              ? '_${unmamedParamIndex++}'
              : _createParamsMatcher(segment),
          optional: optional
        ));

        continue;
      }

      // Static
      node = (node.static ??= {}).putIfAbsent(segment, () => NodeImpl(segment));
    }

    // Assign params and data to the node.
    (node.methods ??= {}).putIfAbsent(method ?? '', () => []).add(MethodData(
          data: data,
          params: params.isNotEmpty ? params : null,
        ));

    // All segments is static.
    if (params.isEmpty) {
      _context.static[toSegmentsPath(segments)] = node;
    }
  }

  /// 查找匹配给定路径和方法的第一个路由
  ///
  /// [method] 要匹配的HTTP方法。如果为null，则匹配任何方法
  /// [path] 要匹配的路径
  /// [params] 是否在结果中包含匹配的参数，默认为true
  ///
  /// 如果找到匹配项，则返回[MatchedRoute<T>]，否则返回null
  MatchedRoute<T>? find(String? method, String path, {bool params = true}) {
    final segments = toPathSegments(path);
    final normalizedPath = toSegmentsPath(segments);

    // 0. global static matched.
    if (_context.static[normalizedPath]
        case Node<T>(
          methods: final Map<String, List<MethodData<T>>> methodMap
        )) {
      final values = methodMap[method] ?? methodMap[''];
      if (values?.firstOrNull?.data case final data when data is T) {
        return MatchedRoute(data: data);
      }
    }

    // 1. lookup tree.
    final match =
        _lookupTree(_context, _context.root, method, segments, 0)?.firstOrNull;
    if (match == null) return null;

    return MatchedRoute(
      data: match.data,
      params: params ? toMatchedRouteParams(match.params, segments) : null,
    );
  }

  /// 查找匹配给定路径和方法的所有路由
  ///
  /// [method] 要匹配的HTTP方法。如果为null，则匹配任何方法
  /// [path] 要匹配的路径
  /// [params] 是否在结果中包含匹配的参数，默认为true
  ///
  /// 返回所有匹配的路由列表
  List<MatchedRoute<T>> findAll(String? method, String path,
      {bool params = true}) {
    final segments = toPathSegments(path);
    final normalizedPath = toSegmentsPath(segments);
    final result = <MatchedRoute<T>>[];

    // 0. global static matched.
    if (_context.static[normalizedPath]
        case Node<T>(
          methods: final Map<String, List<MethodData<T>>> methodMap
        )) {
      for (final methodData in methodMap[method] ?? []) {
        result.add(MatchedRoute(
          data: methodData.data,
          params:
              params ? toMatchedRouteParams(methodData.params, segments) : null,
        ));
      }

      for (final methodData in methodMap[''] ?? []) {
        result.add(MatchedRoute(
          data: methodData.data,
          params:
              params ? toMatchedRouteParams(methodData.params, segments) : null,
        ));
      }
    }

    // 1. lookup tree.
    for (final methodData
        in _collectMatches(_context, _context.root, method, segments, 0)) {
      result.add(MatchedRoute(
        data: methodData.data,
        params:
            params ? toMatchedRouteParams(methodData.params, segments) : null,
      ));
    }

    return result;
  }

  /// 从路由器中删除路由
  ///
  /// [method] 要删除的HTTP方法。如果为null，则匹配任何方法
  /// [path] 要删除的路由路径
  /// [data] 可选，如果提供，只有当路由数据匹配时才删除
  ///
  /// 返回是否有路由被删除
  bool remove(String? method, String path, [T? data]) {
    final segments = toPathSegments(path);
    final normalizedPath = toSegmentsPath(segments);

    // 0. find node.
    final staticNode = _context.static[normalizedPath];
    if (staticNode != null) {
      final removed = _removeMethodData(staticNode, method, data);
      if (removed && staticNode.methods?.isEmpty == true) {
        _context.static.remove(normalizedPath);
      }
      return removed;
    }

    // 1. remove from tree.
    return _removeFromTree(_context.root, method, segments, 0, data);
  }

  Iterable<MethodData<T>>? _lookupTree(
    RouterContext<T> ctx,
    Node<T> node,
    String? method,
    Iterable<String> segments,
    int index,
  ) {
    // 0. Ends
    if (index == segments.length) {
      if (node.methods != null) {
        final values = node.methods?[method] ?? node.methods?[''];
        if (values != null) return values;
      }

      // Fallback to dynamic for last child (/test and /test/ matches /test/*)
      if (node.param case Node<T>(methods: final methodMap)
          when methodMap != null) {
        final values = methodMap[method] ?? methodMap[''];

        // The reason for only checking first here is that findRoute only returns the first match.
        if (values != null &&
            values.firstOrNull?.params?.lastOrNull?.optional == true) {
          return values;
        }
      }

      if (node.wildcard case Node<T>(methods: final methodMap)
          when methodMap != null) {
        final values = methodMap[method] ?? methodMap[''];

        // The reason for only checking first here is that findRoute only returns the first match.
        if (values != null &&
            values.firstOrNull?.params?.lastOrNull?.optional == true) {
          return values;
        }
      }

      return null;
    }

    final segment = segments.elementAtOrNull(index);

    // 1. static
    if (node.static?[segment] case final Node<T> node) {
      final values = _lookupTree(ctx, node, method, segments, index + 1);
      if (values != null) return values;
    }

    // 2. param
    if (node.param case final Node<T> node) {
      final values = _lookupTree(ctx, node, method, segments, index + 1);
      if (values != null) return values;
    }

    // 3. wildcard
    if (node.wildcard case Node<T>(methods: final methodMap)
        when methodMap != null) {
      return methodMap[method] ?? methodMap[''];
    }

    // No match
    return null;
  }

  List<MethodData<T>> _collectMatches(
    RouterContext<T> ctx,
    Node<T> node,
    String? method,
    Iterable<String> segments,
    int index,
  ) {
    final result = <MethodData<T>>[];

    // 0. Ends
    if (index == segments.length) {
      if (node.methods != null) {
        result.addAll(node.methods?[method] ?? []);
        result.addAll(node.methods?[''] ?? []);
      }

      // Fallback to dynamic for last child.
      if (node.param case Node<T>(methods: final methodMap)
          when methodMap != null) {
        for (final value in (methodMap[method] ?? []) + (methodMap[''] ?? [])) {
          if (value.params?.lastOrNull?.optional == true) {
            result.add(value);
          }
        }
      }

      if (node.wildcard case Node<T>(methods: final methodMap)
          when methodMap != null) {
        for (final value in (methodMap[method] ?? []) + (methodMap[''] ?? [])) {
          if (value.params?.lastOrNull?.optional == true) {
            result.add(value);
          }
        }
      }

      return result;
    }

    final segment = segments.elementAtOrNull(index);

    // 1. static
    if (node.static?[segment] case final Node<T> childNode) {
      result
          .addAll(_collectMatches(ctx, childNode, method, segments, index + 1));
    }

    // 2. param
    if (node.param case final Node<T> childNode) {
      result
          .addAll(_collectMatches(ctx, childNode, method, segments, index + 1));
    }

    // 3. wildcard
    if (node.wildcard case Node<T>(methods: final methodMap)
        when methodMap != null) {
      result.addAll(methodMap[method] ?? []);
      result.addAll(methodMap[''] ?? []);
    }

    return result;
  }

  bool _removeMethodData(Node<T> node, String? method, T? data) {
    if (node.methods == null) return false;

    final methods = node.methods![method ?? ''];
    if (methods == null) return false;

    final initialLength = methods.length;
    if (data != null) {
      methods.removeWhere((item) => item.data == data);
    } else {
      methods.clear();
    }

    if (methods.isEmpty) {
      node.methods!.remove(method ?? '');
    }

    if (node.methods!.isEmpty) {
      node.methods = null;
    }

    return initialLength != methods.length;
  }

  bool _removeFromTree(
    Node<T> node,
    String? method,
    Iterable<String> segments,
    int index,
    T? data,
  ) {
    if (index == segments.length) {
      return _removeMethodData(node, method, data);
    }

    final segment = segments.elementAt(index);
    var removed = false;

    // Check wildcard node
    if (segment.startsWith('**')) {
      if (node.wildcard != null) {
        removed = _removeMethodData(node.wildcard!, method, data);
        if (node.wildcard!.methods == null &&
            node.wildcard!.static == null &&
            node.wildcard!.param == null &&
            node.wildcard!.wildcard == null) {
          node.wildcard = null;
        }
      }
      return removed;
    }

    // Check param node
    if (segment == '*' || segment.startsWith(':')) {
      if (node.param != null) {
        removed =
            _removeFromTree(node.param!, method, segments, index + 1, data);
        if (node.param!.methods == null &&
            node.param!.static == null &&
            node.param!.param == null &&
            node.param!.wildcard == null) {
          node.param = null;
        }
      }
      return removed;
    }

    // Check static nodes
    if (node.static != null && node.static!.containsKey(segment)) {
      final staticNode = node.static![segment]!;
      removed = _removeFromTree(staticNode, method, segments, index + 1, data);
      if (staticNode.methods == null &&
          staticNode.static == null &&
          staticNode.param == null &&
          staticNode.wildcard == null) {
        node.static!.remove(segment);
      }
      if (node.static!.isEmpty) {
        node.static = null;
      }
    }

    return removed;
  }
}

// 内部辅助方法 - 创建路由器上下文
RouterContext<T> _createContext<T>() {
  return _ContextImpl<T>();
}

// 内部实现 - 路由器上下文
class _ContextImpl<T> implements RouterContext<T> {
  @override
  final Node<T> root = NodeImpl("<root>");

  @override
  final Map<String, Node<T>> static = {};
}

// 内部方法 - 创建参数匹配器
Pattern _createParamsMatcher(String segment) {
  if (!segment.contains(':', 1)) {
    return segment.substring(1);
  }

  final source = segment.replaceAllMapped(
    RegExp(r':(\w+)'),
    (match) => '(?<${match.group(1)}>\\w+)',
  );

  return RegExp(source);
}

// 从utils.dart导入的功能
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
