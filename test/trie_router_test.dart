import 'package:test/test.dart';
import 'package:routingkit/src/_internal/node.dart';
import 'package:routingkit/routingkit.dart';

final int x = 1, y = 2, z = 3;

void main() {
  test('Base routing', () {
    final router = TrieRouter()
      ..register(0, [PathComponent('users'), PathComponent(':name')]);
    final parameters = Parameters();

    expect(router.lookup(['users', 'Seven'], parameters), equals(0));
    expect(parameters.get('name'), equals('Seven'));
  });

  test('Case ensitive routing', () {
    final router =
        TrieRouter(options: ConfigurationOptions(caseSensitive: true))
          ..register(0, [PathComponent('FoO'), PathComponent('bAr')]);
    final parameters = Parameters();

    expect(router.lookup(['FoO', 'bAr'], parameters), equals(0));
  });

  test('Case insensitive routing', () {
    final router =
        TrieRouter(options: ConfigurationOptions(caseSensitive: false))
          ..register(0, [PathComponent('FoO'), PathComponent('bAr')]);
    final parameters = Parameters();

    expect(router.lookup(['FOO', 'bar'], parameters), equals(0));
  });

  // Any routing
  test('Any routing', () {
    final router = TrieRouter()
      ..register(0, [PathComponent('a'), PathComponent.anything])
      ..register(1, [
        PathComponent('b'),
        PathComponent.parameter('1'),
        PathComponent.anything
      ])
      ..register(2, [
        PathComponent('c'),
        PathComponent.parameter('1'),
        PathComponent.parameter('2'),
        PathComponent.anything
      ])
      ..register(3, [
        PathComponent('d'),
        PathComponent.parameter('1'),
        PathComponent.parameter('2'),
      ])
      ..register(4, [
        PathComponent('e'),
        PathComponent.parameter('1'),
        PathComponent.catchAll
      ])
      ..register(5, [
        PathComponent.anything,
        PathComponent.constant('e'),
        PathComponent.parameter('1')
      ]);

    final parameters = Parameters();

    // a
    expect(router.lookup(['a'], parameters), isNull);
    expect(router.lookup(['a', 'a'], parameters), equals(0));
    expect(router.lookup(['a', 'b'], parameters), equals(0));

    // b
    expect(router.lookup(['b'], parameters), isNull);
    expect(router.lookup(['b', 'a'], parameters), isNull);
    expect(router.lookup(['b', 'a', 'c'], parameters), equals(1));

    // c
    expect(router.lookup(['c'], parameters), isNull);
    expect(router.lookup(['c', 'a'], parameters), isNull);
    expect(router.lookup(['c', 'a', 'c'], parameters), isNull);
    expect(router.lookup(['c', 'b', 'c', 'd'], parameters), equals(2));

    // d
    expect(router.lookup(['d'], parameters), isNull);
    expect(router.lookup(['d', 'a'], parameters), isNull);
    expect(router.lookup(['d', 'a', 'b'], parameters), equals(3));

    // e
    expect(router.lookup(["e", "1", "b", "a"], parameters), equals(4));

    // Other
    expect(router.lookup(['f', 'e', '1'], parameters), equals(5));
    expect(router.lookup(['g', 'e', '1'], parameters), equals(5));
    expect(router.lookup(['h', 'e', '1'], parameters), equals(5));
  });

  // Wildcard routing
  test('Wildcard routing', () {
    final router1 = TrieRouter()
      ..register(0, [
        PathComponent.constant('a'),
        PathComponent.parameter('1'),
        PathComponent.constant('a')
      ])
      ..register(1, [
        PathComponent.constant('a'),
        PathComponent.anything,
        PathComponent.constant('b'),
      ]);
    final router2 = TrieRouter()
      ..register(0, [
        PathComponent.constant('a'),
        PathComponent.anything,
        PathComponent.constant('a')
      ])
      ..register(1, [
        PathComponent.constant('a'),
        PathComponent.anything,
        PathComponent.constant('b'),
      ]);
    final parameters1 = Parameters();
    final parameters2 = Parameters();
    final path = ['a', '1', 'b'];

    expect(router1.lookup(path, parameters1), equals(1));
    expect(router2.lookup(path, parameters2), equals(1));
  });

  // Router suffixes
  test('Router suffixes', () {
    final router = TrieRouter(
      options: ConfigurationOptions(caseSensitive: true),
    );
    router.register(0, [PathComponent('a')]);
    router.register(1, [PathComponent('aa')]);

    final parameters = Parameters();

    expect(router.lookup(['a'], parameters), equals(0));
    expect(router.lookup(['aa'], parameters), equals(1));
  });

  // Parameter Percent Decoding
  test('Parameter Percent Decoding', () {
    final router = TrieRouter()
      ..register(0, [PathComponent('users'), PathComponent(':name')]);
    final parameters = Parameters();

    expect(router.lookup(['users', 'Seven%20Du'], parameters), equals(0));
    expect(parameters.get('name'), equals('Seven Du'));
  });

  // Catch all nesting
  test('Catch all nesting', () {
    final router = TrieRouter<String>()
      ..register('/**', [PathComponent.catchAll])
      ..register('/a/**', [PathComponent.constant('a'), PathComponent.catchAll])
      ..register('/a/b/**', [
        PathComponent.constant('a'),
        PathComponent.constant('b'),
        PathComponent.catchAll
      ])
      ..register('/a/b', [
        PathComponent.constant('a'),
        PathComponent.constant('b'),
      ]);

    final parameters = Parameters();

    expect(router.lookup(['a'], parameters), equals('/**'));
    expect(router.lookup(['a', 'b'], parameters), equals('/a/b'));
    expect(router.lookup(['a', 'b', 'c'], parameters), equals('/a/b/**'));
    expect(router.lookup(['a', 'c'], parameters), equals('/a/**'));
    expect(router.lookup(['b'], parameters), equals('/**'));
    expect(router.lookup(["b", "c", "d", "e"], parameters), equals('/**'));
  });

  // Catch all precedence
  test('Catch all precedence', () {
    final router = TrieRouter<String>();
    router.register(
        'a', [PathComponent.constant('v1'), PathComponent.constant('test')]);
    router
        .register('b', [PathComponent.constant('v1'), PathComponent.catchAll]);
    router
        .register('c', [PathComponent.constant('v1'), PathComponent.anything]);

    final parameters = Parameters();

    expect(router.lookup(['v1', 'test'], parameters), equals('a'));
    expect(router.lookup(['v1', 'test', 'foo'], parameters), equals('b'));
    expect(router.lookup(['v1', 'foo'], parameters), equals('c'));
  });

  // Catch all value
  test('Catch all value', () {
    final router = TrieRouter();
    router.register(0,
        [PathComponent('users'), PathComponent(':user'), PathComponent('**')]);
    router.register(1, [PathComponent('users'), PathComponent('**')]);

    final parameters = Parameters();

    expect(router.lookup(['users'], parameters), isNull);
    expect(parameters.getCatchAll(), isEmpty);

    expect(router.lookup(['users', 'foo'], parameters), equals(1));
    expect(parameters.getCatchAll(), ['foo']);

    expect(
        router.lookup(['users', 'seven', 'posts', '2'], parameters), equals(0));
    expect(parameters.getCatchAll(), ['posts', '2']);
  });

  // Router description
  test('Router description', () {
    final PathComponent constA = PathComponent.constant('a'),
        constOne = PathComponent.constant('1'),
        paramOne = PathComponent.parameter('1'),
        anything = PathComponent.anything,
        catchAll = PathComponent.catchAll;

    final router = TrieRouter()
      ..register(0, [constA, anything])
      ..register(1, [constA, constOne, catchAll])
      ..register(1, [constA, constOne, anything])
      ..register(1, [anything, constA, paramOne])
      ..register(1, [catchAll]);

    final String description = '''
$rightArrow ${constA.description}
$space$rightArrow ${constOne.description}
$space$space$rightArrow ${anything.description}
$space$space$rightArrow ${catchAll.description}
$space$rightArrow ${anything.description}
$rightArrow ${anything.description}
$space$rightArrow ${constA.description}
$space$space$rightArrow ${paramOne.description}
$rightArrow ${catchAll.description}''';

    expect(router.description, equals(description));
  });
}
