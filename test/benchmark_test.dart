import 'dart:math';

import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  const iterationCount = 1000;

  group('Performance benchmarks', () {
    test('add and find static routes', () {
      final router = createRouter<String>();
      final stopwatch = Stopwatch()..start();

      // Adding routes
      for (var i = 0; i < iterationCount; i++) {
        router.add('GET', '/path$i', 'handler$i');
      }

      final addTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Finding routes
      for (var i = 0; i < iterationCount; i++) {
        final randomIndex = Random().nextInt(iterationCount);
        final match = router.find('GET', '/path$randomIndex');
        expect(match?.data, equals('handler$randomIndex'));
      }

      final findTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      print('Performance (static routes):');
      print('  - Adding $iterationCount routes: ${addTime}ms');
      print('  - Finding $iterationCount routes: ${findTime}ms');
      print('  - Average find time: ${findTime / iterationCount}ms per route');
    });

    test('add and find parameter routes', () {
      final router = createRouter<String>();
      final stopwatch = Stopwatch()..start();

      // Adding routes
      for (var i = 0; i < iterationCount; i++) {
        router.add('GET', '/users/:id/items/:itemId/profile$i', 'handler$i');
      }

      final addTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Finding routes
      for (var i = 0; i < iterationCount; i++) {
        final randomIndex = Random().nextInt(iterationCount);
        final match =
            router.find('GET', '/users/123/items/456/profile$randomIndex');
        expect(match?.data, equals('handler$randomIndex'));
        expect(match?.params, equals({'id': '123', 'itemId': '456'}));
      }

      final findTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      print('Performance (parameter routes):');
      print('  - Adding $iterationCount routes: ${addTime}ms');
      print('  - Finding $iterationCount routes: ${findTime}ms');
      print('  - Average find time: ${findTime / iterationCount}ms per route');
    });

    test('complex routing scenario', () {
      final router = createRouter<String>();
      final stopwatch = Stopwatch()..start();

      // Add a mix of static, parameter, and wildcard routes
      for (var i = 0; i < iterationCount / 3; i++) {
        // Static routes
        router.add('GET', '/api/static/$i', 'static$i');

        // Parameter routes
        router.add('GET', '/api/users/:userId/profiles/$i', 'profile$i');

        // Wildcard routes
        router.add('GET', '/api/assets/$i/**:path', 'assets$i');
      }

      final addTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Finding routes (mixed types)
      for (var i = 0; i < iterationCount; i++) {
        final type = i % 3;
        final index = i % (iterationCount ~/ 3);

        switch (type) {
          case 0: // Static
            final match = router.find('GET', '/api/static/$index');
            expect(match?.data, equals('static$index'));
            break;

          case 1: // Parameter
            final match = router.find('GET', '/api/users/123/profiles/$index');
            expect(match?.data, equals('profile$index'));
            expect(match?.params['userId'], equals('123'));
            break;

          case 2: // Wildcard
            final match =
                router.find('GET', '/api/assets/$index/some/deep/path');
            expect(match?.data, equals('assets$index'));
            expect(match?.params.containsKey('path'), isTrue);
            break;
        }
      }

      final findTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      print('Performance (complex scenario):');
      print('  - Adding ${iterationCount ~/ 3 * 3} mixed routes: ${addTime}ms');
      print('  - Finding $iterationCount mixed routes: ${findTime}ms');
      print('  - Average find time: ${findTime / iterationCount}ms per route');
    });

    test('case insensitive performance', () {
      // Compare case-sensitive vs case-insensitive
      final caseSensitiveRouter = createRouter<String>();
      final caseInsensitiveRouter = createRouter<String>(caseSensitive: false);

      // Add identical routes to both
      for (var i = 0; i < iterationCount; i++) {
        final path = '/Route$i/Path';
        caseSensitiveRouter.add('GET', path, 'handler$i');
        caseInsensitiveRouter.add('GET', path, 'handler$i');
      }

      // Test case sensitive performance
      final sensitiveStopwatch = Stopwatch()..start();
      for (var i = 0; i < iterationCount; i++) {
        final randomIndex = Random().nextInt(iterationCount);
        final path = '/Route$randomIndex/Path';
        caseSensitiveRouter.find('GET', path);
      }
      final sensitiveTime = sensitiveStopwatch.elapsedMilliseconds;
      sensitiveStopwatch.stop();

      // Test case insensitive performance - 使用相同大小写来避免不确定性
      final insensitiveStopwatch = Stopwatch()..start();
      for (var i = 0; i < iterationCount; i++) {
        final randomIndex = Random().nextInt(iterationCount);
        final path = '/Route$randomIndex/Path'; // 使用与添加时相同的大小写
        caseInsensitiveRouter.find('GET', path);
      }
      final insensitiveTime = insensitiveStopwatch.elapsedMilliseconds;
      insensitiveStopwatch.stop();

      print('Case sensitivity performance comparison:');
      print(
          '  - Case sensitive: ${sensitiveTime}ms for $iterationCount lookups');
      print(
          '  - Case insensitive: ${insensitiveTime}ms for $iterationCount lookups');
      print('  - Difference: ${insensitiveTime - sensitiveTime}ms');
      print(
          '  - Percentage slower: ${((insensitiveTime / sensitiveTime) - 1) * 100}%');
    });
  });
}
