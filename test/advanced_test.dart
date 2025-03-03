import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import 'utils/create_test_router.dart';

void main() {
  group('高级路由模式', () {
    test('复杂路径模式', () {
      final router = createRouter<String>();

      // 添加一些复杂的路由模式
      router.add(
          'GET',
          '/api/v1/users/:userId/posts/:postId/comments/:commentId',
          'complex-route');
      router.add('GET', '/api/v1/users/:userId/settings', 'user-settings');
      router.add(null, '/api/v1/public/**', 'public-api');

      // 测试完全匹配
      final complexResult =
          router.find('GET', '/api/v1/users/123/posts/456/comments/789');
      expect(complexResult?.data, equals('complex-route'));
      expect(complexResult?.params,
          equals({'userId': '123', 'postId': '456', 'commentId': '789'}));

      // 测试部分匹配
      final settingsResult = router.find('GET', '/api/v1/users/123/settings');
      expect(settingsResult?.data, equals('user-settings'));
      expect(settingsResult?.params, equals({'userId': '123'}));

      // 测试通配符匹配
      final publicResult = router.find('POST', '/api/v1/public/anything/here');
      expect(publicResult?.data, equals('public-api'));
    });

    test('路径规范化', () {
      final router = createRouter<String>();
      router.add('GET', '/normalize', 'normalize');
      router.add('GET', '/path/with/trailing/slash/', 'trailing-slash');

      // 测试正常路径
      expect(router.find('GET', '/normalize')?.data, equals('normalize'));

      // 测试有尾部斜杠的路径
      expect(router.find('GET', '/path/with/trailing/slash')?.data,
          equals('trailing-slash'));
      expect(router.find('GET', '/path/with/trailing/slash/')?.data,
          equals('trailing-slash'));

      // 测试多余斜杠的路径
      router.add('GET', '//extra//slashes//', 'extra-slashes');
      expect(
          router.find('GET', '/extra/slashes')?.data, equals('extra-slashes'));
      expect(router.find('GET', '//extra//slashes//')?.data,
          equals('extra-slashes'));
    });
  });

  group('参数提取', () {
    test('复杂参数提取', () {
      final router = createRouter<String>();

      // 添加具有不同类型参数的路由
      router.add('GET', '/params/:required/*/:mixed/**', 'mixed-params');

      final result =
          router.find('GET', '/params/required-value/optional-value/a/b/c');
      expect(result?.data, equals('mixed-params'));

      final params = result?.params;
      expect(params, isNotNull);
      expect(params?['required'], equals('required-value'));
      // 可选参数有值
      expect(params?['_0'], equals('optional-value'));
      // 检查参数数量
      expect(params?.length, greaterThanOrEqualTo(2));
    });

    test('简单路径参数', () {
      final router = createRouter<String>();

      // 添加简单路径参数路由
      router.add('GET', '/products/:id', 'product-details');

      // 匹配参数
      final validResult = router.find('GET', '/products/123');
      expect(validResult?.data, equals('product-details'));
      expect(validResult?.params, equals({'id': '123'}));
    });
  });

  group('边缘情况', () {
    test('根路径', () {
      final router = createRouter<String>();
      router.add('GET', '/', 'root');

      expect(router.find('GET', '/')?.data, equals('root'));
      expect(router.find('GET', '')?.data, equals('root'));
    });

    test('空路由器', () {
      final router = createRouter<String>();

      // 空路由器不应匹配任何路径
      expect(router.find('GET', '/'), isNull);
      expect(router.find('GET', '/any/path'), isNull);
      expect(router.findAll('GET', '/any/path'), isEmpty);
    });

    test('非常长的路径', () {
      final router = createRouter<String>();

      // 创建一个非常长的路径
      final segments = List.generate(20, (i) => 'segment$i');
      final longPath = '/${segments.join('/')}';

      router.add('GET', longPath, 'long-path');

      // 测试长路径
      expect(router.find('GET', longPath)?.data, equals('long-path'));
    });
  });

  group('多路由匹配和优先级', () {
    test('路由优先级', () {
      final router = createRouter<String>();

      // 添加多个可能匹配同一路径的路由
      router.add('GET', '/priority/:param', 'param-route');
      router.add('GET', '/priority/specific', 'specific-route');
      router.add('GET', '/priority/**', 'catch-all-route');

      // 优先匹配静态路由
      expect(router.find('GET', '/priority/specific')?.data,
          equals('specific-route'));

      // 其次匹配参数路由
      expect(
          router.find('GET', '/priority/other')?.data, equals('param-route'));

      // 最后匹配通配符路由
      final allMatches = router.findAll('GET', '/priority/specific');
      expect(
          allMatches.map((r) => r.data).toList(), contains('catch-all-route'));
    });

    test('独立路由实例的添加顺序', () {
      // 使用全新的路由器实例，避免与其他测试的冲突
      final router = createRouter<String>();

      // 添加顺序
      router.add('GET', '/test-order/1', 'first');
      router.add('GET', '/test-order/1', 'second');
      router.add('GET', '/test-order/1', 'third');

      // 验证find总是返回第一个匹配
      expect(router.find('GET', '/test-order/1')?.data, equals('first'));

      // 验证findAll返回所有匹配，并且包含期望的项
      final all =
          router.findAll('GET', '/test-order/1').map((r) => r.data).toList();
      expect(all, containsAll(['first', 'second', 'third']));

      // 验证第一个匹配是正确的
      expect(all.first, equals('first'));
    });
  });

  group('方法匹配', () {
    test('精确方法匹配', () {
      final router = createRouter<String>();

      router.add('GET', '/methods', 'get-route');
      router.add('POST', '/methods', 'post-route');
      router.add('PUT', '/methods', 'put-route');

      expect(router.find('GET', '/methods')?.data, equals('get-route'));
      expect(router.find('POST', '/methods')?.data, equals('post-route'));
      expect(router.find('PUT', '/methods')?.data, equals('put-route'));
      expect(router.find('DELETE', '/methods'), isNull);
    });

    test('通配符方法匹配', () {
      final router = createRouter<String>();

      router.add(null, '/wildcard-method', 'any-method');
      router.add('GET', '/wildcard-method', 'get-method');

      // 验证精确方法匹配比通配符方法优先
      expect(
          router.find('GET', '/wildcard-method')?.data, equals('get-method'));
      expect(
          router.find('POST', '/wildcard-method')?.data, equals('any-method'));

      // 验证findAll包含所有匹配
      final allGetMethods = router.findAll('GET', '/wildcard-method');
      expect(allGetMethods.map((r) => r.data).toList(),
          containsAll(['get-method', 'any-method']));
    });

    test('方法大小写敏感性', () {
      final router = createRouter<String>();

      router.add('get', '/case', 'lowercase');
      router.add('GET', '/case', 'uppercase');

      // 验证方法大小写敏感
      expect(router.find('get', '/case')?.data, equals('lowercase'));
      expect(router.find('GET', '/case')?.data, equals('uppercase'));
    });
  });
}
