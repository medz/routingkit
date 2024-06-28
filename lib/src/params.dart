import 'constants.dart';

class Params extends Iterable<(String name, String value)> {
  final _storage = <(String name, String value)>[];

  @override
  Iterator<(String name, String value)> get iterator => _storage.iterator;

  void add(String name, String value) {
    if (name == kCatchall) {
      _storage.removeWhere((element) => element.$1 == kCatchall);
    }

    _storage.add((name, value));
  }

  void remove(String name, [String? value]) {
    _storage.removeWhere(
      (e) => switch ((name, value)) {
        (String name, String value) => e.$1 == name && e.$2 == value,
        (String name, _) => e.$1 == name,
      },
    );
  }

  String? call(String name) {
    return firstWhereNull((element) => element.$1 == name)?.$2;
  }

  Iterable<String> valuesOf(String name) {
    return where((element) => element.$1 == name).map((e) => e.$2);
  }

  String? get catchall => this(kCatchall);
}

extension<T> on Iterable<T> {
  T? firstWhereNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
