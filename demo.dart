import 'package:routingkit/routingkit.dart';

import 'test/_utils.dart';

void main() {
  final router = createTestRouter([
    ('/', null),
    ('/foo', null),
    ('/foo/*', null),
    ('/foo/**', null),
    ('/foo/bar', null),
    ('/foo/baz', null),
    ('/foo/baz/**', null),
    ('/without-trailing', null),
    ('/with-trailing/', null),
    ('/c/**', null),
    ('/c/cart', null),
  ]);

  final res = findAllRoutes(router, 'GET', '/foo');
  print(res);
}
