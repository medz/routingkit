import '../constants.dart';
import '../params.dart';
import '../router.dart';
import '../router_options.dart';
import 'path_segment.dart';
import 'route_radix_trie_node.dart';

class RadixTrieRouter<T> implements Router<T> {
  const RadixTrieRouter({required this.node, required this.options});

  final RouteRadixTrieNode<T> node;
  final RouterOptions options;

  @override
  MatchedRoute<T> lookup(String path) {
    final pathSegments = splitPathSegments(path);
    final params = Params();
    final namedParams = <(WildcardRouteRadixTrieNode<T>, String)>[];

    Iterable<String>? catchall;
    RouteRadixTrieNode<T> current = node;
    for (final (index, pathSegment) in pathSegments.indexed) {
      if (current.catchall != null) {
        catchall = pathSegments.skip(index);
      }

      final constant = current.constants[
          options.caseSensitive ? pathSegment : pathSegment.toLowerCase()];
      if (constant != null) {
        current = constant;
        catchall = null;
        continue;
      }

      final wildcard = current.wildcard;
      if (wildcard != null) {
        namedParams.add((wildcard, pathSegment));
        current = wildcard;
        catchall = null;
        continue;
      }

      break;
    }

    if (current.value == null) return (params, null);
    if (catchall != null && catchall.isNotEmpty) {
      params.add(kCatchall, catchall.join('/'));
    }

    for (final (node, value) in namedParams) {
      final name = node.names[current];
      if (name != null) {
        params.add(name, value);
      }
    }

    return (params, current.value!);
  }

  @override
  void register(String route, T value) {
    final pathSegments = createPathSegments(route);
    final lastPathSegmentIndex = pathSegments.length - 1;
    final wildcardNamedNodes = <(WildcardRouteRadixTrieNode<T>, String)>[];

    RouteRadixTrieNode<T> current = node;
    for (final (index, pathSegment) in pathSegments.indexed) {
      if (pathSegment is CatchallPathSegment && lastPathSegmentIndex != index) {
        throw ArgumentError.value(
            pathSegment, 'path', 'Catchall must be the last segment');
      }

      current = findOrCreateNode(current, pathSegment);

      if (current is WildcardRouteRadixTrieNode<T> &&
          pathSegment is ParamPathSegment) {
        wildcardNamedNodes.add((current, pathSegment.name));
      }
    }

    current.value = value;

    for (final (node, name) in wildcardNamedNodes) {
      node.names[current] = name;
    }
  }

  @override
  void remove(String route) {
    final pathSegments = createPathSegments(route);

    RouteRadixTrieNode<T>? current = node;
    for (final pathSegment in pathSegments) {
      current = switch (pathSegment) {
        ConstPathSegment(value: final value) => current?.constants[value],
        CatchallPathSegment _ => current?.catchall,
        _ => current?.wildcard,
      };

      if (current == null) return;
    }

    current?.value = null;
    if (current != null) {
      rmeoveNestParentNameOf(current, current);
      cleanNestParentNodeOf(current);
    }
  }
}

extension<T> on RadixTrieRouter<T> {
  Iterable<String> splitPathSegments(String path) {
    return path.split('/').where((e) => e.isNotEmpty);
  }

  Iterable<PathSegment> createPathSegments(String path) {
    return splitPathSegments(path).map(parsePathSegment);
  }

  PathSegment parsePathSegment(String name) {
    assert(!name.contains('/'));

    return switch (name) {
      '*' => const AnyPathSegment(),
      '**' => const CatchallPathSegment(),
      String segment when segment.startsWith(':') =>
        ParamPathSegment(segment.substring(1)),
      String value =>
        ConstPathSegment(options.caseSensitive ? value : value.toLowerCase()),
    };
  }

  RouteRadixTrieNode<T> findOrCreateNode(
      RouteRadixTrieNode<T> node, PathSegment pathSetment) {
    return switch (pathSetment) {
      ConstPathSegment(value: final value) =>
        findOrCreateConstNode(node, value),
      CatchallPathSegment _ => findOrCreateCatchallNode(node),
      _ => findOrCreateWildcardNode(node),
    };
  }

  RouteRadixTrieNode<T> findOrCreateConstNode(
      RouteRadixTrieNode<T> node, String value) {
    final constant = node.constants[value];
    if (constant != null) {
      return constant;
    }

    return node.constants[value] = RouteRadixTrieNode<T>()..parent = node;
  }

  RouteRadixTrieNode<T> findOrCreateCatchallNode(RouteRadixTrieNode<T> node) {
    return node.catchall ??= RouteRadixTrieNode<T>()..parent = node;
  }

  WildcardRouteRadixTrieNode<T> findOrCreateWildcardNode(
      RouteRadixTrieNode<T> node) {
    return node.wildcard ??= WildcardRouteRadixTrieNode<T>()..parent = node;
  }

  void rmeoveNestParentNameOf(
      RouteRadixTrieNode<T> node, RouteRadixTrieNode<T> key) {
    if (node is WildcardRouteRadixTrieNode<T>) {
      node.names.remove(key);
    }

    if (node.parent != null) {
      rmeoveNestParentNameOf(node.parent!, key);
    }
  }

  void cleanNestParentNodeOf(RouteRadixTrieNode<T> node) {
    if (node.catchall == null &&
        node.constants.isEmpty &&
        node.catchall == null &&
        node.value == null) {
      node.parent?.constants.removeWhere((_, e) => e == node);

      if (node.parent?.catchall == node) {
        node.parent?.catchall = null;
      }

      if (node.parent?.wildcard == node) {
        node.parent?.wildcard = null;
      }

      if (node.parent != null) {
        cleanNestParentNodeOf(node.parent!);
      }
    }
  }
}
