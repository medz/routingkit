import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import 'utils/create_test_router.dart';

void main() {
  group('Performance Tests', () {
    test('Large-scale route adding and finding', () {
      final router = createRouter<String>();
      final int routeCount = 1000;

      // Measure time to add routes
      final addStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      final addDuration = DateTime.now().difference(addStart);
      print('Adding $routeCount routes took: ${addDuration.inMilliseconds}ms');

      // Measure time to find static routes
      final staticStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/route/$i');
      }

      final staticDuration = DateTime.now().difference(staticStart);
      print(
          'Finding $routeCount static routes took: ${staticDuration.inMilliseconds}ms');

      // Measure time to find non-existent routes
      final notFoundStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/not-found/$i');
      }

      final notFoundDuration = DateTime.now().difference(notFoundStart);
      print(
          'Finding $routeCount non-existent routes took: ${notFoundDuration.inMilliseconds}ms');

      // Ensure performance is within reasonable range
      expect(addDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each route should take less than 1ms to add');
      expect(staticDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each static route should take less than 1ms to find');
      expect(notFoundDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: 'Each non-existent route should take less than 1ms to find');
    });

    test('Multiple parameter routes', () {
      final router = createRouter<String>();

      router.add('GET', '/user/:id/profile/:field', 'user-profile');
      router.add('GET', '/user/:id/settings', 'user-settings');

      // Test first route
      final profileResult = router.find('GET', '/user/123/profile/name');
      expect(profileResult?.data, equals('user-profile'));
      expect(profileResult?.params, equals({'id': '123', 'field': 'name'}));

      // Test second route
      final settingsResult = router.find('GET', '/user/123/settings');
      expect(settingsResult?.data, equals('user-settings'));
      expect(settingsResult?.params, equals({'id': '123'}));
    });
  });

  group('Invalid Input Handling', () {
    test('Invalid path handling', () {
      final router = createRouter<String>();

      // Try adding empty route path
      router.add('GET', '', 'empty-path');

      // Empty path should be normalized to root path
      expect(router.find('GET', '')?.data, equals('empty-path'));
      expect(router.find('GET', '/')?.data, equals('empty-path'));

      // Try adding path without leading slash
      router.add('GET', 'no-leading-slash', 'no-leading-slash');

      // Should match normalized path
      expect(router.find('GET', 'no-leading-slash')?.data,
          equals('no-leading-slash'));
      expect(router.find('GET', '/no-leading-slash')?.data,
          equals('no-leading-slash'));
    });

    test('Invalid HTTP method handling', () {
      final router = createRouter<String>();

      // Add HTTP methods with different cases
      router.add('get', '/case-test', 'lowercase-get');
      router.add('GET', '/case-test', 'uppercase-get');
      router.add('Get', '/case-test', 'mixedcase-get');

      // Verify HTTP method case sensitivity
      expect(router.find('get', '/case-test')?.data, equals('lowercase-get'));
      expect(router.find('GET', '/case-test')?.data, equals('uppercase-get'));
      expect(router.find('Get', '/case-test')?.data, equals('mixedcase-get'));

      // Add non-standard HTTP method
      router.add('CUSTOM_METHOD', '/custom', 'custom-method');

      // Non-standard HTTP method should also match
      expect(router.find('CUSTOM_METHOD', '/custom')?.data,
          equals('custom-method'));
    });

    test('Special character handling', () {
      final router = createRouter<String>();

      // Add path with special characters
      router.add('GET', '/special/chars', 'special-chars');

      // Special character path should match normally
      expect(
          router.find('GET', '/special/chars')?.data, equals('special-chars'));
    });
  });

  group('Complex Logic Combination Tests', () {
    test('Combining multiple route types', () {
      final router = createRouter<String>();

      // Clear any existing routes
      router.remove('GET', '/multi-match/specific');
      router.remove('GET', '/multi-match/:param');
      router.remove(null, '/multi-match/:param');

      // Add combination of different route types
      router.add('GET', '/api/users', 'users-list');
      router.add('GET', '/api/users/:id', 'user-detail');
      router.add('POST', '/api/users/:id', 'user-update');
      router.add(null, '/api/public/**', 'public-api');
      router.add('GET', '/api/admin/:section/*/**', 'admin-wildcard');

      // Test various combinations of lookups
      expect(router.find('GET', '/api/users')?.data, equals('users-list'));
      expect(router.find('GET', '/api/users/123')?.data, equals('user-detail'));
      expect(
          router.find('POST', '/api/users/123')?.data, equals('user-update'));
      expect(router.find('DELETE', '/api/public/docs')?.data,
          equals('public-api'));

      // Test complex wildcard and parameter combination
      final adminResult =
          router.find('GET', '/api/admin/reports/monthly/2023/04');
      expect(adminResult?.data, equals('admin-wildcard'));
      expect(adminResult?.params?['section'], equals('reports'));

      // Test findAll complex scenario (create new router to avoid conflicts)
      final multiRouter = createRouter<String>();
      multiRouter.add(null, '/multi-match/:param', 'multi-1');
      multiRouter.add('GET', '/multi-match/:param', 'multi-2');
      multiRouter.add('GET', '/multi-match/specific', 'multi-3');

      final multiMatches = multiRouter.findAll('GET', '/multi-match/specific');
      expect(multiMatches.length,
          greaterThanOrEqualTo(2)); // Should match at least 2 routes

      // Verify static route exists in results
      expect(multiMatches.map((r) => r.data).toList(), contains('multi-3'));
    });
  });
}
