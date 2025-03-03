import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('Performance Tests', () {
    test('Large-scale route adding', () {
      final router = createRouter<String>();
      final int routeCount = 1000;

      // Measure time to add routes
      final addStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      final addDuration = DateTime.now().difference(addStart);
      print('Adding $routeCount routes took: ${addDuration.inMilliseconds}ms');

      // Ensure performance is within reasonable range
      expect(addDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each route should take less than 1ms to add');
    });

    test('Large-scale route finding', () {
      final router = createRouter<String>();
      final int routeCount = 1000;

      // Add routes
      for (var i = 0; i < routeCount; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      // Measure time to find static routes
      final staticStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/route/$i');
      }

      final staticDuration = DateTime.now().difference(staticStart);
      print(
          'Finding $routeCount static routes took: ${staticDuration.inMilliseconds}ms');

      // Ensure performance is within reasonable range
      expect(staticDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each static route should take less than 1ms to find');
    });

    test('Non-existent route performance', () {
      final router = createRouter<String>();
      final int routeCount = 1000;

      // Add routes
      for (var i = 0; i < routeCount; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      // Measure time to find non-existent routes
      final notFoundStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/not-found/$i');
      }

      final notFoundDuration = DateTime.now().difference(notFoundStart);
      print(
          'Finding $routeCount non-existent routes took: ${notFoundDuration.inMilliseconds}ms');

      // Ensure performance is within reasonable range
      expect(notFoundDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each non-existent route should take less than 1ms to find');
    });

    test('Complex route pattern performance', () {
      final router = createRouter<String>();
      final int routeCount = 100;

      // Add complex routes
      for (var i = 0; i < routeCount; i++) {
        router.add(
            'GET',
            '/api/v1/users/:userId/posts/:postId/comments/:commentId',
            'route-$i');
      }

      // Measure time to find complex routes
      final findStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/api/v1/users/123/posts/456/comments/789');
      }

      final findDuration = DateTime.now().difference(findStart);
      print(
          'Finding $routeCount complex routes took: ${findDuration.inMilliseconds}ms');

      // Ensure performance is within reasonable range
      expect(findDuration.inMilliseconds / routeCount < 2, isTrue,
          reason: 'Each complex route should take less than 2ms to find');
    });

    test('Route removal performance', () {
      final router = createRouter<String>();
      final int routeCount = 1000;

      // Add routes
      for (var i = 0; i < routeCount; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      // Measure time to remove routes
      final removeStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.remove('GET', '/route/$i');
      }

      final removeDuration = DateTime.now().difference(removeStart);
      print(
          'Removing $routeCount routes took: ${removeDuration.inMilliseconds}ms');

      // Ensure performance is within reasonable range
      expect(removeDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each route should take less than 1ms to remove');
    });
  });
}
