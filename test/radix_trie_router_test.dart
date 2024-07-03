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
  T? valueOf(String path) => lookup(path)?.value;
}

main() {
  test('base routing', () {
    final router = createRouter(
      routes: {'/users/:name': 0},
    );

    final result = router.lookup('/users/Seven');

    expect(result?.params('name'), equals('Seven'));
    expect(result?.value, equals(0));
    expect(result?.route, equals('users/:name'));
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

    expect(router.valueOf('a'), isNull);
    expect(router.valueOf('a/a'), equals(0));
    expect(router.valueOf('a/b'), equals(0));

    expect(router.valueOf('b'), isNull);
    expect(router.valueOf('b/a'), isNull);
    expect(router.valueOf('b/a/c'), equals(1));

    // c
    expect(router.valueOf('c'), isNull);
    expect(router.valueOf('c/a'), isNull);
    expect(router.valueOf('c/a/c'), isNull);
    expect(router.valueOf('c/b/c/d'), equals(2));

    // d
    expect(router.valueOf('d'), isNull);
    expect(router.valueOf('d/a'), isNull);
    expect(router.valueOf('d/a/b'), equals(3));

    // e
    expect(router.valueOf('e/1/d/f'), equals(4));

    // Other
    expect(router.valueOf('f/f/1'), equals(5));
    expect(router.valueOf('g/f/1'), equals(5));
    expect(router.valueOf('h/f/1'), equals(5));
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
    final result1 = router1.lookup(path);
    final result2 = router2.lookup(path);

    expect(result1?.params, isEmpty);
    expect(result1?.value, equals(1));

    expect(result2?.params.length, equals(1));
    expect(result2?.params('1'), equals('1'));
    expect(result2?.value, equals(1));
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

    final result1 = router.lookup('users');
    expect(result1, isNull);

    final result2 = router.lookup('users/foo');
    expect(result2?.params.catchall, equals('foo'));
    expect(result2?.value, equals(1));

    final result3 = router.lookup('users/seven/posts/2');
    expect(result3?.value, equals(0));
    expect(result3?.params, isNotEmpty);
    expect(result3?.params('name'), 'seven');
    expect(result3?.params.catchall, equals('posts/2'));
  });

  test('build path', () {
    final router = createRouter();
    final path = router.buildPath(
      '/users/:user/posts/:id',
      params: {'user': 'seven', 'id': '1'},
    );

    expect(path, equals('users/seven/posts/1'));

    final path2 = router.buildPath(
      'demo/:name/*/:a/**',
      params: {'name': '1', 'a': '2'},
      wildcard: ['3'],
      catchall: '4',
    );
    expect(path2, equals('demo/1/3/2/4'));
  });
}
