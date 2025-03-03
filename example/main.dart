import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter<String>();

  router.add('GET', '/path', 'static route');
  router.add('POST', '/path/:name', 'name route');
  router.add('GET', '/path/foo/**', 'wildcard route');
  router.add('GET', '/path/foo/**:name', 'named wildcard route');

  print(router.find('GET', '/path')); // => { data: static route }
  print(router.find(
      'POST', '/path/cady')); // => { data: name route, params: {name: cady} }
  print(router.find('GET',
      '/path/foo/bar/baz')); // => { data: wildcard route, params: {_: bar/baz} }
  print(router.find('GET', '/')); // => null, not found.
}
