import 'package:test/test.dart';
import 'package:routingkit/src/_internal/node.dart';
import 'package:routingkit/routingkit.dart';

final int x = 1, y = 2, z = 3;

void main() {
  test('Base routing', () {
    final router = TrieRouter()
      ..register(0, [Segment('users'), Segment(':name')]);
    final parameters = Params();

    expect(router.lookup(['users', 'Seven'], parameters), equals(0));
    expect(parameters.get('name'), equals('Seven'));
  });

  test('Case ensitive routing', () {
    final router = TrieRouter(caseSensitive: true)
      ..register(0, [Segment('FoO'), Segment('bAr')]);
    final parameters = Params();

    expect(router.lookup(['FoO', 'bAr'], parameters), equals(0));
  });

  test('Case insensitive routing', () {
    final router = TrieRouter(caseSensitive: false)
      ..register(0, [Segment('FoO'), Segment('bAr')]);
    final parameters = Params();

    expect(router.lookup(['FOO', 'bar'], parameters), equals(0));
  });

  // Any routing
  test('Any routing', () {
    final router = TrieRouter()
      ..register(0, [Segment('a'), Segment.any()])
      ..register(1, [Segment('b'), Segment.param('1'), Segment.any()])
      ..register(2,
          [Segment('c'), Segment.param('1'), Segment.param('2'), Segment.any()])
      ..register(3, [
        Segment('d'),
        Segment.param('1'),
        Segment.param('2'),
      ])
      ..register(4, [Segment('e'), Segment.param('1'), Segment.catchall()])
      ..register(5, [Segment.any(), Segment.constant('e'), Segment.param('1')]);

    final parameters = Params();

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
      ..register(
          0, [Segment.constant('a'), Segment.param('1'), Segment.constant('a')])
      ..register(1, [
        Segment.constant('a'),
        Segment.any(),
        Segment.constant('b'),
      ]);
    final router2 = TrieRouter()
      ..register(
          0, [Segment.constant('a'), Segment.any(), Segment.constant('a')])
      ..register(1, [
        Segment.constant('a'),
        Segment.any(),
        Segment.constant('b'),
      ]);
    final parameters1 = Params();
    final parameters2 = Params();
    final path = ['a', '1', 'b'];

    expect(router1.lookup(path, parameters1), equals(1));
    expect(router2.lookup(path, parameters2), equals(1));
  });

  // Router suffixes
  test('Router suffixes', () {
    final router = TrieRouter(caseSensitive: true);
    router.register(0, [Segment('a')]);
    router.register(1, [Segment('aa')]);

    final parameters = Params();

    expect(router.lookup(['a'], parameters), equals(0));
    expect(router.lookup(['aa'], parameters), equals(1));
  });

  // Parameter Percent Decoding
  test('Parameter Percent Decoding', () {
    final router = TrieRouter()
      ..register(0, [Segment('users'), Segment(':name')]);
    final parameters = Params();

    expect(router.lookup(['users', 'Seven%20Du'], parameters), equals(0));
    expect(parameters.get('name'), equals('Seven Du'));
  });

  // Catch all nesting
  test('Catch all nesting', () {
    final router = TrieRouter<String>()
      ..register('/**', [Segment.catchall()])
      ..register('/a/**', [Segment.constant('a'), Segment.catchall()])
      ..register('/a/b/**',
          [Segment.constant('a'), Segment.constant('b'), Segment.catchall()])
      ..register('/a/b', [
        Segment.constant('a'),
        Segment.constant('b'),
      ]);

    final parameters = Params();

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
    router.register('a', [Segment.constant('v1'), Segment.constant('test')]);
    router.register('b', [Segment.constant('v1'), Segment.catchall()]);
    router.register('c', [Segment.constant('v1'), Segment.any()]);

    final parameters = Params();

    expect(router.lookup(['v1', 'test'], parameters), equals('a'));
    expect(router.lookup(['v1', 'test', 'foo'], parameters), equals('b'));
    expect(router.lookup(['v1', 'foo'], parameters), equals('c'));
  });

  // Catch all value
  test('Catch all value', () {
    final router = TrieRouter();
    router.register(0, [Segment('users'), Segment(':user'), Segment('**')]);
    router.register(1, [Segment('users'), Segment('**')]);

    final parameters = Params();

    expect(router.lookup(['users'], parameters), isNull);
    expect(parameters.catchall, isEmpty);

    expect(router.lookup(['users', 'foo'], parameters), equals(1));
    expect(parameters.catchall, ['foo']);

    expect(
        router.lookup(['users', 'seven', 'posts', '2'], parameters), equals(0));
    expect(parameters.catchall, ['posts', '2']);
  });

  // Router description
  test('Router description', () {
    final Segment constA = Segment.constant('a'),
        constOne = Segment.constant('1'),
        paramOne = Segment.param('1'),
        anything = Segment.any(),
        catchall = Segment.catchall();

    final router = TrieRouter()
      ..register(0, [constA, anything])
      ..register(1, [constA, constOne, catchall])
      ..register(1, [constA, constOne, anything])
      ..register(1, [anything, constA, paramOne])
      ..register(1, [catchall]);

    final String description = '''
$rightArrow ${constA.toString()}
$space$rightArrow ${constOne.toString()}
$space$space$rightArrow ${anything.toString()}
$space$space$rightArrow ${catchall.toString()}
$space$rightArrow ${anything.toString()}
$rightArrow ${anything.toString()}
$space$rightArrow ${constA.toString()}
$space$space$rightArrow ${paramOne.toString()}
$rightArrow ${catchall.toString()}''';

    expect(router.description, equals(description));
  });
}
