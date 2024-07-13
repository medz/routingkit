import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter();

  addRoute(router, 'get', '/path', 'Static path');
  addRoute(router, 'get', '/path/:name', 'Param route');
  addRoute(router, 'get', '/path/**', 'Wildcard route');
  addRoute(router, 'get', '/path/**:name', 'Named wildcard route');
  addRoute(
      router, 'get', '/files/:dir/:filename.:format,v:version', 'Mixed route');

  // Static
  // print(findRoute(router, 'get', '/path'));

  // // Param
  // print(findRoute(router, 'get', '/path/seven'));

  // // Wildcard
  // print(findRoute(router, "GET", "/path/foo/bar/baz"));

  // // Mixed

  // print(router.root.static['files']);
  print(findRoute(router, "GET", "/files/pubspec.yaml.dart,v1"));
}
