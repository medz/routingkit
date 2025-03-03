import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('Router Removal Functionality', () {
    test('Remove basic route', () {
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/users')) {}

      // Add route
      router.add('GET', '/users', 'get-users');

      // Verify successful addition
      expect(router.find('GET', '/users')?.data, equals('get-users'));

      // Remove route
      final removed = router.remove('GET', '/users');
      expect(removed, isTrue);

      // Verify successful removal
      expect(router.find('GET', '/users'), isNull);
    });

    test('Remove route with specific data', () {
      // Create a new router instance
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/multi-test')) {}

      // Add multiple routes with the same path
      router.add('GET', '/multi-test', 'data1');
      router.add('GET', '/multi-test', 'data2');
      router.add('GET', '/multi-test', 'data3');

      // Get initial state
      final initialRoutes = router.findAll('GET', '/multi-test');
      print('Initial route count: ${initialRoutes.length}');

      // Remove route with specific data
      final removed = router.remove('GET', '/multi-test', 'data2');
      expect(removed, isTrue);

      // Verify specific route was removed
      final remainingRoutes = router.findAll('GET', '/multi-test');
      final dataList = remainingRoutes.map((r) => r.data).toList();
      print('Routes after removal: $dataList');

      // Verify route count decreased
      expect(remainingRoutes.length, lessThan(initialRoutes.length));

      // Verify data
      expect(dataList, contains('data1'));
      expect(dataList, contains('data3'));
      expect(dataList, isNot(contains('data2')));
    });

    test('Remove parameter route', () {
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/users/:id')) {}

      // Add parameter route
      router.add('GET', '/users/:id', 'user-route');

      // Verify successful addition
      expect(router.find('GET', '/users/123')?.data, equals('user-route'));

      // Remove route
      final removed = router.remove('GET', '/users/:id');
      expect(removed, isTrue);

      // Verify successful removal
      expect(router.find('GET', '/users/123'), isNull);
    });

    test('Remove wildcard route', () {
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/api/**')) {}

      // Add wildcard route
      router.add('GET', '/api/**', 'api-route');

      // Verify successful addition
      expect(router.find('GET', '/api/users/123')?.data, equals('api-route'));

      // Remove route
      final removed = router.remove('GET', '/api/**');
      expect(removed, isTrue);

      // Verify successful removal
      expect(router.find('GET', '/api/users/123'), isNull);
    });

    test('Remove non-existent route', () {
      final router = createRouter<String>();

      // Ensure route doesn't exist
      while (router.remove('GET', '/not-exists')) {}

      // Try to remove non-existent route
      final removed = router.remove('GET', '/not-exists');
      expect(removed, isFalse);
    });
  });

  group('Route Update Simulation', () {
    test('Update route by removing and re-adding', () {
      final router = createRouter<String>();

      // Ensure route doesn't exist
      while (router.remove('GET', '/update')) {}

      // Add original route
      router.add('GET', '/update', 'original');

      // Verify successful addition
      expect(router.find('GET', '/update')?.data, equals('original'));

      // Remove original route
      while (router.remove('GET', '/update')) {}

      // Add updated route
      router.add('GET', '/update', 'updated');

      // Verify update successful
      expect(router.find('GET', '/update')?.data, equals('updated'));
    });
  });

  group('Complex Scenario Tests', () {
    test('Route removal with multiple methods', () {
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/methods')) {}
      while (router.remove('POST', '/methods')) {}
      while (router.remove('PUT', '/methods')) {}

      // Add routes with multiple methods
      router.add('GET', '/methods', 'get');
      router.add('POST', '/methods', 'post');
      router.add('PUT', '/methods', 'put');

      // Remove specific method route
      router.remove('POST', '/methods');

      // Verify only specified method route was removed
      expect(router.find('GET', '/methods')?.data, equals('get'));
      expect(router.find('POST', '/methods'), isNull);
      expect(router.find('PUT', '/methods')?.data, equals('put'));
    });

    test('Add same route after removal', () {
      final router = createRouter<String>();

      // Ensure route doesn't exist
      while (router.remove('GET', '/reuse')) {}

      // Add original route
      router.add('GET', '/reuse', 'original');

      // Remove route
      while (router.remove('GET', '/reuse')) {}

      // Add new route with same path
      router.add('GET', '/reuse', 'new');

      // Verify new route is effective
      expect(router.find('GET', '/reuse')?.data, equals('new'));
    });

    test('Complex add and remove sequence', () {
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/complex/static')) {}
      while (router.remove('GET', '/complex/:param')) {}
      while (router.remove('GET', '/complex/**')) {}

      // Add some routes
      router.add('GET', '/complex/static', 'static');
      router.add('GET', '/complex/:param', 'param');
      router.add('GET', '/complex/**', 'wildcard');

      // Remove one route
      router.remove('GET', '/complex/:param');

      // Verify other routes still work properly
      expect(router.find('GET', '/complex/static')?.data, equals('static'));
      expect(router.find('GET', '/complex/123'), isNotNull); // Wildcard match
      expect(router.find('GET', '/complex/123')?.data, equals('wildcard'));

      // Add another route
      router.add('GET', '/complex/:id', 'new-param');

      // Verify new route works
      expect(router.find('GET', '/complex/456')?.data, equals('new-param'));
    });
  });

  group('Extreme Cases', () {
    test('Large number of route adds and removes', () {
      final router = createRouter<String>();

      // Clear any existing routes
      for (var i = 0; i < 100; i++) {
        while (router.remove('GET', '/route/$i')) {}
      }

      // Add many routes
      for (var i = 0; i < 100; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      // Remove half of the routes
      for (var i = 0; i < 50; i++) {
        while (router.remove('GET', '/route/$i')) {}
      }

      // Verify removal and retained routes
      for (var i = 0; i < 100; i++) {
        final result = router.find('GET', '/route/$i');
        if (i < 50) {
          expect(result, isNull, reason: 'Route /route/$i should be removed');
        } else {
          expect(result?.data, equals('route-$i'),
              reason: 'Route /route/$i should be retained');
        }
      }
    });

    test('Tree structure integrity after node removal', () {
      final router = createRouter<String>();

      // Clear any existing routes
      while (router.remove('GET', '/a/b/c/d')) {}
      while (router.remove('GET', '/a/b/x/y')) {}
      while (router.remove('GET', '/a/b/c/e')) {}

      // Create a path tree
      router.add('GET', '/a/b/c/d', 'abcd');
      router.add('GET', '/a/b/x/y', 'abxy');
      router.add('GET', '/a/b/c/e', 'abce');

      // Remove middle node route
      while (router.remove('GET', '/a/b/c/d')) {}

      // Verify other routes still valid
      expect(router.find('GET', '/a/b/c/d'), isNull);
      expect(router.find('GET', '/a/b/x/y')?.data, equals('abxy'));
      expect(router.find('GET', '/a/b/c/e')?.data, equals('abce'));
    });
  });
}
