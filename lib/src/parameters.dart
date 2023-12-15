class Parameters {
  //------ Internals ------
  final _values = <String, String>{};
  _Catchall? _catchall;
  //-----------------------

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

  /// Returns the components matched by the catchall.(**)
  ///
  /// If no catch all was matched, an empty list is returned.
  ///
  /// you can judge whether `catchAll` is hit using:
  ///
  /// ```dart
  /// final catchAll = parameters.getCatchall();
  ///
  /// if (catchAll.isEmpty) {
  ///   // no catch all was matched.
  /// }
  /// ```
  Iterable<String> getCatchall() {
    if (_catchall?.encoded == true) {
      final values = _catchall!.values.map((e) => e.decodeComponent());
      _catchall = _Catchall(values, false);
    }

    return _catchall?.values ?? const {};
  }

  /// Stores the components matched by the catchall.(**)
  ///
  /// - [values]: The values to store.
  /// - [encoded]: Whether the values are encoded.
  void setCatchall(Iterable<String> values) {
    _catchall = _Catchall(values);
  }
}

class _Catchall {
  final Iterable<String> values;
  final bool encoded;

  const _Catchall(this.values, [this.encoded = true]);
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
