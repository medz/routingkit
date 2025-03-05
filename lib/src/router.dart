import 'types.dart';

/// Creates a new router instance
///
/// Generic type [T] represents the data type associated with routes
/// [anyMethodToken] is the token used to represent any HTTP method, defaults to 'routerkit-method://any'
/// [caseSensitive] determines whether path matching is case sensitive, defaults to true
Router<T> createRouter<T>({
  String anyMethodToken = 'routerkit-method://any',
  bool caseSensitive = true,
}) {
  return _RouterImpl<T>(
    anyMethodToken: anyMethodToken,
    caseSensitive: caseSensitive,
  );
}

/// Internal implementation of Router interface
class _RouterImpl<T> implements Router<T> {
  /// Creates a new router instance
  ///
  /// [anyMethodToken] is the token used to represent any HTTP method
  /// [caseSensitive] determines whether path matching is case sensitive
  _RouterImpl({required this.anyMethodToken, required this.caseSensitive});

  /// Token used to represent any HTTP method
  @override
  final String anyMethodToken;

  /// Whether path matching is case sensitive
  @override
  final bool caseSensitive;

  /// Root node
  final _root = _RouterNode<T>('');

  /// Static route mapping for quick lookup
  final _staticRoutes = <String, _RouterNode<T>>{};

  /// Adds a new route to the router
  ///
  /// [method] HTTP method like 'GET', 'POST', etc. If null, matches any method
  /// [path] Route path pattern
  /// [data] Data associated with this route
  @override
  void add(String? method, String path, T data) {
    // Normalize HTTP method to uppercase
    final normalizedMethod = method?.toUpperCase();

    // Special handling for format parameters like ':filename.:format' and ':filename.:format?'
    String processedPath = path;
    Map<String, String>? formatParams;

    if (path.contains('.') && path.contains(':')) {
      // We might have a path with format parameter like '/files/:filename.:format?' or '/files/:filename.:format'
      print('DEBUG ADD: Found potential format parameter in path: $path');
      final parts = path.split('/');
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (part.startsWith(':') && part.contains('.')) {
          // Found a potential format parameter segment
          print('DEBUG ADD: Found format parameter segment: $part at index $i');
          final paramParts = part.split('.');
          if (paramParts.length == 2) {
            // We have ':name.:format' or ':name.:format?' pattern
            final paramName = paramParts[0];
            final formatPart = paramParts[1];
            final isOptional = formatPart.endsWith('?');
            final formatParam = isOptional
                ? formatPart.substring(0, formatPart.length - 1)
                : formatPart;

            print(
                'DEBUG ADD: Parsed format parameter: paramName=$paramName, formatParam=$formatParam, isOptional=$isOptional');

            // Replace with a simple parameter for the router
            parts[i] = paramName;

            // Store format information for later use
            // The actual parameter index will be i-1 if the path starts with a slash (which it usually does)
            // because the first element in the split result will be empty
            final paramIndex = path.startsWith('/') ? i - 1 : i;
            formatParams = {
              'paramIndex': paramIndex.toString(),
              'formatName': formatParam.substring(1), // Remove the ':' prefix
              'isOptional': isOptional.toString()
            };
            print('DEBUG ADD: Created formatParams: $formatParams');
          }
        }
      }
      processedPath = parts.join('/');
      print('DEBUG ADD: Processed path: $processedPath');
    }

    final segments = _pathToSegments(processedPath);
    final params = <_ParamInfo>[];

    var node = _root;
    var unnamedParamIndex = 0;

    for (final (index, segment) in segments.indexed) {
      // Handle wildcard path segment (like ** or **:name)
      if (segment.startsWith('**')) {
        node = node.wildcard ??= _RouterNode('**');
        final wildcardName =
            segment.contains(':') ? segment.split(':')[1] : '_';
        params.add(_ParamInfo(
          index: index,
          name: wildcardName,
          optional: false, // Wildcards are always required
        ));

        // Important: For wildcard segments, we stop traversing
        // as the wildcard captures all remaining segments
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

    // Add format parameter information if present
    if (formatParams != null) {
      // Add a special parameter that indicates this is a format parameter
      final paramIndexStr = formatParams['paramIndex']!;
      final paramIndex = int.parse(paramIndexStr);
      final formatName = formatParams['formatName']!;
      final isOptional = formatParams['isOptional'] == 'true';

      print(
          'DEBUG ADD: Adding format info to param at index $paramIndex: formatName=$formatName, isOptional=$isOptional');
      print('DEBUG ADD: Params before adding format info: $params');

      // Find the parameter at the specified index
      for (final param in params) {
        print(
            'DEBUG ADD: Checking param at index ${param.index} with name ${param.name}');
        if (param.index == paramIndex) {
          // Add format information to this parameter
          param.formatInfo = {
            'name': formatName,
            'optional': isOptional.toString()
          };
          print('DEBUG ADD: Added format info to param: ${param.formatInfo}');
          break;
        }
      }

      print('DEBUG ADD: Params after adding format info: $params');
    }

    // Add route data to the node
    final routeData = _RouteData(
      data: data,
      params: params.isNotEmpty ? params : null,
    );

    // Only add the route if it doesn't already exist for this method
    if (!(node.methods?[normalizedMethod ?? anyMethodToken]
            ?.any((r) => r.data == data) ??
        false)) {
      (node.methods ??= {})[normalizedMethod ?? anyMethodToken] =
          ((node.methods?[normalizedMethod ?? anyMethodToken] ?? [])
            ..add(routeData));
    }

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
  @override
  MatchedRoute<T>? find(String? method, String path,
      {bool includeParams = true}) {
    // Normalize HTTP method to uppercase
    final normalizedMethod = method?.toUpperCase();
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);

    // 1. Look for static routes
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;

      // First check for exact method match
      final methodValues = node.methods?[normalizedMethod];
      if (methodValues != null && methodValues.isNotEmpty) {
        final params = includeParams
            ? _extractParams(methodValues.first.params, segments)
            : null;
        // If params extraction failed (e.g., required format parameter not found), return null
        if (includeParams &&
            methodValues.first.params != null &&
            params == null) {
          return null;
        }
        return MatchedRoute(
          data: methodValues.first.data,
          params: params,
        );
      }

      // Then check for wildcard method match (method is null)
      final wildcardMethodValues = node.methods?[anyMethodToken];
      if (wildcardMethodValues != null && wildcardMethodValues.isNotEmpty) {
        final params = includeParams
            ? _extractParams(wildcardMethodValues.first.params, segments)
            : null;
        // If params extraction failed, return null
        if (includeParams &&
            wildcardMethodValues.first.params != null &&
            params == null) {
          return null;
        }
        return MatchedRoute(
          data: wildcardMethodValues.first.data,
          params: params,
        );
      }
    }

    // 2. Look in the route tree
    final match =
        _findInTree(_root, normalizedMethod, segments, 0)?.firstOrNull;
    if (match == null) return null;

    final params =
        includeParams ? _extractParams(match.params, segments) : null;
    // If params extraction failed, return null
    if (includeParams && match.params != null && params == null) {
      return null;
    }

    return MatchedRoute(
      data: match.data,
      params: params,
    );
  }

  /// Find all routes matching the given path and method
  ///
  /// [method] HTTP method to match. If null, matches any method
  /// [path] Path to match
  /// [includeParams] Whether to include matched parameters in the result, defaults to true
  ///
  /// Returns a list of all matching routes
  @override
  List<MatchedRoute<T>> findAll(String? method, String path,
      {bool includeParams = true}) {
    // Normalize HTTP method to uppercase
    final normalizedMethod = method?.toUpperCase();
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);
    final result = <MatchedRoute<T>>[];

    // Track already added route data to avoid duplicates
    final addedRouteData = <T>{};

    // Internal helper method to add routes without duplicates
    void addUniqueMatchedRoutes(List<_RouteData<T>> routeDataList) {
      for (final routeData in routeDataList) {
        // Only add if not already in the result
        if (!addedRouteData.contains(routeData.data)) {
          addedRouteData.add(routeData.data);
          result.add(MatchedRoute(
            data: routeData.data,
            params: includeParams
                ? _extractParams(routeData.params, segments)
                : null,
          ));
        }
      }
    }

    // 1. Look for static routes
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;

      // Add exact method matches
      if (normalizedMethod != null &&
          node.methods?.containsKey(normalizedMethod) == true) {
        addUniqueMatchedRoutes(node.methods![normalizedMethod] ?? []);
      }

      // Add wildcard method matches
      if (node.methods?.containsKey(anyMethodToken) == true) {
        addUniqueMatchedRoutes(node.methods![anyMethodToken] ?? []);
      }

      // If request method is null, add routes for all methods
      if (normalizedMethod == null && node.methods != null) {
        for (final entry in node.methods!.entries) {
          if (entry.key != anyMethodToken) {
            // Skip wildcard method since it's already added
            addUniqueMatchedRoutes(entry.value);
          }
        }
      }
    }

    // 2. Collect all matches from the route tree
    // Only process non-static routes to avoid duplicates
    final treeMatches =
        _collectMatchesNonStatic(_root, normalizedMethod, segments, 0);
    addUniqueMatchedRoutes(treeMatches);

    return result;
  }

  /// Remove a route from the router
  ///
  /// [method] HTTP method to remove. If null, matches any method
  /// [path] Route path to remove
  /// [data] Optional, if provided, only removes the route if the route data matches
  ///
  /// Returns whether a route was removed
  @override
  bool remove(String? method, String path, [T? data]) {
    // Normalize HTTP method to uppercase
    final normalizedMethod = method?.toUpperCase();
    final segments = _pathToSegments(path);
    final normalizedPath = _segmentsToPath(segments);

    // 1. Check static routes
    if (_staticRoutes.containsKey(normalizedPath)) {
      final node = _staticRoutes[normalizedPath]!;
      final removed = _removeFromNode(node, normalizedMethod, data);
      if (removed && node.isEmpty) {
        _staticRoutes.remove(normalizedPath);
      }
      return removed;
    }

    // 2. Remove from the route tree
    return _removeFromTree(_root, normalizedMethod, segments, 0, data);
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
        if (node.methods!.containsKey(anyMethodToken)) {
          return node.methods![anyMethodToken];
        }

        // If method is null, should return null as caller needs to manually handle all methods
        if (method == null) {
          return null;
        }
      }
      return null;
    }

    final segment = segments[index];
    final matches = <_RouteData<T>>[];

    // 1. Try static match - highest priority
    if (node.static.containsKey(segment)) {
      final staticMatch = _findInTree(
        node.static[segment]!,
        method,
        segments,
        index + 1,
      );
      if (staticMatch != null) {
        matches.addAll(staticMatch);
        // If we found a static match, return it immediately for correct priority
        return matches.isNotEmpty ? matches : null;
      }
    }

    // 2. Try parameter match - medium priority
    if (node.param != null && matches.isEmpty) {
      final paramMatch = _findInTree(
        node.param!,
        method,
        segments,
        index + 1,
      );
      if (paramMatch != null) {
        matches.addAll(paramMatch);
        // If we found a parameter match, return it immediately if no static match
        return matches.isNotEmpty ? matches : null;
      }
    }

    // 3. Try wildcard match - lowest priority
    if (node.wildcard != null && matches.isEmpty) {
      // For wildcard match, we need to handle the remaining segments
      if (node.wildcard!.methods != null) {
        // First check for exact method match
        if (method != null && node.wildcard!.methods!.containsKey(method)) {
          return node.wildcard!.methods![method];
        }

        // Then check for wildcard method match
        if (node.wildcard!.methods!.containsKey(anyMethodToken)) {
          return node.wildcard!.methods![anyMethodToken];
        }

        // If method is null, gather all methods except wildcard
        if (method == null) {
          final allMatches = <_RouteData<T>>[];
          for (final entry in node.wildcard!.methods!.entries) {
            if (entry.key != anyMethodToken) {
              allMatches.addAll(entry.value);
            }
          }
          if (allMatches.isNotEmpty) {
            return allMatches;
          }
        }
      }
    }

    return matches.isNotEmpty ? matches : null;
  }

  // Internal method: Collect matches from the route tree, excluding static routes
  // that were already processed by the static routes lookup
  List<_RouteData<T>> _collectMatchesNonStatic(
    _RouterNode<T> node,
    String? method,
    List<String> segments,
    int index,
  ) {
    final matches = <_RouteData<T>>[];

    // When reaching the end of the path
    if (index == segments.length) {
      // Skip this node if it's a static route that was already processed
      if (_staticRoutes.containsKey(_segmentsToPath(segments))) {
        return matches;
      }

      // 1. Check current node
      if (node.methods != null) {
        // Add exact method matches
        if (method != null && node.methods!.containsKey(method)) {
          matches.addAll(node.methods![method] ?? []);
        }

        // Add wildcard method matches
        if (node.methods!.containsKey(anyMethodToken)) {
          matches.addAll(node.methods![anyMethodToken] ?? []);
        }

        // If method is null, add all method matches
        if (method == null && node.methods != null) {
          for (final entry in node.methods!.entries) {
            if (entry.key != anyMethodToken) {
              // Skip wildcard method since it's already added
              matches.addAll(entry.value);
            }
          }
        }
      }
      return matches;
    }

    final segment = segments[index];
    final staticMatches = <_RouteData<T>>[];
    final paramMatches = <_RouteData<T>>[];
    final wildcardMatches = <_RouteData<T>>[];

    // 1. Try static match
    if (node.static.containsKey(segment)) {
      staticMatches.addAll(_collectMatchesNonStatic(
        node.static[segment]!,
        method,
        segments,
        index + 1,
      ));
    }

    // 2. Try parameter match
    if (node.param != null) {
      paramMatches.addAll(_collectMatchesNonStatic(
        node.param!,
        method,
        segments,
        index + 1,
      ));
    }

    // 3. Try wildcard match
    if (node.wildcard != null) {
      // For wildcard match in collection, check if we have methods
      if (node.wildcard!.methods != null) {
        // Add exact method matches
        if (method != null && node.wildcard!.methods!.containsKey(method)) {
          wildcardMatches.addAll(node.wildcard!.methods![method] ?? []);
        }

        // Add wildcard method matches (method is anyMethodToken)
        if (node.wildcard!.methods!.containsKey(anyMethodToken)) {
          wildcardMatches.addAll(node.wildcard!.methods![anyMethodToken] ?? []);
        }

        // If method is null, add all method matches except wildcard
        if (method == null) {
          for (final entry in node.wildcard!.methods!.entries) {
            if (entry.key != anyMethodToken) {
              wildcardMatches.addAll(entry.value);
            }
          }
        }
      }
    }

    // Add matches in order of priority: static, parameter, wildcard
    matches.addAll(staticMatches);
    matches.addAll(paramMatches);
    matches.addAll(wildcardMatches);

    return matches;
  }

  // Internal method: Remove route data from a node
  bool _removeFromNode(_RouterNode<T> node, String? method, T? data) {
    if (node.methods == null) return false;

    final methodValues = node.methods![method ?? anyMethodToken];
    if (methodValues == null) return false;

    final initialLength = methodValues.length;
    methodValues.removeWhere((r) => data == null || r.data == data);

    if (methodValues.isEmpty) {
      node.methods!.remove(method ?? anyMethodToken);
    }

    if (node.methods!.isEmpty) {
      node.methods = null;
    }

    return methodValues.length < initialLength;
  }

  // Internal method: Remove route data from the route tree
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

    // 1. Try static match
    if (node.static.containsKey(segment)) {
      final removed = _removeFromTree(
        node.static[segment]!,
        method,
        segments,
        index + 1,
        data,
      );
      if (removed && node.static[segment]!.isEmpty) {
        node.static.remove(segment);
      }
      if (removed) return true;
    }

    // 2. Try parameter match
    if (node.param != null) {
      final removed = _removeFromTree(
        node.param!,
        method,
        segments,
        index + 1,
        data,
      );
      if (removed && node.param!.isEmpty) {
        node.param = null;
      }
      if (removed) return true;
    }

    // 3. Try wildcard match
    if (node.wildcard != null) {
      final removed = _removeFromTree(
        node.wildcard!,
        method,
        segments,
        index + 1,
        data,
      );
      if (removed && node.wildcard!.isEmpty) {
        node.wildcard = null;
      }
      if (removed) return true;
    }

    return false;
  }

  // Internal method: Convert path to segments
  List<String> _pathToSegments(String path) {
    // Step 1: Normalize the path
    final normalizedPath = _normalizePath(path);

    // Step 2: Extract path segments
    final segments = _extractPathSegments(normalizedPath);

    // Step 3: Apply case sensitivity rules if needed
    return _applyCaseSensitivityRules(segments);
  }

  // Helper method: Normalize path by removing trailing slashes and query params
  String _normalizePath(String path) {
    // Remove trailing slash if not root path
    final withoutTrailingSlash = path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;

    // Remove query parameters and fragments
    return withoutTrailingSlash.split('?')[0].split('#')[0];
  }

  // Helper method: Extract path segments from normalized path
  List<String> _extractPathSegments(String normalizedPath) {
    // Split path into segments and remove empty segments
    return normalizedPath.split('/').where((s) => s.isNotEmpty).toList();
  }

  // Helper method: Apply case sensitivity rules to segments
  List<String> _applyCaseSensitivityRules(List<String> segments) {
    if (caseSensitive) {
      return segments;
    }

    // Create a new list to avoid modifying the input
    final result = <String>[];

    for (final segment in segments) {
      // Only convert non-parameter segments to lowercase
      if (!segment.startsWith(':') && !segment.startsWith('*')) {
        result.add(segment.toLowerCase());
      } else {
        result.add(segment);
      }
    }

    return result;
  }

  // Internal method: Convert segments to path
  String _segmentsToPath(List<String> segments) {
    return '/${segments.join('/')}';
  }

  // Internal method: Create parameter pattern
  String _createParamPattern(String segment) {
    // Return the original parameter name without ':' prefix, preserving case
    return segment.substring(1);
  }

  // Internal method: Extract parameters from segments
  Map<String, String>? _extractParams(
    List<_ParamInfo>? params,
    List<String> segments,
  ) {
    if (params == null || params.isEmpty) return null;

    final result = <String, String>{};
    var unnamedIndex = 0;

    for (final param in params) {
      // Check if segment exists for this parameter
      if (param.index >= segments.length) {
        if (!param.optional) return null; // Required parameter missing
        continue;
      }

      final value = segments[param.index];

      // Process different parameter types based on their characteristics
      if (param.formatInfo != null) {
        // Handle format parameters (e.g. :filename.:format)
        if (!_processFormatParameter(param, value, result)) {
          return null; // Format parameter processing failed
        }
      } else if (param.name == '_') {
        // Handle unnamed wildcard parameters (**)
        _processWildcardParameter(param, segments, result, unnamedIndex++);
      } else if (param.name.isNotEmpty) {
        // Handle regular named parameters (:name)
        _processNamedParameter(param, segments, result);
      }
    }

    return result;
  }

  // Helper method: Process format parameters like ':filename.:format'
  bool _processFormatParameter(
      _ParamInfo param, String value, Map<String, String> result) {
    final formatName = param.formatInfo!['name']!;
    final isOptional = param.formatInfo!['optional'] == 'true';

    // If the value contains a dot, split it to extract format
    if (value.contains('.')) {
      final valueParts = value.split('.');
      if (valueParts.length == 2) {
        // Store the main parameter value (before the dot)
        result[param.name] = valueParts[0];
        // Store the format parameter value (after the dot)
        result[formatName] = valueParts[1];
        return true;
      }
    }

    // If no dot in value, just use the whole value for the parameter
    result[param.name] = value;

    // If format is required but not found, return false to indicate failure
    if (!isOptional) {
      return false;
    }

    return true;
  }

  // Helper method: Process wildcard parameters (**)
  void _processWildcardParameter(_ParamInfo param, List<String> segments,
      Map<String, String> result, int unnamedIndex) {
    if (param.index < segments.length) {
      // For wildcards, we combine all remaining segments
      final remainingSegments = segments.sublist(param.index);
      result['_$unnamedIndex'] = remainingSegments.join('/');
    }
  }

  // Helper method: Process named parameters (:name)
  void _processNamedParameter(
      _ParamInfo param, List<String> segments, Map<String, String> result) {
    if (param.index < segments.length) {
      if (segments[0].startsWith('**:')) {
        // For named wildcards like '**:path', combine all segments
        final remainingSegments = segments.sublist(param.index);
        result[param.name] = remainingSegments.join('/');
      } else {
        // Regular named parameter
        result[param.name] = segments[param.index];
      }
    }
  }

  /// For debugging only - exposes the internal root node
  _RouterNode<T> debugGetRootNode() => _root;
}

/// Internal class: Router node
class _RouterNode<T> {
  _RouterNode(this.segment);

  final String segment;

  final static = <String, _RouterNode<T>>{};
  _RouterNode<T>? param;
  _RouterNode<T>? wildcard;
  Map<String, List<_RouteData<T>>>? methods;

  bool get isEmpty =>
      static.isEmpty && param == null && wildcard == null && methods == null;
}

/// Internal class: Route data
class _RouteData<T> {
  _RouteData({
    required this.data,
    this.params,
  });

  final T data;
  final List<_ParamInfo>? params;
}

/// Internal class: Parameter info
class _ParamInfo {
  _ParamInfo({
    required this.index,
    required this.name,
    required this.optional,
  });

  final int index;
  final String name;
  final bool optional;

  // Format parameter info for special cases like ':filename.:format?'
  Map<String, String>? formatInfo;
}
