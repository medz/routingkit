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

    test('Optional parameter matching', () {
      final router = createRouter<String>();

      router.add('GET', '/files/:filename.:format?', 'file-handler');

      // Test with format
      final withFormat = router.find('GET', '/files/document.pdf');
      expect(withFormat?.data, equals('file-handler'));
      expect(withFormat?.params?.containsKey('filename'), isTrue);
      expect(withFormat?.params?['filename'], contains('document'));

      // Test without format
      final withoutFormat = router.find('GET', '/files/document');
      expect(withoutFormat?.data, equals('file-handler'));
      expect(withoutFormat?.params?.containsKey('filename'), isTrue);
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
}
