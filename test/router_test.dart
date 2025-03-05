import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('Router Core Functionality', () {
    test('Static route matching', () {
      final router = createRouter<String>();

      router.add('GET', '/users', 'users-list');
      router.add('GET', '/products', 'products-list');

      expect(router.find('GET', '/users')?.data, equals('users-list'));
      expect(router.find('GET', '/products')?.data, equals('products-list'));
      expect(router.find('GET', '/categories'), isNull);
    });

    test('Parameter route matching', () {
      final router = createRouter<String>();

      router.add('GET', '/users/:id', 'user-detail');
      router.add('GET', '/products/:id/reviews', 'product-reviews');

      // Test single parameter
      final userResult = router.find('GET', '/users/123');
      expect(userResult?.data, equals('user-detail'));
      expect(userResult?.params, equals({'id': '123'}));

      // Test multiple parameters
      final productResult = router.find('GET', '/products/456/reviews');
      expect(productResult?.data, equals('product-reviews'));
      expect(productResult?.params, equals({'id': '456'}));
    });

    test('Optional parameter matching with standard params', () {
      final router = createRouter<String>();

      // 使用通配符参数来模拟可选参数
      router.add('GET', '/files/:filename/*', 'file-handler-with-format');
      // 添加不带格式的路由
      router.add('GET', '/files/:filename', 'file-handler');

      // Test with format
      final withFormat = router.find('GET', '/files/document/pdf');
      expect(withFormat?.data, equals('file-handler-with-format'));
      expect(withFormat?.params?.containsKey('filename'), isTrue);
      expect(withFormat?.params?['filename'], equals('document'));
      expect(withFormat?.params?.containsKey('_0'), isTrue);
      expect(withFormat?.params?['_0'], equals('pdf'));

      // Test without format
      final withoutFormat = router.find('GET', '/files/readme');
      expect(withoutFormat?.data, equals('file-handler'));
      expect(withoutFormat?.params?.containsKey('filename'), isTrue);
      expect(withoutFormat?.params?['filename'], equals('readme'));
      expect(withoutFormat?.params?.containsKey('_0'), isFalse);
    });

    test('Wildcard route matching', () {
      final router = createRouter<String>();

      router.add('GET', '/assets/**', 'static-assets');
      router.add('GET', '/docs/**:path', 'documentation');

      // Test simple wildcard
      final assetsResult = router.find('GET', '/assets/images/logo.png');
      expect(assetsResult?.data, equals('static-assets'));

      // Test named wildcard
      final docsResult = router.find('GET', '/docs/api/v1/users');
      expect(docsResult?.data, equals('documentation'));
      expect(docsResult?.params?.containsKey('path'), isTrue);
      expect(docsResult?.params?['path'], contains('api'));
    });

    test('Route priority', () {
      final router = createRouter<String>();

      // Add routes in order of specificity
      router.add('GET', '/users/:id', 'user-route');
      router.add('GET', '/users/specific', 'specific-route');
      router.add('GET', '/users/**', 'catch-all-route');

      // Static routes should have highest priority
      expect(router.find('GET', '/users/specific')?.data,
          equals('specific-route'));

      // Parameter routes should have second priority
      expect(router.find('GET', '/users/123')?.data, equals('user-route'));

      // Wildcard routes should have lowest priority
      expect(router.find('GET', '/users/other/path')?.data,
          equals('catch-all-route'));
    });

    test('Complex route patterns', () {
      final router = createRouter<String>();

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

      // Test partial match
      final settingsResult = router.find('GET', '/api/v1/users/123/settings');
      expect(settingsResult?.data, equals('user-settings'));
      expect(settingsResult?.params, equals({'userId': '123'}));

      // Test wildcard match
      final publicResult = router.find('POST', '/api/v1/public/anything/here');
      expect(publicResult?.data, equals('public-api'));
    });
  });

  group('Router Configuration', () {
    test('Custom anyMethodToken', () {
      // Create router with custom anyMethodToken
      final router = createRouter<String>(anyMethodToken: 'ANY_METHOD');

      // Add routes with different methods
      router.add('GET', '/api', 'get-api');
      router.add('POST', '/api', 'post-api');
      router.add(null, '/api', 'any-api'); // Should use ANY_METHOD token

      // Verify that find works with explicit methods
      expect(router.find('GET', '/api')?.data, equals('get-api'));
      expect(router.find('POST', '/api')?.data, equals('post-api'));

      // Verify that null method uses anyMethodToken internally
      expect(router.find(null, '/api')?.data, equals('any-api'));

      // Verify findAll returns all matches
      final allMatches = router.findAll(null, '/api');
      // Note: findAll returns multiple entries when method is null - one for each explicit method
      // plus the anyMethodToken entry
      expect(allMatches.length,
          equals(3)); // Should return exactly 3 matches without duplicates
      expect(allMatches.map((m) => m.data).contains('get-api'), isTrue);
      expect(allMatches.map((m) => m.data).contains('post-api'), isTrue);
      expect(allMatches.map((m) => m.data).contains('any-api'), isTrue);
    });

    test('Default anyMethodToken', () {
      // Create router with default anyMethodToken
      final router = createRouter<String>();

      // Add routes with different methods
      router.add('GET', '/api', 'get-api');
      router.add(null, '/api', 'any-api'); // Should use default token

      // Verify matching
      expect(router.find('GET', '/api')?.data, equals('get-api'));
      expect(router.find(null, '/api')?.data, equals('any-api'));
      expect(router.find('POST', '/api')?.data,
          equals('any-api')); // Any method should match
    });
  });

  group('Case Sensitivity', () {
    test('Case sensitive matching (default)', () {
      final router = createRouter<String>();

      router.add('GET', '/Users', 'users-uppercase');
      router.add('GET', '/users', 'users-lowercase');

      expect(router.find('GET', '/Users')?.data, equals('users-uppercase'));
      expect(router.find('GET', '/users')?.data, equals('users-lowercase'));
      expect(router.find('GET', '/USERS'), isNull);
    });

    test('Case insensitive matching', () {
      final router = createRouter<String>(caseSensitive: false);

      router.add('GET', '/Users', 'users-route');

      // All these should match the same route regardless of case
      expect(router.find('GET', '/Users')?.data, equals('users-route'));
      expect(router.find('GET', '/users')?.data, equals('users-route'));
      expect(router.find('GET', '/USERS')?.data, equals('users-route'));
      expect(router.find('GET', '/uSeRs')?.data, equals('users-route'));
    });

    test('Case insensitive with parameters', () {
      final router = createRouter<String>(caseSensitive: false);

      router.add('GET', '/Users/:ID', 'user-detail');

      final result1 = router.find('GET', '/users/123');
      expect(result1?.data, equals('user-detail'));
      expect(result1?.params, equals({'ID': '123'}));

      final result2 = router.find('GET', '/USERS/456');
      expect(result2?.data, equals('user-detail'));
      expect(result2?.params, equals({'ID': '456'}));
    });
  });
}
