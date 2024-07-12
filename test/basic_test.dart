import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import '_utils.dart';

void main() {
  final router = createTestRouter([
    ('/test', null),
    ('/test/:id', null),
    ('/test/:idYZ/y/z', null),
    ('/test/:idY/y', null),
    ('/test/foo', null),
    ('/test/foo/*', null),
    ('/test/foo/**', null),
    ('/test/foo/bar/qux', null),
    ('/test/foo/baz', null),
    ('/test/fooo', null),
    ('/another/path', null),
    ('/wildcard/**', null),
  ]);

  test('lookup works', () {
    expect(
        findRoute(router, 'GET', '/test')?.toTestObject().first,
        equals({
          'data': {'path': "/test"}
        }));

    // Static
    expect(
        findRoute(router, 'GET', '/test/foo')?.toTestObject().first,
        equals({
          'data': {'path': "/test/foo"}
        }));

    expect(
        findRoute(router, 'GET', '/test/fooo')?.toTestObject().first,
        equals({
          'data': {'path': "/test/fooo"}
        }));

    expect(
        findRoute(router, 'GET', '/another/path')?.toTestObject().first,
        equals({
          'data': {'path': "/another/path"}
        }));

    // Param
    expect(
        findRoute(router, 'GET', '/test/123')?.toTestObject().first,
        equals({
          'data': {'path': "/test/:id"},
          'params': {'id': "123"}
        }));

    expect(
        findRoute(router, 'GET', '/test/123/y')?.toTestObject().first,
        equals({
          'data': {'path': "/test/:idY/y"},
          'params': {'idY': "123"}
        }));

    expect(
        findRoute(router, 'GET', '/test/123/y/z')?.toTestObject().first,
        equals({
          'data': {'path': "/test/:idYZ/y/z"},
          'params': {'idYZ': "123"}
        }));

    expect(
        findRoute(router, 'GET', '/test/foo/123')?.toTestObject().first,
        equals({
          'data': {'path': "/test/foo/*"},
          'params': {'_0': "123"}
        }));

    // Wildcard
    expect(
        findRoute(router, 'GET', '/test/foo/123/456')?.toTestObject().first,
        equals({
          'data': {'path': "/test/foo/**"},
          'params': {'_': "123/456"}
        }));
    expect(
        findRoute(router, 'GET', '/wildcard/foo')?.toTestObject().first,
        equals({
          'data': {'path': "/wildcard/**"},
          'params': {'_': "foo"}
        }));

    expect(
        findRoute(router, 'GET', '/wildcard/foo/bar')?.toTestObject().first,
        equals({
          'data': {'path': "/wildcard/**"},
          'params': {'_': "foo/bar"}
        }));

    expect(
        findRoute(router, 'GET', '/wildcard')?.toTestObject().first,
        equals({
          'data': {'path': "/wildcard/**"},
        }));
  });

  test('remove works', () {
    removeRoute(router, "GET", "/test");
    removeRoute(router, "GET", "/test/*");
    removeRoute(router, "GET", "/test/foo/*");
    removeRoute(router, "GET", "/test/foo/**");

    expect(findRoute(router, 'GET', '/test'), isNull);
  });
}
