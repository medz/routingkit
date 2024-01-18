import '../segment.dart';

/// Describes a node that has matched a parameter or anything.
class Wildcard<T> {
  final Node<T> node;

  //------------------ Internals -------------------//
  bool _explicitlyIncludesAnything = false;
  String? _parameter;
  //------------------------------------------------//

  bool get explicitlyIncludesAnything => _explicitlyIncludesAnything;
  String? get parameter => _parameter;

  Wildcard(this.node);

  factory Wildcard.anything(Node<T> node) =>
      Wildcard(node)..explicitlyIncludeAnything();

  factory Wildcard.parameter(Node<T> node, String parameter) =>
      Wildcard(node)..setParameter(parameter);

  /// Update the wildcard to match a new parameter name
  void setParameter(String parameter) => this._parameter = parameter;

  /// Explicitly include anything
  void explicitlyIncludeAnything() => _explicitlyIncludesAnything = true;
}

/// A single node of the `Router`s trie tree of routes.
class Node<T> {
  /// All constant child nodes.
  final Map<String, Node<T>> constants = {};

  /// Wildcard child node that may be a named parameter or an anything
  /// wildcard.
  Wildcard<T>? wildcard;

  /// Catchall node, if one exists.
  ///
  /// This is a special node that matches any path segment.
  Node<T>? catchAll;

  /// The node value.
  T? value;

  /// Create a new node.
  Node([this.value]);

  /// Returns the child router node for the supplied [Segment] or
  /// creates a new segment onto the tree if necessary.
  Node<T> childOrCreate(Segment segment, bool caseSensitive) {
    return switch (segment) {
      ConstSegment(value: final value) =>
        _createConstantChild(value, caseSensitive),
      ParamSegment(name: final params) => _createWildcard(params),
      CatchallSegment _ => _createCatchall(),
      AnySegment _ => _createAnything(),
    };
  }
}

/// Internal extension methods for [Node].
extension<T> on Node<T> {
  /// Creates a new anything child node.
  Node<T> _createAnything() {
    wildcard = switch (wildcard) {
      Wildcard<T> wildcard => wildcard..explicitlyIncludeAnything(),
      _ => Wildcard<T>.anything(Node()),
    };

    return wildcard!.node;
  }

  /// Creates a new catchall child node.
  Node<T> _createCatchall() {
    return catchAll = switch (catchAll) {
      Node<T> catchAll => catchAll,
      _ => Node<T>(),
    };
  }

  /// Creates a new wildcard child node.
  Node<T> _createWildcard(String parameter) {
    wildcard = switch (wildcard) {
      null => Wildcard<T>.parameter(Node(), parameter),
      Wildcard<T> wildcard => _updateWildcardParameter(wildcard, parameter),
    };

    return wildcard!.node;
  }

  /// Updates the wildcard parameter.
  Wildcard<T> _updateWildcardParameter(Wildcard<T> wildcard, String parameter) {
    assert(
        wildcard.parameter == parameter,
        'Wildcard parameter mismatch: '
        '${wildcard.parameter} != $parameter');

    return wildcard..setParameter(parameter);
  }

  /// Creates a new constant child node.
  Node<T> _createConstantChild(String constant, bool caseSensitive) {
    final value = caseSensitive ? constant : constant.toLowerCase();

    return constants.putIfAbsent(value, () => Node());
  }
}
