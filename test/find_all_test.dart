import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import '_utils.dart';

Iterable<String> _findAllRoutes(
    RouterContext context, String method, String path) {
  return findAllRoutes(context, method, path).map((e) => e.data['path']);
}

void main() {
  group("findAllRoutes basic", () {
    final router = createTestRouter([
      ('/foo', null),
      ('/foo/**', null),
      ('/foo/bar', null),
      ('/foo/bar/baz', null),
      ('/foo/*/baz', null),
      ('/**', null),
    ]);

    test('matches /foo/bar/baz pattern', () {
      expect(_findAllRoutes(router, "GET", "/foo/bar/baz"), [
        '/**',
        '/foo/**',
        '/foo/*/baz',
        '/foo/bar/baz',
      ]);
    });
  });

  group('matcher: complex', () {
    final router = createTestRouter([
      ('/', null),
      ('/foo', null),
      ('/foo/*', null),
      ('/foo/**', null),
      ('/foo/bar', null),
      ('/foo/baz', null),
      ('/foo/baz/**', null),
      ('/foo/*/sub', null),
      ('/without-trailing', null),
      ('/with-trailing/', null),
      ('/c/**', null),
      ('/cart', null),
    ]);

    test('can match routes', () {
      expect(_findAllRoutes(router, 'GET', '/'), ['/']);
      expect(_findAllRoutes(router, 'GET', '/foo'), [
        '/foo/**',
        '/foo/*',
        '/foo',
      ]);
      expect(_findAllRoutes(router, 'GET', '/foo/bar'), [
        '/foo/**',
        '/foo/*',
        '/foo/bar',
      ]);
      expect(_findAllRoutes(router, 'GET', '/foo/baz'), [
        '/foo/**',
        '/foo/*',
        '/foo/baz/**',
        '/foo/baz',
      ]);
      expect(_findAllRoutes(router, 'GET', '/foo/123/sub'), [
        '/foo/**',
        '/foo/*/sub',
      ]);
      expect(_findAllRoutes(router, 'GET', '/foo/123'), [
        '/foo/**',
        '/foo/*',
      ]);
    });

    test('trailing slash', () {
      expect(
          _findAllRoutes(router, 'GET', '/with-trailing'), ['/with-trailing/']);
      expect(
        _findAllRoutes(router, 'GET', '/with-trailing'),
        _findAllRoutes(router, 'GET', '/with-trailing/'),
      );

      expect(_findAllRoutes(router, 'GET', '/without-trailing'),
          ['/without-trailing']);
      expect(
        _findAllRoutes(router, 'GET', '/without-trailing'),
        _findAllRoutes(router, 'GET', '/without-trailing/'),
      );
    });

    test('prefix overlap', () {
      expect(_findAllRoutes(router, "GET", "/c/123"), ['/c/**']);
      expect(
        _findAllRoutes(router, "GET", "/c/123"),
        _findAllRoutes(router, "GET", "/c/123/"),
      );
      expect(
        _findAllRoutes(router, "GET", "/c/123"),
        _findAllRoutes(router, "GET", "/c"),
      );
      expect(_findAllRoutes(router, "GET", "/cart"), ['/cart']);
    });
  });

  group('matcher: order', () {
    final router = createTestRouter([
      ('/hello', null),
      ('/hello/world', null),
      ('/hello/*', null),
      ('/hello/**', null),
    ]);

    test('/hello', () {
      expect(
        _findAllRoutes(router, 'GET', '/hello'),
        ['/hello/**', '/hello/*', '/hello'],
      );
    });

    test('/hello/world', () {
      expect(
        _findAllRoutes(router, 'GET', '/hello/world'),
        ['/hello/**', '/hello/*', '/hello/world'],
      );
    });

    test('/hello/world/foobar', () {
      expect(
        _findAllRoutes(router, 'GET', '/hello/world/foobar'),
        ['/hello/**'],
      );
    });
  });
}
