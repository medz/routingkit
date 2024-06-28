import 'package:routingkit/routingkit.dart' hide createRouter;
import 'package:routingkit/routingkit.dart' as routingkit show createRouter;
import 'package:test/test.dart';

Router<T> createRouter<T>({
  bool caseSensitive = false,
  Map<String, T> routes = const {},
}) {
  return routingkit.createRouter(
    driver: const RadixTrieRouterDriver(),
    caseSensitive: caseSensitive,
    routes: routes,
  );
}

extension<T> on Router<T> {
  T? valueOf(String path) => lookup(path).$2;
}

main() {
  test('base routing', () {
    final router = createRouter(
      routes: {'/users/:name': 0},
    );

    final (params, value) = router.lookup('/users/Seven');

    expect(params('name'), equals('Seven'));
    expect(value, equals(0));
  });

  test('Case ensitive routing', () {
    final router = createRouter(
      caseSensitive: true,
      routes: {'FoO/Bar': 0},
    );

    expect(router.valueOf('FoO/Bar'), equals(0));
  });

  test('Case insensitive routing', () {
    final router = createRouter(
      caseSensitive: false,
      routes: {'FoO/Bar': 0},
    );

    expect(router.valueOf('FOO/bar'), equals(0));
  });

  // Any routing
  test('Any routing', () {
    final router = createRouter(
      routes: {
        'a/*': 0,
        'b/:1/*': 1,
        'c/:1/:2/*': 2,
        'd/:1/:2': 3,
        'e/:1/**': 4,
        '*/f/:1': 5,
      },
    );

    expect(router.lookup('a').$2, isNull);
    expect(router.lookup('a/a').$2, equals(0));
    expect(router.lookup('a/b').$2, equals(0));

    expect(router.lookup('b').$2, isNull);
    expect(router.lookup('b/a').$2, isNull);
    expect(router.lookup('b/a/c').$2, equals(1));

    // c
    expect(router.lookup('c').$2, isNull);
    expect(router.lookup('c/a').$2, isNull);
    expect(router.lookup('c/a/c').$2, isNull);
    expect(router.lookup('c/b/c/d').$2, equals(2));

    // d
    expect(router.lookup('d').$2, isNull);
    expect(router.lookup('d/a').$2, isNull);
    expect(router.lookup('d/a/b').$2, equals(3));

    // e
    expect(router.lookup('e/1/d/f').$2, equals(4));

    // Other
    expect(router.lookup('f/f/1').$2, equals(5));
    expect(router.lookup('g/f/1').$2, equals(5));
    expect(router.lookup('h/f/1').$2, equals(5));
  });

  // Wildcard routing
  test('Wildcard routing', () {
    final router1 = createRouter(routes: {
      'a/:1/a': 0,
      'a/*/b': 1,
    });
    final router2 = createRouter(routes: {
      'a/*/a': 0,
      'a/:1/b': 1,
    });

    const path = 'a/1/b';
    final (p1, v1) = router1.lookup(path);
    final (p2, v2) = router2.lookup(path);

    expect(p1, isEmpty);
    expect(v1, equals(1));

    expect(p2.length, equals(1));
    expect(p2('1'), equals('1'));
    expect(v2, equals(1));
  });

  // Catch all nesting
  test('Catch all nesting', () {
    const paths = ['/**', '/a/**', '/a/b/**', '/a/b'];
    final routes = {for (final e in paths) e: e};
    final router = createRouter(routes: routes);

    expect(router.valueOf('a'), equals('/**'));
    expect(router.valueOf('a/b'), equals('/a/b'));
    expect(router.valueOf('a/b/c'), equals('/a/b/**'));
    expect(router.valueOf('a/c'), equals('/a/**'));
    expect(router.valueOf('b'), equals('/**'));
    expect(router.valueOf('b/c/d/e'), equals('/**'));
  });

  // Catch all precedence
  test('Catch all precedence', () {
    final router = createRouter(routes: {
      'v1/test': 'a',
      'v1/**': 'b',
      'v1/*': 'c',
    });

    expect(router.valueOf('v1/test'), equals('a'));
    expect(router.valueOf('v1/test/foo'), equals('b'));
    expect(router.valueOf('v1/foo'), equals('c'));
  });

  // Catch all value
  test('Catch all value', () {
    final router = createRouter(routes: {
      'users/:name/**': 0,
      'users/**': 1,
    });

    final (p1, v1) = router.lookup('users');
    expect(p1, isEmpty);
    expect(p1.catchall, isNull);
    expect(v1, isNull);

    final (p2, v2) = router.lookup('users/foo');
    expect(p2.catchall, equals('foo'));
    expect(v2, equals(1));

    final (p3, v3) = router.lookup('users/seven/posts/2');
    expect(v3, equals(0));
    expect(p3, isNotEmpty);
    expect(p3('name'), 'seven');
    expect(p3.catchall, equals('posts/2'));
  });
}
