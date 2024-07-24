import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter<String>();

  router.add('get', '/path', 'Static path');
  router.add('get', '/path/:name', 'Param route');
  router.add('get', '/path/*', 'Unnamed param route');
  router.add('get', '/path/**', 'Wildcard Route');
  router.add('get', '/path/**:rset', 'Named wildcard route');
  router.add('get', '/files/:dir/:filename.:format,v:version', 'Mixed Route');

  // {data: Static path}
  print(router.find('get', '/path')?.toMap());

  // {data: Param route, params: {name: seven}}
  print(router.find('get', '/path/seven')?.toMap());

  // {data: Wildcard Route, params: {_: foo/bar/baz}}
  print(router.find('get', '/path/foo/bar/baz')?.toMap());

  // {data: Mixed Route, params: {dir: dart, filename: pubspec, format: yaml, version: 1}}
  print(router.find('get', '/files/dart/pubspec.yaml,v1')?.toMap());

  // `null`, No match.
  print(router.find('get', '/'));
}
