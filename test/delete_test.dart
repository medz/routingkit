import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('Router Remove Operation Tests', () {
    test('Router.remove should correctly remove static routes', () {
      final router = createRouter<String>();

      // Clear the route if it already exists
      while (router.remove('GET', '/test-route')) {}

      // Add a route
      router.add('GET', '/test-route', 'test-data');

      // Verify the route exists
      expect(router.find('GET', '/test-route')?.data, equals('test-data'));

      // Remove the route
      expect(router.remove('GET', '/test-route'), isTrue);

      // Verify the route no longer exists
      expect(router.find('GET', '/test-route'), isNull);
    });

    test('Router.remove should correctly remove parameter routes', () {
      final router = createRouter<String>();

      // Clear the route if it already exists
      while (router.remove('GET', '/users/:id')) {}

      // Add a parameter route
      router.add('GET', '/users/:id', 'user-data');

      // Verify the route matches
      expect(router.find('GET', '/users/123')?.data, equals('user-data'));

      // Remove the route
      expect(router.remove('GET', '/users/:id'), isTrue);

      // Verify the route no longer matches
      expect(router.find('GET', '/users/123'), isNull);
    });

    test('Router.remove should correctly remove wildcard routes', () {
      final router = createRouter<String>();

      // Clear the route if it already exists
      while (router.remove('GET', '/api/**')) {}

      // Add a wildcard route
      router.add('GET', '/api/**', 'api-data');

      // Verify the route matches
      expect(router.find('GET', '/api/users/123')?.data, equals('api-data'));

      // Remove the route
      expect(router.remove('GET', '/api/**'), isTrue);

      // Verify the route no longer matches
      expect(router.find('GET', '/api/users/123'), isNull);
    });

    test('Router.remove should return false for non-existent routes', () {
      final router = createRouter<String>();

      // Ensure route doesn't exist
      while (router.remove('GET', '/non-existent')) {}

      // Attempt to remove a non-existent route
      expect(router.remove('GET', '/non-existent'), isFalse);
    });

    test('Router.remove should remove routes with data match', () {
      final router = createRouter<String>();

      // Clear the routes
      while (router.remove('GET', '/multi-data')) {}

      // Add multiple routes with the same path but different data
      router.add('GET', '/multi-data', 'data1');
      router.add('GET', '/multi-data', 'data2');
      router.add('GET', '/multi-data', 'data3');

      // Find and print all routes before removal
      final beforeRoutes = router.findAll('GET', '/multi-data');
      final beforeData = beforeRoutes.map((r) => r.data).toList();
      print('Routes before removal: $beforeData');

      // Remove a route with specific data
      expect(router.remove('GET', '/multi-data', 'data2'), isTrue);

      // Find and verify remaining routes
      final afterRoutes = router.findAll('GET', '/multi-data');
      final afterData = afterRoutes.map((r) => r.data).toList();
      print('Routes after removal: $afterData');

      // Verify data2 was removed
      expect(afterData, contains('data1'));
      expect(afterData, contains('data3'));
      expect(afterData, isNot(contains('data2')));

      // Verify the count decreased
      expect(afterRoutes.length, lessThan(beforeRoutes.length));
    });

    test('Router.remove should not remove other HTTP methods', () {
      final router = createRouter<String>();

      // Clear the routes
      while (router.remove('GET', '/method-test')) {}
      while (router.remove('POST', '/method-test')) {}

      // Add routes with different HTTP methods
      router.add('GET', '/method-test', 'get-data');
      router.add('POST', '/method-test', 'post-data');

      // Remove only the GET route
      expect(router.remove('GET', '/method-test'), isTrue);

      // Verify GET route was removed but POST remains
      expect(router.find('GET', '/method-test'), isNull);
      expect(router.find('POST', '/method-test')?.data, equals('post-data'));
    });

    test('Router.remove should handle complex path patterns', () {
      final router = createRouter<String>();

      // Clear the routes
      while (router.remove('GET', '/api/users/:id/posts/:postId')) {}

      // Add complex parameter route
      router.add('GET', '/api/users/:id/posts/:postId', 'complex-data');

      // Verify route matches
      expect(router.find('GET', '/api/users/123/posts/456')?.data,
          equals('complex-data'));

      // Remove route
      expect(router.remove('GET', '/api/users/:id/posts/:postId'), isTrue);

      // Verify route no longer matches
      expect(router.find('GET', '/api/users/123/posts/456'), isNull);
    });
  });
}
