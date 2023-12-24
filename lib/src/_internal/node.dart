import '../segment.dart';

const space = '    ';
const rightArrow = '→';

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

  /// Returns the child router node for the supplied [PathComponent] or
  /// creates a new segment onto the tree if necessary.
  Node<T> childOrCreate(Segment segment, bool caseSensitive) {
    return switch (segment) {
      ConstSegment(value: final value) =>
        _createConstantChild(value, caseSensitive),
      ParamSegment(name: final value) => _createWildcard(value),
      CatchallSegment() => _createCatchall(),
      AnySegment() => _createAnything(),
    };
  }

  /// Returns sub path of the trie tree that matches the supplied path
  /// descriptions.
  Iterable<String> get subPathDescriptions sync* {
    for (final MapEntry(key: name, value: constant) in constants.entries) {
      yield "$rightArrow $name";
      yield* constant.subPathDescriptions.indented();
    }

    if (wildcard?.parameter != null) {
      yield "$rightArrow :${wildcard!.parameter}";
      yield* wildcard!.node.subPathDescriptions.indented();
    }

    if (wildcard?.explicitlyIncludesAnything == true) {
      yield "$rightArrow *";
      yield* wildcard!.node.subPathDescriptions.indented();
    }

    if (catchAll != null) {
      yield "$rightArrow **";
    }
  }

  /// Returns the node description.
  String get description => subPathDescriptions.join('\n');
}

/// indented of string iterable.
extension on Iterable<String> {
  Iterable<String> indented() => map((e) => '$space$e');
}

/// Internal extension methods for [Node].
extension<T> on Node<T> {
  /// Creates a new anything child node.
  Node<T> _createAnything() {
    final wildcard = this.wildcard = switch (this.wildcard) {
      null => Wildcard<T>.anything(Node()),
      Wildcard<T> wildcard => wildcard..explicitlyIncludeAnything(),
    };

    return wildcard.node;
  }

  /// Creates a new catchall child node.
  Node<T> _createCatchall() {
    return catchAll = switch (catchAll) {
      null => Node(),
      Node<T> catchAll => catchAll,
    };
  }

  /// Creates a new wildcard child node.
  Node<T> _createWildcard(String parameter) {
    final wildcard = this.wildcard = switch (this.wildcard) {
      null => Wildcard<T>.parameter(Node(), parameter),
      Wildcard<T> wildcard => _updateWildcardParameter(wildcard, parameter),
    };

    return wildcard.node;
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
