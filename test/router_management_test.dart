import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import 'utils/create_test_router.dart';

void main() {
  group('Router 删除功能', () {
    test('删除基本路由', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      while (router.remove('GET', '/users')) {}

      // 添加路由
      router.add('GET', '/users', 'get-users');

      // 验证添加成功
      expect(router.find('GET', '/users')?.data, equals('get-users'));

      // 删除路由
      final removed = router.remove('GET', '/users');
      expect(removed, isTrue);

      // 验证删除成功
      expect(router.find('GET', '/users'), isNull);
    });

    test('删除特定数据的路由 - 不验证初始数量', () {
      // 创建全新的路由器实例
      final router = createRouter<String>();

      // 清除可能存在的所有路由
      while (router.remove('GET', '/multi-test')) {}

      // 添加多个具有相同路径的路由
      router.add('GET', '/multi-test', 'data1');
      router.add('GET', '/multi-test', 'data2');
      router.add('GET', '/multi-test', 'data3');

      // 获取初始状态下的所有路由
      final initialRoutes = router.findAll('GET', '/multi-test');
      print('初始路由数量: ${initialRoutes.length}');

      // 删除特定数据的路由
      final removed = router.remove('GET', '/multi-test', 'data2');
      expect(removed, isTrue);

      // 验证特定数据的路由已被删除
      final remainingRoutes = router.findAll('GET', '/multi-test');
      final dataList = remainingRoutes.map((r) => r.data).toList();
      print('删除后路由: $dataList');

      // 验证路由数量减少
      expect(remainingRoutes.length, lessThan(initialRoutes.length));

      // 验证数据
      expect(dataList, contains('data1'));
      expect(dataList, contains('data3'));
      expect(dataList, isNot(contains('data2')));
    });

    test('删除参数路由', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      while (router.remove('GET', '/users/:id')) {}

      // 添加参数路由
      router.add('GET', '/users/:id', 'user-route');

      // 验证添加成功
      expect(router.find('GET', '/users/123')?.data, equals('user-route'));

      // 删除路由
      final removed = router.remove('GET', '/users/:id');
      expect(removed, isTrue);

      // 验证删除成功
      expect(router.find('GET', '/users/123'), isNull);
    });

    test('删除通配符路由', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      while (router.remove('GET', '/api/**')) {}

      // 添加通配符路由
      router.add('GET', '/api/**', 'api-route');

      // 验证添加成功
      expect(router.find('GET', '/api/users/123')?.data, equals('api-route'));

      // 删除路由
      final removed = router.remove('GET', '/api/**');
      expect(removed, isTrue);

      // 验证删除成功
      expect(router.find('GET', '/api/users/123'), isNull);
    });

    test('删除不存在的路由', () {
      final router = createRouter<String>();

      // 确保路由不存在
      while (router.remove('GET', '/not-exists')) {}

      // 尝试删除不存在的路由
      final removed = router.remove('GET', '/not-exists');
      expect(removed, isFalse);
    });
  });

  group('路由更新模拟', () {
    test('通过删除和重新添加更新路由', () {
      final router = createRouter<String>();

      // 确保路由不存在
      while (router.remove('GET', '/update')) {}

      // 添加原始路由
      router.add('GET', '/update', 'original');

      // 验证添加成功
      expect(router.find('GET', '/update')?.data, equals('original'));

      // 删除原始路由
      while (router.remove('GET', '/update')) {}

      // 添加更新后的路由
      router.add('GET', '/update', 'updated');

      // 验证更新成功
      expect(router.find('GET', '/update')?.data, equals('updated'));
    });
  });

  group('复杂场景测试', () {
    test('具有多个方法的路由删除', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      while (router.remove('GET', '/methods')) {}
      while (router.remove('POST', '/methods')) {}
      while (router.remove('PUT', '/methods')) {}

      // 添加多个方法的路由
      router.add('GET', '/methods', 'get');
      router.add('POST', '/methods', 'post');
      router.add('PUT', '/methods', 'put');

      // 删除特定方法的路由
      router.remove('POST', '/methods');

      // 验证只删除了指定方法的路由
      expect(router.find('GET', '/methods')?.data, equals('get'));
      expect(router.find('POST', '/methods'), isNull);
      expect(router.find('PUT', '/methods')?.data, equals('put'));
    });

    test('删除后再添加相同路由', () {
      final router = createRouter<String>();

      // 确保路由不存在
      while (router.remove('GET', '/reuse')) {}

      // 添加原始路由
      router.add('GET', '/reuse', 'original');

      // 删除路由
      while (router.remove('GET', '/reuse')) {}

      // 再次添加同名路由
      router.add('GET', '/reuse', 'new');

      // 验证新路由生效
      expect(router.find('GET', '/reuse')?.data, equals('new'));
    });

    test('复杂的添加和删除顺序', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      while (router.remove('GET', '/complex/static')) {}
      while (router.remove('GET', '/complex/:param')) {}
      while (router.remove('GET', '/complex/**')) {}

      // 添加一些路由
      router.add('GET', '/complex/static', 'static');
      router.add('GET', '/complex/:param', 'param');
      router.add('GET', '/complex/**', 'wildcard');

      // 删除一个路由
      router.remove('GET', '/complex/:param');

      // 验证其他路由仍然正常工作
      expect(router.find('GET', '/complex/static')?.data, equals('static'));
      expect(router.find('GET', '/complex/123'), isNotNull); // 通配符匹配
      expect(router.find('GET', '/complex/123')?.data, equals('wildcard'));

      // 添加另一个路由
      router.add('GET', '/complex/:id', 'new-param');

      // 验证新路由正常工作
      expect(router.find('GET', '/complex/456')?.data, equals('new-param'));
    });
  });

  group('极端情况', () {
    test('大量路由添加和删除', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      for (var i = 0; i < 100; i++) {
        while (router.remove('GET', '/route/$i')) {}
      }

      // 添加大量路由
      for (var i = 0; i < 100; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      // 删除一半的路由
      for (var i = 0; i < 50; i++) {
        while (router.remove('GET', '/route/$i')) {}
      }

      // 验证删除和保留的路由
      for (var i = 0; i < 100; i++) {
        final result = router.find('GET', '/route/$i');
        if (i < 50) {
          expect(result, isNull, reason: '路由 /route/$i 应该已被删除');
        } else {
          expect(result?.data, equals('route-$i'),
              reason: '路由 /route/$i 应该被保留');
        }
      }
    });

    test('删除节点后的树结构完整性', () {
      final router = createRouter<String>();

      // 清除之前可能存在的路由
      while (router.remove('GET', '/a/b/c/d')) {}
      while (router.remove('GET', '/a/b/x/y')) {}
      while (router.remove('GET', '/a/b/c/e')) {}

      // 创建一个路径树
      router.add('GET', '/a/b/c/d', 'abcd');
      router.add('GET', '/a/b/x/y', 'abxy');
      router.add('GET', '/a/b/c/e', 'abce');

      // 删除中间节点路由
      while (router.remove('GET', '/a/b/c/d')) {}

      // 验证其他路由仍然有效
      expect(router.find('GET', '/a/b/c/d'), isNull);
      expect(router.find('GET', '/a/b/x/y')?.data, equals('abxy'));
      expect(router.find('GET', '/a/b/c/e')?.data, equals('abce'));
    });
  });
}
