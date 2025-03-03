import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP Method Tests', () {
    test('Method normalization', () {
      final router = createRouter<String>();

      // Add routes with different method cases
      router.add('get', '/normalize', 'get-data');
      router.add('post', '/normalize', 'post-data');
      router.add('put', '/normalize', 'put-data');

      // Verify that methods are normalized to uppercase
      expect(router.find('GET', '/normalize')?.data, equals('get-data'));
      expect(router.find('POST', '/normalize')?.data, equals('post-data'));
      expect(router.find('PUT', '/normalize')?.data, equals('put-data'));

      // Verify that different cases of the same method all match
      expect(router.find('get', '/normalize')?.data, equals('get-data'));
      expect(router.find('Get', '/normalize')?.data, equals('get-data'));
      expect(router.find('GET', '/normalize')?.data, equals('get-data'));

      // Test with non-standard HTTP method
      router.add('custom_method', '/custom', 'custom-data');
      expect(
          router.find('CUSTOM_METHOD', '/custom')?.data, equals('custom-data'));
      expect(
          router.find('custom_method', '/custom')?.data, equals('custom-data'));
      expect(
          router.find('CUSTOM_METHOD', '/custom')?.data, equals('custom-data'));
    });

    test('Method case sensitivity and route preservation', () {
      final router = createRouter<String>();

      // Add routes with different cases
      router.add('get', '/case', 'lowercase');
      router.add('GET', '/case', 'uppercase');
      router.add('Get', '/case', 'mixedcase');

      // Verify that the first added route is preserved
      expect(router.find('get', '/case')?.data, equals('lowercase'));
      expect(router.find('GET', '/case')?.data, equals('lowercase'));
      expect(router.find('Get', '/case')?.data, equals('lowercase'));

      // Verify that subsequent additions with different cases don't override
      expect(router.find('GET', '/case')?.data, equals('lowercase'));
      expect(router.find('Get', '/case')?.data, equals('lowercase'));
    });

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

    test('Method matching with parameters', () {
      final router = createRouter<String>();

      router.add('GET', '/users/:id', 'get-user');
      router.add('POST', '/users/:id', 'create-user');
      router.add('PUT', '/users/:id', 'update-user');
      router.add('DELETE', '/users/:id', 'delete-user');

      // Test different methods with parameters
      expect(router.find('GET', '/users/123')?.data, equals('get-user'));
      expect(router.find('POST', '/users/123')?.data, equals('create-user'));
      expect(router.find('PUT', '/users/123')?.data, equals('update-user'));
      expect(router.find('DELETE', '/users/123')?.data, equals('delete-user'));

      // Test case insensitivity with parameters
      expect(router.find('get', '/users/123')?.data, equals('get-user'));
      expect(router.find('post', '/users/123')?.data, equals('create-user'));
      expect(router.find('put', '/users/123')?.data, equals('update-user'));
      expect(router.find('delete', '/users/123')?.data, equals('delete-user'));
    });
  });
}
