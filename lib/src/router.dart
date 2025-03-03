import 'types.dart';

/// Creates a new router instance
///
/// Generic type [T] represents the data type associated with routes
Router<T> createRouter<T>() => Router<T>();

/// Router class, provides route management and matching functionality
class Router<T> {
  Router();

  /// Root node
  final _root = _RouterNode<T>('');

  /// Static route mapping for quick lookup
  final _staticRoutes = <String, _RouterNode<T>>{};

  /// Adds a new route to the router
  ///
  /// [method] HTTP method like 'GET', 'POST', etc. If null, matches any method
  /// [path] Route path pattern
  /// [data] Data associated with this route
  void add(String? method, String path, T data) {
    final segments = _pathToSegments(path);
    final params = <_ParamInfo>[];

    var node = _root;
    var unnamedParamIndex = 0;

    for (final (index, segment) in segments.indexed) {
      // Handle wildcard path segment (like ** or **:name)
      if (segment.startsWith('**')) {
        node = node.wildcard ??= _RouterNode('**');
        params.add(_ParamInfo(
          index: index,
          name: segment.split(':').elementAtOrNull(1) ?? '_',
          optional: segment.length == 2,
        ));
        break;
      }

      // Handle parameter path segment (like * or :name)
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

      // Handle static path segment
      node = node.static.putIfAbsent(segment, () => _RouterNode(segment));
    }

    // Add route data to the node
    final routeData = _RouteData(
      data: data,
      params: params.isNotEmpty ? params : null,
    );

    (node.methods ??= {})[method ?? ''] =
        ((node.methods?[method ?? ''] ?? [])..add(routeData));

    // If it's a pure static path, add to static route mapping
    if (params.isEmpty) {
      _staticRoutes[_segmentsToPath(segments)] = node;
    }
  }

  /// Find the first route matching the given path and method
  ///
  /// [method] HTTP method to match. If null, matches any method
  /// [path] Path to match
  /// [includeParams] Whether to include matched parameters in the result, defaults to true
  ///
  /// Returns [MatchedRoute<T>] if a match is found, null otherwise
  MatchedRoute<T>? find(String? method, String path,
      {bool includeParams = true}) {
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);

    // 1. Look for static routes
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;

      // First check for exact method match
      final methodValues = node.methods?[method];
      if (methodValues != null && methodValues.isNotEmpty) {
        return MatchedRoute(
          data: methodValues.first.data,
          params: includeParams
              ? _extractParams(methodValues.first.params, segments)
              : null,
        );
      }

      // Then check for wildcard method match (method is null)
      final wildcardMethodValues = node.methods?[''];
      if (wildcardMethodValues != null && wildcardMethodValues.isNotEmpty) {
        return MatchedRoute(
          data: wildcardMethodValues.first.data,
          params: includeParams
              ? _extractParams(wildcardMethodValues.first.params, segments)
              : null,
        );
      }
    }

    // 2. Look in the route tree
    final match = _findInTree(_root, method, segments, 0)?.firstOrNull;
    if (match == null) return null;

    return MatchedRoute(
      data: match.data,
      params: includeParams ? _extractParams(match.params, segments) : null,
    );
  }

  /// Find all routes matching the given path and method
  ///
  /// [method] HTTP method to match. If null, matches any method
  /// [path] Path to match
  /// [includeParams] Whether to include matched parameters in the result, defaults to true
  ///
  /// Returns a list of all matching routes
  List<MatchedRoute<T>> findAll(String? method, String path,
      {bool includeParams = true}) {
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);
    final result = <MatchedRoute<T>>[];

    // 1. Look for static routes
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;

      // Add exact method matches
      if (method != null) {
        _addMatchedRoutes(
            result, node.methods?[method] ?? [], segments, includeParams);
      }

      // Add wildcard method matches (method is '')
      _addMatchedRoutes(
          result, node.methods?[''] ?? [], segments, includeParams);

      // If request method is null, add routes for all methods
      if (method == null && node.methods != null) {
        for (final entry in node.methods!.entries) {
          if (entry.key.isNotEmpty) {
            // Skip wildcard method since it's already added
            _addMatchedRoutes(result, entry.value, segments, includeParams);
          }
        }
      }
    }

    // 2. Collect all matches from the route tree
    final matches = _collectMatches(_root, method, segments, 0);
    for (final match in matches) {
      result.add(MatchedRoute(
        data: match.data,
        params: includeParams ? _extractParams(match.params, segments) : null,
      ));
    }

    return result;
  }

  /// Remove a route from the router
  ///
  /// [method] HTTP method to remove. If null, matches any method
  /// [path] Route path to remove
  /// [data] Optional, if provided, only removes the route if the route data matches
  ///
  /// Returns whether a route was removed
  bool remove(String? method, String path, [T? data]) {
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);

    // 1. Check static routes
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;
      final removed = _removeFromNode(node, method, data);
      if (removed && node.isEmpty) {
        _staticRoutes.remove(normalizedPath);
      }
      return removed;
    }

    // 2. Remove from the route tree
    return _removeFromTree(_root, method, segments, 0, data);
  }

  // Internal method: Add route data to result list
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

  // Internal method: Find matches in the route tree
  List<_RouteData<T>>? _findInTree(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
  ) {
    // When reaching the end of the path
    if (index == segments.length) {
      // 1. Check current node
      if (node.methods != null) {
        // First check for exact method match
        if (method != null && node.methods!.containsKey(method)) {
          return node.methods![method];
        }

        // Then check for wildcard method match (method is '')
        if (node.methods!.containsKey('')) {
          return node.methods![''];
        }

        // If method is null, should return null as caller needs to manually handle all methods
        if (method == null) {
          return null;
        }

        return null;
      }

      // 2. Check parameter node (optional parameter)
      if (node.param != null && node.param!.methods != null) {
        // Same logic as above
        List<_RouteData<T>>? values;
        if (method != null && node.param!.methods!.containsKey(method)) {
          values = node.param!.methods![method];
        } else if (node.param!.methods!.containsKey('')) {
          values = node.param!.methods![''];
        } else {
          return null;
        }

        if (values != null && _hasOptionalLastParam(values)) {
          return values;
        }
      }

      // 3. Check wildcard node (optional parameter)
      if (node.wildcard != null && node.wildcard!.methods != null) {
        // Same logic as above
        List<_RouteData<T>>? values;
        if (method != null && node.wildcard!.methods!.containsKey(method)) {
          values = node.wildcard!.methods![method];
        } else if (node.wildcard!.methods!.containsKey('')) {
          values = node.wildcard!.methods![''];
        } else {
          return null;
        }

        return values;
      }

      return null;
    }

    final segment = segments[index];

    // 1. Check static node
    if (node.static.containsKey(segment)) {
      final result =
          _findInTree(node.static[segment]!, method, segments, index + 1);
      if (result != null) return result;
    }

    // 2. Check parameter node
    if (node.param != null) {
      final result = _findInTree(node.param!, method, segments, index + 1);
      if (result != null) return result;
    }

    // 3. Check wildcard node
    if (node.wildcard != null && node.wildcard!.methods != null) {
      // Same logic as above
      List<_RouteData<T>>? values;
      if (method != null && node.wildcard!.methods!.containsKey(method)) {
        values = node.wildcard!.methods![method];
      } else if (node.wildcard!.methods!.containsKey('')) {
        values = node.wildcard!.methods![''];
      } else {
        return null;
      }

      return values;
    }

    return null;
  }

  // Internal method: Collect all matches from the route tree
  List<_RouteData<T>> _collectMatches(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
  ) {
    final result = <_RouteData<T>>[];

    // When reaching the end of the path
    if (index == segments.length) {
      // Check current node methods
      _addMethodMatches(result, node, method);

      // Check parameter node methods (optional parameter)
      if (node.param != null) {
        _addMethodMatches(result, node.param!, method);
      }

      // Check wildcard node methods
      if (node.wildcard != null) {
        _addMethodMatches(result, node.wildcard!, method);
      }

      return result;
    }

    final segment = segments[index];

    // 1. Check if static path exists and recurse
    if (node.static.containsKey(segment)) {
      result.addAll(
          _collectMatches(node.static[segment]!, method, segments, index + 1));
    }

    // 2. Check parameter match and recurse
    if (node.param != null) {
      result.addAll(_collectMatches(node.param!, method, segments, index + 1));
    }

    // 3. Check wildcard match
    if (node.wildcard != null) {
      _addMethodMatches(result, node.wildcard!, method);
    }

    return result;
  }

  // Helper method to add method matches to result
  void _addMethodMatches(
    List<_RouteData<T>> result,
    _RouterNode<T> node,
    String? method,
  ) {
    if (node.methods == null) return;

    // Add exact method matches
    if (method != null && node.methods!.containsKey(method)) {
      result.addAll(node.methods![method]!);
    }

    // Add wildcard method matches
    if (node.methods!.containsKey('')) {
      result.addAll(node.methods!['']!);
    }
  }

  // Internal method: Remove from node
  bool _removeFromNode(_RouterNode<T> node, String? method, T? data) {
    if (node.methods == null) return false;

    // Method to remove (null becomes '' in the map)
    final methodKey = method ?? '';

    // If there's no entry for this method, nothing to remove
    if (!node.methods!.containsKey(methodKey)) return false;

    // If data is provided, remove specific data entry
    if (data != null) {
      final routes = node.methods![methodKey]!;
      final initialLength = routes.length;
      node.methods![methodKey] = routes.where((r) => r.data != data).toList();

      // Check if any route was removed
      final removed = initialLength > node.methods![methodKey]!.length;
      // Clean up empty lists
      if (node.methods![methodKey]!.isEmpty) {
        node.methods!.remove(methodKey);
      }
      // Clean up empty methods map
      if (node.methods!.isEmpty) {
        node.methods = null;
      }
      return removed;
    } else {
      // Remove all routes for this method
      node.methods!.remove(methodKey);
      // Clean up empty methods map
      if (node.methods!.isEmpty) {
        node.methods = null;
      }
      return true;
    }
  }

  // Internal method: Remove from tree
  bool _removeFromTree(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
    T? data,
  ) {
    // When reaching the end of the path
    if (index == segments.length) {
      return _removeFromNode(node, method, data);
    }

    final segment = segments[index];
    bool removed = false;

    // 1. Try to remove from static node
    if (segment != '*' && segment != '**' && !segment.startsWith(':')) {
      if (node.static.containsKey(segment)) {
        removed = _removeFromTree(
            node.static[segment]!, method, segments, index + 1, data);

        // Clean up static node if empty
        if (node.static[segment]!.isEmpty) {
          node.static.remove(segment);
        }

        return removed;
      }
    }

    // 2. Try to remove from parameter node
    if (segment == '*' || segment.startsWith(':')) {
      if (node.param != null) {
        removed =
            _removeFromTree(node.param!, method, segments, index + 1, data);
        if (node.param!.isEmpty) {
          node.param = null;
        }
        return removed;
      }
      return false;
    }

    // 3. Try to remove from wildcard node
    if (segment.startsWith('**')) {
      if (node.wildcard != null) {
        removed = _removeFromNode(node.wildcard!, method, data);
        if (node.wildcard!.isEmpty) {
          node.wildcard = null;
        }
      }
      return removed;
    }

    return false;
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
