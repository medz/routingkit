import 'package:logging/logging.dart';

class Parameters {
  late final Logger logger;

  //------ Internals ------
  final _values = <String, String>{};
  _CatchAll? _catchAll;
  //-----------------------

  Parameters([Logger? logger]) {
    this.logger = logger ?? Logger('trie-router');
  }

  /// Returns all parameters names.
  Set<String> get allNames => _values.keys.toSet();

  /// Returns the named parameter value.
  ///
  /// For example, if the path is `/users/:id` and the path is `/users/123`,
  /// would be using:
  /// ```dart
  /// final String? id = parameters.get('id');
  /// ```
  String? get(String name) => _values[name];

  /// Returns the named parameter value casted to [T].
  ///
  /// For example, if the path is `/users/:id` and the path is `/users/123`,
  /// casting to [int] would be using:
  /// ```dart
  /// final int id = parameters.get<int>('id', int.parse);
  /// ```
  T? getAs<T>(String name, T Function(String) cast) {
    return switch (get(name)) {
      String value => cast(value),
      _ => null,
    };
  }

  /// Adds a new parameter value.
  ///
  /// ## Parameters
  /// - [name]: The parameter name.
  /// - [value]: The parameter value.
  /// - [encoded]: Whether the value is encoded.
  void set(String name, String value) {
    _values[name] = value.decodeComponent();
  }

  /// Returns the components matched by the catch all.(**)
  ///
  /// If no catch all was matched, an empty list is returned.
  ///
  /// you can judge whether `catchAll` is hit using:
  ///
  /// ```dart
  /// final catchAll = parameters.getCatchAll();
  ///
  /// if (catchAll.isEmpty) {
  ///   // no catch all was matched.
  /// }
  /// ```
  Iterable<String> getCatchAll() {
    if (_catchAll?.encoded == true) {
      final values = _catchAll!.values.map((e) => e.decodeComponent());
      _catchAll = _CatchAll(values, false);
    }

    return _catchAll?.values ?? const {};
  }

  /// Stores the components matched by the catch all.(**)
  ///
  /// - [values]: The values to store.
  /// - [encoded]: Whether the values are encoded.
  void setCatchAll(Iterable<String> values) {
    _catchAll = _CatchAll(values);
  }
}

class _CatchAll {
  final Iterable<String> values;
  final bool encoded;

  const _CatchAll(this.values, [this.encoded = true]);
}

extension on String {
  /// Decodes the string as a URI component.
  String decodeComponent() {
    try {
      return Uri.decodeComponent(this);
    } on ArgumentError {
      return this;
    }
  }
}
