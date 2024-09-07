import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter<String>();

  addRoute(router, 'GET', '/path', 'static route');
  addRoute(router, 'POST', '/path/:name', 'name route');
  addRoute(router, 'GET', '/path/foo/**', 'wildcard route');
  addRoute(router, 'GET', '/path/foo/**:name', 'named wildcard route');

  print(findRoute(router, 'GET', '/path')); // => { data: static route }
  print(findRoute(router, 'POST', '/path/cady')); // => { data: name route, }
  print(findRoute(
      router, 'GET', '/path/foo/bar/baz')); // => { data: wildcard route }
  print(findRoute(router, 'GET', '/')); // => null, not found.
}
