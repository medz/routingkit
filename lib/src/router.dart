import 'params.dart';

abstract interface class Router<T> {
  Result<T>? lookup(String path);
  void register(String route, T value);
  void remove(String route);

  String buildPath(
    String route, {
    Map<String, String>? params,
    Iterable<String>? wildcard,
    String? catchall,
  });
}

class Result<T> {
  const Result({
    required this.params,
    required this.value,
    required this.route,
  });

  final T value;
  final Params params;
  final String route;
}
