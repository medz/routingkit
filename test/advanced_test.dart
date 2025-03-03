import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('Advanced Routing Patterns', () {
    test('Complex path patterns', () {
      final router = createRouter<String>();

      // Add complex route patterns
      router.add(
          'GET',
          '/api/v1/users/:userId/posts/:postId/comments/:commentId',
          'complex-route');
      router.add('GET', '/api/v1/users/:userId/settings', 'user-settings');
      router.add(null, '/api/v1/public/**', 'public-api');

      // Test full match with multiple parameters
      final complexResult =
          router.find('GET', '/api/v1/users/123/posts/456/comments/789');
      expect(complexResult?.data, equals('complex-route'));
      expect(complexResult?.params,
          equals({'userId': '123', 'postId': '456', 'commentId': '789'}));

      // Test partial match with only user ID
      final settingsResult = router.find('GET', '/api/v1/users/123/settings');
      expect(settingsResult?.data, equals('user-settings'));
      expect(settingsResult?.params, equals({'userId': '123'}));

      // Test wildcard match
      final publicResult = router.find('POST', '/api/v1/public/anything/here');
      expect(publicResult?.data, equals('public-api'));
    });

    test('Path normalization', () {
      final router = createRouter<String>();
      router.add('GET', '/normalize', 'normalize');
      router.add('GET', '/path/with/trailing/slash/', 'trailing-slash');

      // Test normal path
      expect(router.find('GET', '/normalize')?.data, equals('normalize'));

      // Test trailing slash
      expect(router.find('GET', '/path/with/trailing/slash')?.data,
          equals('trailing-slash'));
      expect(router.find('GET', '/path/with/trailing/slash/')?.data,
          equals('trailing-slash'));

      // Test extra slashes
      router.add('GET', '//extra//slashes//', 'extra-slashes');
      expect(
          router.find('GET', '/extra/slashes')?.data, equals('extra-slashes'));
      expect(router.find('GET', '//extra//slashes//')?.data,
          equals('extra-slashes'));
    });
  });

  group('Parameter Extraction', () {
    test('Complex parameter extraction', () {
      final router = createRouter<String>();

      // Add routes with different parameter types
      router.add('GET', '/params/:required/*/:mixed/**', 'mixed-params');

      final result =
          router.find('GET', '/params/required-value/optional-value/a/b/c');
      expect(result?.data, equals('mixed-params'));

      final params = result?.params;
      expect(params, isNotNull);
      expect(params?['required'], equals('required-value'));
      // Check optional parameter
      expect(params?['_0'], equals('optional-value'));
      // Check parameter count
      expect(params?.length, greaterThanOrEqualTo(2));
    });

    test('Simple path parameters', () {
      final router = createRouter<String>();

      // Add route with simple parameter
      router.add('GET', '/products/:id', 'product-details');

      // Test parameter matching
      final validResult = router.find('GET', '/products/123');
      expect(validResult?.data, equals('product-details'));
      expect(validResult?.params, equals({'id': '123'}));
    });
  });

  group('Edge Cases', () {
    test('Root path', () {
      final router = createRouter<String>();
      router.add('GET', '/', 'root');

      expect(router.find('GET', '/')?.data, equals('root'));
      expect(router.find('GET', '')?.data, equals('root'));
    });

    test('Empty router', () {
      final router = createRouter<String>();

      // Empty router should not match any path
      expect(router.find('GET', '/'), isNull);
      expect(router.find('GET', '/any/path'), isNull);
      expect(router.findAll('GET', '/any/path'), isEmpty);
    });

    test('Very long path', () {
      final router = createRouter<String>();

      // Create a very long path
      final segments = List.generate(20, (i) => 'segment$i');
      final longPath = '/${segments.join('/')}';

      router.add('GET', longPath, 'long-path');

      // Test long path
      expect(router.find('GET', longPath)?.data, equals('long-path'));
    });
  });

  group('Multiple Route Matching and Priority', () {
    test('Route priority', () {
      final router = createRouter<String>();

      // Add multiple routes that could match the same path
      router.add('GET', '/priority/:param', 'param-route');
      router.add('GET', '/priority/specific', 'specific-route');
      router.add('GET', '/priority/**', 'catch-all-route');

      // Static routes should have highest priority
      expect(router.find('GET', '/priority/specific')?.data,
          equals('specific-route'));

      // Parameter routes should have second priority
      expect(
          router.find('GET', '/priority/other')?.data, equals('param-route'));

      // Wildcard routes should have lowest priority
      final allMatches = router.findAll('GET', '/priority/specific');
      expect(
          allMatches.map((r) => r.data).toList(), contains('catch-all-route'));
    });

    test('Order of routes in separate router instance', () {
      // Use a new router instance to avoid conflicts with other tests
      final router = createRouter<String>();

      // Add routes in order
      router.add('GET', '/test-order/1', 'first');
      router.add('GET', '/test-order/1', 'second');
      router.add('GET', '/test-order/1', 'third');

      // find() should always return the first match
      expect(router.find('GET', '/test-order/1')?.data, equals('first'));

      // findAll() should return all matches in the order they were added
      final all =
          router.findAll('GET', '/test-order/1').map((r) => r.data).toList();
      expect(all, containsAll(['first', 'second', 'third']));

      // Verify first match is correct
      expect(all.first, equals('first'));
    });
  });

  group('Method Matching', () {
    test('Exact method matching', () {
      final router = createRouter<String>();

      router.add('GET', '/methods', 'get-route');
      router.add('POST', '/methods', 'post-route');
      router.add('PUT', '/methods', 'put-route');

      expect(router.find('GET', '/methods')?.data, equals('get-route'));
      expect(router.find('POST', '/methods')?.data, equals('post-route'));
      expect(router.find('PUT', '/methods')?.data, equals('put-route'));
      expect(router.find('DELETE', '/methods'), isNull);
    });

    test('Wildcard method matching', () {
      final router = createRouter<String>();

      router.add(null, '/wildcard-method', 'any-method');
      router.add('GET', '/wildcard-method', 'get-method');

      // Exact method should have priority over wildcard
      expect(
          router.find('GET', '/wildcard-method')?.data, equals('get-method'));
      expect(
          router.find('POST', '/wildcard-method')?.data, equals('any-method'));

      // findAll should include all matches
      final allGetMethods = router.findAll('GET', '/wildcard-method');
      expect(allGetMethods.map((r) => r.data).toList(),
          containsAll(['get-method', 'any-method']));
    });

    test('Method case sensitivity', () {
      final router = createRouter<String>();

      router.add('get', '/case', 'lowercase');
      router.add('GET', '/case', 'uppercase');

      // Method matching should be case sensitive
      expect(router.find('get', '/case')?.data, equals('lowercase'));
      expect(router.find('GET', '/case')?.data, equals('uppercase'));
    });
  });
}
