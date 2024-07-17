import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter<String>();

  addRoute(router, 'get', '/path', 'Static path');
  addRoute(router, 'get', '/path/:name', 'Param route');
  addRoute(router, 'get', '/path/**', 'Wildcard route');
  addRoute(router, 'get', '/path/**:name', 'Named wildcard route');
  addRoute(
      router, 'get', '/files/:dir/:filename.:format,v:version', 'Mixed route');

  // Static
  final static = findRoute(router, 'get', '/path')?.lastOrNull;
  print('GET /path, ${static?.data}');

  // Param
  final paramRoute = findRoute(router, 'get', '/path/seven')?.lastOrNull;
  print(
    'GET /path/:name, ${paramRoute?.data}, name: ${paramRoute?.params.get('name')}',
  );

  // Wildcard
  final wildcard = findRoute(router, "get", "/path/foo/bar/baz")?.lastOrNull;
  print('GET /path/**, ${wildcard?.data}, ${wildcard?.params.catchall}');

  // Mixed
  print(findRoute(router, "GET", "/files/pubspec.yaml.dart,v1")
      ?.lastOrNull
      ?.data);
}
