import 'package:logging/logging.dart';

import '_internal/node.dart';
import 'params.dart';
import 'segment.dart';
import 'router.dart';

/// Generic [TrieRouter] built using the `trie` tree algorithm.
///
/// - Use [register] to register routes into the router.
/// - Use [lookup] to then lookup a matching route.
class TrieRouter<T> implements Router<T> {
  /// Whether to use case sensitive matching
  final bool caseSensitive;

  /// The trie router logger.
  final Logger logger;

  /// The root node of the trie tree.
  final Node<T> _root = Node();

  /// Create a new trie router.
  TrieRouter({
    this.caseSensitive = true,
    Logger? logger,
  }) : logger = logger ?? Logger('Routing Kit');

  @override
  T? lookup(Iterable<String> segments, Params params) {
    Node<T> currentNode = _root;
    (Node<T>, Iterable<String>)? currentCatchall;

    // traverse the string path supplied
    for (final (index, segment) in segments.indexed) {
      // Store catch all if it exists
      if (currentNode.catchAll != null) {
        currentCatchall = (currentNode.catchAll!, segments.skip(index));
      }

      // Match the segment of constants.
      final constant = currentNode.constants[segment.toCase(caseSensitive)];
      if (constant != null) {
        currentNode = constant;
        continue;
      }

      // No constant match, try to match a dynamic members
      // including parameters or anything.
      final wildcard = currentNode.wildcard;
      if (wildcard != null) {
        // If the wildcard is a parameter, add it to the parameters.
        if (wildcard.parameter != null) {
          params.append(wildcard.parameter!, segment);
        }

        currentNode = wildcard.node;
        continue;
      }

      if (currentCatchall != null) {
        params.catchall = currentCatchall.$2;
      }
      return currentCatchall?.$1.value;
    }

    if (currentNode.value != null) {
      return currentNode.value;
    } else if (currentCatchall != null) {
      params.catchall = currentCatchall.$2;
    }

    return currentCatchall?.$1.value;
  }

  @override
  void register(T value, Iterable<Segment> segments) {
    assert(segments.isNotEmpty, 'Segments cannot be empty');

    // Start at the root of the trie tree
    Node current = _root;

    // for each dynamic path in the route get the appropriate node,
    // creating it if it doesn't exist.
    for (final (index, segment) in segments.indexed) {
      if (segment is CatchallSegment && index < segments.length - 1) {
        final error = ArgumentError.value(
            segment, 'path', 'Catchall must be the last segment');
        logger.severe(error.message, error, error.stackTrace);

        throw error;
      }

      current = current.childOrCreate(segment, caseSensitive);
    }

    // If the node already has a value, it means that the route is duplicated.
    if (current.value != null) {
      logger.info('Overriding duplicate route for $segments');
    }

    current.value = value;
  }
}

extension on String {
  String toCase(bool caseSensitive) => caseSensitive ? this : toLowerCase();
}
