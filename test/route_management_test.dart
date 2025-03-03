import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('Route Management', () {
    test('Adding routes', () {
      final router = createRouter<String>();

      // Add static route
      router.add('GET', '/test', 'test-data');
      expect(router.find('GET', '/test')?.data, equals('test-data'));

      // Add parameter route
      router.add('GET', '/users/:id', 'user-data');
      expect(router.find('GET', '/users/123')?.data, equals('user-data'));

      // Add wildcard route
      router.add('GET', '/assets/**', 'assets-data');
      expect(router.find('GET', '/assets/images/logo.png')?.data,
          equals('assets-data'));
    });

    test('Removing static routes', () {
      final router = createRouter<String>();

      // Add route
      router.add('GET', '/test-route', 'test-data');

      // Verify route exists
      expect(router.find('GET', '/test-route')?.data, equals('test-data'));

      // Remove route
      expect(router.remove('GET', '/test-route'), isTrue);

      // Verify route no longer exists
      expect(router.find('GET', '/test-route'), isNull);
    });

    test('Removing parameter routes', () {
      final router = createRouter<String>();

      // Add parameter route
      router.add('GET', '/users/:id', 'user-data');

      // Verify route matches
      expect(router.find('GET', '/users/123')?.data, equals('user-data'));

      // Remove route
      expect(router.remove('GET', '/users/:id'), isTrue);

      // Verify route no longer matches
      expect(router.find('GET', '/users/123'), isNull);
    });

    test('Removing wildcard routes', () {
      final router = createRouter<String>();

      // Add wildcard route
      router.add('GET', '/api/**', 'api-data');

      // Verify route matches
      expect(router.find('GET', '/api/users/123')?.data, equals('api-data'));

      // Remove route
      expect(router.remove('GET', '/api/**'), isTrue);

      // Verify route no longer matches
      expect(router.find('GET', '/api/users/123'), isNull);
    });

    test('Removing routes with specific data', () {
      final router = createRouter<String>();

      // Add multiple routes with same path but different data
      router.add('GET', '/test', 'data1');
      router.add('GET', '/test', 'data2');
      router.add('GET', '/test', 'data3');

      // Verify all routes exist
      final matches = router.findAll('GET', '/test');
      expect(matches.map((r) => r.data).toList(),
          containsAll(['data1', 'data2', 'data3']));

      // Remove specific route
      expect(router.remove('GET', '/test', 'data2'), isTrue);

      // Verify only specific route was removed
      final remainingMatches = router.findAll('GET', '/test');
      expect(remainingMatches.map((r) => r.data).toList(),
          containsAll(['data1', 'data3']));
    });

    test('Removing non-existent routes', () {
      final router = createRouter<String>();

      // Try to remove non-existent route
      expect(router.remove('GET', '/not-exists'), isFalse);

      // Try to remove route with non-existent data
      router.add('GET', '/test', 'test-data');
      expect(router.remove('GET', '/test', 'non-existent-data'), isFalse);
    });

    test('Removing routes with different methods', () {
      final router = createRouter<String>();

      // Add routes with different methods
      router.add('GET', '/test', 'get-data');
      router.add('POST', '/test', 'post-data');

      // Remove only GET route
      expect(router.remove('GET', '/test'), isTrue);

      // Verify GET route was removed but POST remains
      expect(router.find('GET', '/test'), isNull);
      expect(router.find('POST', '/test')?.data, equals('post-data'));
    });
  });
}
