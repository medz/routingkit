class Params extends Iterable<(String name, String value)> {
  /// Internal storage.
  final _storage = <(String name, String value)>[];
  _Catchall? _catchall;

  @override
  Iterator<(String, String)> get iterator => _storage.iterator;

  /// Returns a first value for the given [name].
  String? get(name) =>
      firstWhereNull((element) => element.$1 == name)?.$2.tryDecodeComponent();

  /// Returns all values for the given [name].
  Iterable<String> getAll(name) => where((element) => element.$1 == name)
      .map((e) => e.$2.tryDecodeComponent());

  /// Appends a new parameter value.
  void append(String name, String value) => _storage.add((name, value));

  /// Returns or sets the catchall segment matched values.
  Iterable<String> get catchall {
    if (_catchall?.encoded == true) {
      _catchall = _Catchall(
        encoded: false,
        _catchall!.values.map((e) => e.tryDecodeComponent()),
      );
    }

    return _catchall?.values ?? const <String>[];
  }

  /// Sets the catchall segment matched values.
  set catchall(Iterable<String> values) =>
      _catchall = _Catchall(values, encoded: true);

  /// Returns the param names.
  Iterable<String> get keys => map((e) => e.$1);
}

class _Catchall {
  final Iterable<String> values;
  final bool encoded;

  const _Catchall(this.values, {this.encoded = false});
}

extension<T> on Iterable<T> {
  T? firstWhereNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}

extension on String {
  String tryDecodeComponent() {
    try {
      return Uri.decodeComponent(this);
    } catch (_) {
      return this;
    }
  }
}
