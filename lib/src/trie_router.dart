import 'package:logging/logging.dart';

import 'configuration_options.dart';
import '_internal/node.dart';
import 'params.dart';
import 'segment.dart';
import 'router.dart';

/// Generic [TrieRouter] built using the `trie` tree algorithm.
///
/// - Use [register] to register routes into the router.
/// - Use [lookup] to then lookup a matching route.
class TrieRouter<T> implements Router<T> {
  /// The trie router configuration options.
  final ConfigurationOptions options;

  /// The trie router logger.
  late final Logger logger;

  /// The root node of the trie tree.
  final Node<T> _root = Node();

  /// Create a new trie router.
  TrieRouter({
    this.options = const ConfigurationOptions(),
    Logger? logger,
  }) {
    this.logger = logger ?? Logger('trie-router');
  }

  @override
  T? lookup(Iterable<String> path, Params parameters) {
    Node<T> currentNode = _root;
    (Node<T>, Iterable<String>)? currentCatchAll;

    // traverse the string path supplied
    for (final (index, segment) in path.indexed) {
      // Store catch all if it exists
      if (currentNode.catchAll != null) {
        currentCatchAll = (currentNode.catchAll!, path.skip(index));
      }

      // Match the segment of constants.
      final constant = currentNode
          .constants[options.caseSensitive ? segment : segment.toLowerCase()];
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
          parameters.append(wildcard.parameter!, segment);
        }

        currentNode = wildcard.node;
        continue;
      }

      // No matches, return catch all if we have one
      if (currentCatchAll case (Node<T> catchAll, Iterable<String> values)) {
        // fallback to catchall output if we have one
        parameters.catchall = values;

        return catchAll.value;
      }

      // No matches, return null
      return null;
    }

    if (currentNode.value != null) return currentNode.value;
    if (currentCatchAll case (Node<T> catchAll, Iterable<String> values)) {
      // fallback to catchall output if we have one
      parameters.catchall = values;

      return catchAll.value;
    }

    return null;
  }

  @override
  void register(T value, Iterable<Segment> segments) {
    assert(segments.isNotEmpty, 'Segments cannot be empty');

    // Start at the root of the trie tree
    Node current = _root;

    // for each dynamic path in the route get the appropriate node,
    // creating it if it doesn't exist.
    for (final (index, component) in segments.indexed) {
      if (component is CatchallSegment && index < segments.length - 1) {
        throw ArgumentError.value(
            component, 'path', 'Catchall must be the last segment');
      }

      current = current.childOrCreate(component, options);
    }

    // If the node already has a value, it means that the route is duplicated.
    if (current.value != null) {
      logger.info(
          'Overriding duplicate route for ${segments.elementAt(0)} ${segments.skip(1)}');
    }

    current.value = value;
  }

  /// Returns the node description.
  String get description => _root.description;
}
