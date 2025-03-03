import 'types.dart';

/// 创建一个新的路由器实例
///
/// 泛型类型 [T] 表示与路由关联的数据类型
Router<T> createRouter<T>() => Router<T>();

/// 路由器类，提供路由管理和匹配功能
class Router<T> {
  Router();

  /// 根节点
  final _root = _RouterNode<T>('');

  /// 静态路由映射，用于快速查找
  final _staticRoutes = <String, _RouterNode<T>>{};

  /// 添加新路由到路由器
  ///
  /// [method] HTTP方法，如'GET'、'POST'等。如果为null，则匹配任何方法
  /// [path] 路由路径模式
  /// [data] 与此路由关联的数据
  void add(String? method, String path, T data) {
    final segments = _pathToSegments(path);
    final params = <_ParamInfo>[];

    var node = _root;
    var unnamedParamIndex = 0;

    for (final (index, segment) in segments.indexed) {
      // 处理通配符路径段 (如 ** 或 **:name)
      if (segment.startsWith('**')) {
        node = node.wildcard ??= _RouterNode('**');
        params.add(_ParamInfo(
          index: index,
          name: segment.split(':').elementAtOrNull(1) ?? '_',
          optional: segment.length == 2,
        ));
        break;
      }

      // 处理参数路径段 (如 * 或 :name)
      if (segment == '*' || segment.startsWith(':')) {
        final optional = segment == '*';
        node = node.param ??= _RouterNode('*');
        params.add(_ParamInfo(
          index: index,
          name: optional
              ? '_${unnamedParamIndex++}'
              : _createParamPattern(segment),
          optional: optional,
        ));
        continue;
      }

      // 处理静态路径段
      node = node.static.putIfAbsent(segment, () => _RouterNode(segment));
    }

    // 添加路由数据到节点
    final routeData = _RouteData(
      data: data,
      params: params.isNotEmpty ? params : null,
    );

    (node.methods ??= {})[method ?? ''] =
        ((node.methods?[method ?? ''] ?? [])..add(routeData));

    // 如果是纯静态路径，添加到静态路由映射
    if (params.isEmpty) {
      _staticRoutes[_segmentsToPath(segments)] = node;
    }
  }

  /// 查找匹配给定路径和方法的第一个路由
  ///
  /// [method] 要匹配的HTTP方法。如果为null，则匹配任何方法
  /// [path] 要匹配的路径
  /// [includeParams] 是否在结果中包含匹配的参数，默认为true
  ///
  /// 如果找到匹配项，则返回[MatchedRoute<T>]，否则返回null
  MatchedRoute<T>? find(String? method, String path,
      {bool includeParams = true}) {
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);

    // 1. 查找静态路由
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;
      final values = node.methods?[method] ?? node.methods?[''];
      if (values != null && values.isNotEmpty) {
        return MatchedRoute(data: values.first.data);
      }
    }

    // 2. 在路由树中查找
    final match = _findInTree(_root, method, segments, 0)?.firstOrNull;
    if (match == null) return null;

    return MatchedRoute(
      data: match.data,
      params: includeParams ? _extractParams(match.params, segments) : null,
    );
  }

  /// 查找匹配给定路径和方法的所有路由
  ///
  /// [method] 要匹配的HTTP方法。如果为null，则匹配任何方法
  /// [path] 要匹配的路径
  /// [includeParams] 是否在结果中包含匹配的参数，默认为true
  ///
  /// 返回所有匹配的路由列表
  List<MatchedRoute<T>> findAll(String? method, String path,
      {bool includeParams = true}) {
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);
    final result = <MatchedRoute<T>>[];

    // 1. 查找静态路由
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;
      _addMatchedRoutes(
          result, node.methods?[method] ?? [], segments, includeParams);
      _addMatchedRoutes(
          result, node.methods?[''] ?? [], segments, includeParams);
    }

    // 2. 收集路由树中的所有匹配
    final matches = _collectMatches(_root, method, segments, 0);
    for (final match in matches) {
      result.add(MatchedRoute(
        data: match.data,
        params: includeParams ? _extractParams(match.params, segments) : null,
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
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);

    // 1. 检查静态路由
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;
      final removed = _removeFromNode(node, method, data);
      if (removed && node.isEmpty) {
        _staticRoutes.remove(normalizedPath);
      }
      return removed;
    }

    // 2. 在路由树中删除
    return _removeFromTree(_root, method, segments, 0, data);
  }

  // 内部方法：将路由数据添加到结果列表
  void _addMatchedRoutes(
    List<MatchedRoute<T>> result,
    List<_RouteData<T>> routeDataList,
    List<String> segments,
    bool includeParams,
  ) {
    for (final routeData in routeDataList) {
      result.add(MatchedRoute(
        data: routeData.data,
        params:
            includeParams ? _extractParams(routeData.params, segments) : null,
      ));
    }
  }

  // 内部方法：在路由树中查找匹配
  List<_RouteData<T>>? _findInTree(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
  ) {
    // 当到达路径末尾时
    if (index == segments.length) {
      // 1. 检查当前节点
      if (node.methods != null) {
        final values = node.methods?[method] ?? node.methods?[''];
        if (values != null) return values;
      }

      // 2. 检查参数节点（可选参数）
      if (node.param != null && node.param!.methods != null) {
        final values = node.param!.methods?[method] ?? node.param!.methods?[''];
        if (values != null && _hasOptionalLastParam(values)) {
          return values;
        }
      }

      // 3. 检查通配符节点（可选参数）
      if (node.wildcard != null && node.wildcard!.methods != null) {
        final values =
            node.wildcard!.methods?[method] ?? node.wildcard!.methods?[''];
        if (values != null && _hasOptionalLastParam(values)) {
          return values;
        }
      }

      return null;
    }

    final segment = segments[index];

    // 1. 检查静态节点
    if (node.static.containsKey(segment)) {
      final result =
          _findInTree(node.static[segment]!, method, segments, index + 1);
      if (result != null) return result;
    }

    // 2. 检查参数节点
    if (node.param != null) {
      final result = _findInTree(node.param!, method, segments, index + 1);
      if (result != null) return result;
    }

    // 3. 检查通配符节点
    if (node.wildcard != null && node.wildcard!.methods != null) {
      return node.wildcard!.methods?[method] ?? node.wildcard!.methods?[''];
    }

    return null;
  }

  // 内部方法：收集所有匹配的路由
  List<_RouteData<T>> _collectMatches(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
  ) {
    final result = <_RouteData<T>>[];

    // 当到达路径末尾时
    if (index == segments.length) {
      // 1. 收集当前节点的匹配
      if (node.methods != null) {
        result.addAll(node.methods?[method] ?? []);
        result.addAll(node.methods?[''] ?? []);
      }

      // 2. 收集参数节点的匹配（可选参数）
      if (node.param != null && node.param!.methods != null) {
        for (final routeData in [
          ...(node.param!.methods?[method] ?? []),
          ...(node.param!.methods?[''] ?? [])
        ]) {
          if (_isLastParamOptional(routeData)) {
            result.add(routeData);
          }
        }
      }

      // 3. 收集通配符节点的匹配（可选参数）
      if (node.wildcard != null && node.wildcard!.methods != null) {
        for (final routeData in [
          ...(node.wildcard!.methods?[method] ?? []),
          ...(node.wildcard!.methods?[''] ?? [])
        ]) {
          if (_isLastParamOptional(routeData)) {
            result.add(routeData);
          }
        }
      }

      return result;
    }

    final segment = segments[index];

    // 1. 收集静态节点的匹配
    if (node.static.containsKey(segment)) {
      result.addAll(
          _collectMatches(node.static[segment]!, method, segments, index + 1));
    }

    // 2. 收集参数节点的匹配
    if (node.param != null) {
      result.addAll(_collectMatches(node.param!, method, segments, index + 1));
    }

    // 3. 收集通配符节点的匹配
    if (node.wildcard != null && node.wildcard!.methods != null) {
      result.addAll(node.wildcard!.methods?[method] ?? []);
      result.addAll(node.wildcard!.methods?[''] ?? []);
    }

    return result;
  }

  // 内部方法：从节点中删除路由数据
  bool _removeFromNode(_RouterNode<T> node, String? method, T? data) {
    if (node.methods == null) return false;

    final methodKey = method ?? '';
    if (!node.methods!.containsKey(methodKey)) return false;

    final routes = node.methods![methodKey]!;
    final initialLength = routes.length;

    if (data != null) {
      routes.removeWhere((route) => route.data == data);
    } else {
      routes.clear();
    }

    if (routes.isEmpty) {
      node.methods!.remove(methodKey);
    }

    if (node.methods!.isEmpty) {
      node.methods = null;
    }

    return initialLength != routes.length;
  }

  // 内部方法：从路由树中删除路由
  bool _removeFromTree(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
    T? data,
  ) {
    // 到达路径末尾
    if (index == segments.length) {
      return _removeFromNode(node, method, data);
    }

    final segment = segments[index];
    var removed = false;

    // 处理通配符路径段
    if (segment.startsWith('**')) {
      if (node.wildcard != null) {
        removed = _removeFromNode(node.wildcard!, method, data);
        if (node.wildcard!.isEmpty) {
          node.wildcard = null;
        }
      }
      return removed;
    }

    // 处理参数路径段
    if (segment == '*' || segment.startsWith(':')) {
      if (node.param != null) {
        removed =
            _removeFromTree(node.param!, method, segments, index + 1, data);
        if (node.param!.isEmpty) {
          node.param = null;
        }
      }
      return removed;
    }

    // 处理静态路径段
    if (node.static.containsKey(segment)) {
      final childNode = node.static[segment]!;
      removed = _removeFromTree(childNode, method, segments, index + 1, data);
      if (childNode.isEmpty) {
        node.static.remove(segment);
      }
    }

    return removed;
  }

  // 辅助方法
  bool _hasOptionalLastParam(List<_RouteData<T>> routes) {
    return routes.isNotEmpty && _isLastParamOptional(routes.first);
  }

  bool _isLastParamOptional(_RouteData<T> routeData) {
    return routeData.params?.lastOrNull?.optional == true;
  }

  // 路径转换工具
  List<String> _pathToSegments(String path) =>
      path.split('/').where((segment) => segment.isNotEmpty).toList();

  String _segmentsToPath(List<String> segments) => segments.join('/');

  // 创建参数模式
  Pattern _createParamPattern(String segment) {
    if (!segment.contains(':', 1)) {
      return segment.substring(1);
    }

    final source = segment.replaceAllMapped(
      RegExp(r':(\w+)'),
      (match) => '(?<${match.group(1)}>\\w+)',
    );

    return RegExp(source);
  }

  // 提取匹配的参数
  Map<String, String>? _extractParams(
    List<_ParamInfo>? params,
    List<String> segments,
  ) {
    if (params == null) return null;

    final result = <String, String>{};
    for (final param in params) {
      final index = param.index;
      final value = index < 0
          ? segments.skip(-1 * index).join('/')
          : index < segments.length
              ? segments[index]
              : null;

      if (value == null) continue;

      if (param.name is RegExp) {
        final regex = param.name as RegExp;
        for (final match in regex.allMatches(value)) {
          for (final name in match.groupNames) {
            final groupValue = match.namedGroup(name);
            if (groupValue != null) {
              result[name] = groupValue;
            }
          }
        }
      } else {
        result[param.name.toString()] = value;
      }
    }

    return result.isNotEmpty ? result : null;
  }
}

/// 内部类：路由节点
class _RouterNode<T> {
  _RouterNode(this.key);

  final String key;
  final Map<String, _RouterNode<T>> static = {};
  _RouterNode<T>? param;
  _RouterNode<T>? wildcard;
  Map<String, List<_RouteData<T>>>? methods;

  bool get isEmpty =>
      methods == null && static.isEmpty && param == null && wildcard == null;
}

/// 内部类：路由数据
class _RouteData<T> {
  _RouteData({required this.data, this.params});

  final T data;
  final List<_ParamInfo>? params;
}

/// 内部类：参数信息
class _ParamInfo {
  _ParamInfo({
    required this.index,
    required this.name,
    required this.optional,
  });

  final int index;
  final Pattern name;
  final bool optional;
}
