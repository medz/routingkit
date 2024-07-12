import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import '_utils.dart';

Object? _findRoute(RouterContext context, String method, String path) =>
    findRoute(context, method, path)?.toTestObject().firstOrNull;

Iterable<(String, Object?)> createTestRoutes(Iterable<String> paths) =>
    paths.map((e) => (e, null));

void testRouter(Iterable<String> routes, [Map<String, Object>? tests]) {
  final router = createTestRouter(createTestRoutes(routes));
  if (tests == null) {
    final entries = routes.map(
      (e) => MapEntry(e, {
        'data': {'path': e}
      }),
    );
    tests = Map.fromEntries(entries);
  }

  for (final MapEntry(key: path, value: value) in tests.entries) {
    test('lookup $path should be $value', () {
      expect(_findRoute(router, 'GET', path), value);
    });
  }
}

void main() {
  group('Router lookup', () {
    group('static routes', () {
      testRouter(
        ['/', 'route', 'another-router', '/this/is/yet/another/route'],
      );
    });

    group('retrieve placeholders', () {
      testRouter([
        'carbon/:element',
        'carbon/:element/test/:testing',
        'this/:route/has/:cool/stuff'
      ], {
        'carbon/test1': {
          'data': {'path': "carbon/:element"},
          'params': {
            'element': "test1",
          },
        },
        "/carbon": {
          'data': {'path': "carbon/:element"},
        },
        "carbon/": {
          'data': {'path': "carbon/:element"},
        },
        "carbon/test2/test/test23": {
          'data': {'path': "carbon/:element/test/:testing"},
          'params': {
            'element': "test2",
            'testing': "test23",
          },
        },
        "this/test/has/more/stuff": {
          'data': {'path': "this/:route/has/:cool/stuff"},
          'params': {
            'route': "test",
            'cool': "more",
          },
        },
      });

      testRouter([
        "/",
        "/:a",
        "/:a/:y/:x/:b",
        "/:a/:x/:b",
        "/:a/:b"
      ], {
        "/": {
          'data': {'path': "/"}
        },
        "/a": {
          'data': {'path': "/:a"},
          'params': {'a': "a"},
        },
        "/a/b": {
          'data': {'path': "/:a/:b"},
          'params': {
            'a': "a",
            'b': "b",
          },
        },
        "/a/x/b": {
          'data': {'path': "/:a/:x/:b"},
          'params': {
            'a': "a",
            'b': "b",
            'x': "x",
          },
        },
        "/a/y/x/b": {
          'data': {'path': "/:a/:y/:x/:b"},
          'params': {
            'a': "a",
            'b': "b",
            'x': "x",
            'y': "y",
          },
        },
      });

      testRouter([
        "/",
        "/:name",
        "/:owner/:repo/",
        "/:owner/:repo/:name",
        "/:owner/:repo/:org/:name",
      ], {
        "/medz/spry/test@232": {
          'data': {'path': "/:owner/:repo/:name"},
          'params': {
            'owner': "medz",
            'repo': "spry",
            'name': "test@232",
          },
        },
        "/medz/spry/@haha/a@232": {
          'data': {'path': "/:owner/:repo/:org/:name"},
          'params': {
            'owner': "medz",
            'repo': "spry",
            'org': "@haha",
            'name': "a@232",
          },
        },
      });
    });

    group('should be able to perform wildcard lookups', () {
      testRouter(
        [
          "polymer/**:id",
          "polymer/another/route",
          "route/:p1/something/**:rest"
        ],
        {
          "polymer/another/route": {
            'data': {'path': "polymer/another/route"}
          },
          "polymer/anon": {
            'data': {'path': "polymer/**:id"},
            'params': {'id': "anon"},
          },
          "polymer/foo/bar/baz": {
            'data': {'path': "polymer/**:id"},
            'params': {'id': "foo/bar/baz"},
          },
          "route/param1/something/c/d": {
            'data': {'path': "route/:p1/something/**:rest"},
            'params': {'p1': "param1", 'rest': "c/d"},
          },
        },
      );
    });

    group('fallback to dynamic', () {
      testRouter(
        ["/wildcard/**", "/test/**", "/test", "/dynamic/*"],
        {
          "/wildcard": {
            'data': {'path': "/wildcard/**"},
          },
          "/wildcard/": {
            'data': {'path': "/wildcard/**"},
          },
          "/wildcard/abc": {
            'data': {'path': "/wildcard/**"},
            'params': {'_': "abc"},
          },
          "/wildcard/abc/def": {
            'data': {'path': "/wildcard/**"},
            'params': {'_': "abc/def"},
          },
          "/dynamic": {
            'data': {'path': "/dynamic/*"},
          },
          "/test": {
            'data': {'path': "/test"},
          },
          "/test/": {
            'data': {'path': "/test"},
          },
          "/test/abc": {
            'data': {'path': "/test/**"},
            'params': {'_': "abc"},
          },
        },
      );
    });

    group('unnamed placeholders', () {
      testRouter(
        ["polymer/**", "polymer/route/*"],
        {
          "polymer/foo/bar": {
            'data': {'path': "polymer/**"},
            'params': {'_': "foo/bar"},
          },
          "polymer/route/anon": {
            'data': {'path': "polymer/route/*"},
            'params': {'_0': "anon"},
          },
          "polymer/constructor": {
            'data': {'path': "polymer/**"},
            'params': {'_': "constructor"},
          },
        },
      );
    });

    group('mixed params in same segment', () {
      const mixedPath = '/files/:category/:id,name=:name.txt';
      testRouter(
        [mixedPath],
        {
          "/files/test/123,name=foobar.txt": {
            'data': {'path': mixedPath},
            'params': {'category': "test", 'id': "123", 'name': "foobar"},
          },
        },
      );
    });

    group('should be able to match routes with trailing slash', () {
      testRouter(
        ["route/without/trailing/slash", "route/with/trailing/slash/"],
        {
          "route/without/trailing/slash": {
            'data': {'path': "route/without/trailing/slash"},
          },
          "route/with/trailing/slash/": {
            'data': {'path': "route/with/trailing/slash/"},
          },
          "route/without/trailing/slash/": {
            'data': {'path': "route/without/trailing/slash"},
          },
          "route/with/trailing/slash": {
            'data': {'path': "route/with/trailing/slash/"},
          },
        },
      );
    });
  });
}
