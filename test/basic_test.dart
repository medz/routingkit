// import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import 'utils/create_test_router.dart';

void main() {
  final router = createSimpleRouter([
    '/test',
    '/test/:id',
    '/test/:idYZ/y/z',
    '/test/:idY/y',
    '/test/foo',
    '/test/foo/*',
    '/test/foo/**',
    '/test/foo/bar/qux',
    '/test/foo/baz',
    '/test/fooo',
    '/another/path',
    '/wildcard/**'
  ]);

  test('lookup works', () {
    // Static
    expect(router.find('GET', '/test')?.data, equals('/test'));
    expect(router.find('GET', '/test/foo')?.data, equals('/test/foo'));
  });
}
