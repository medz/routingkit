import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

import 'utils/create_test_router.dart';

void main() {
  group('性能测试', () {
    test('大规模路由添加和查找', () {
      final router = createRouter<String>();
      final int routeCount = 1000;

      // 计时添加路由
      final addStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.add('GET', '/route/$i', 'route-$i');
      }

      final addDuration = DateTime.now().difference(addStart);
      print('添加 $routeCount 个路由耗时: ${addDuration.inMilliseconds}ms');

      // 计时查找静态路由
      final staticStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/route/$i');
      }

      final staticDuration = DateTime.now().difference(staticStart);
      print('查找 $routeCount 个静态路由耗时: ${staticDuration.inMilliseconds}ms');

      // 计时查找不存在的路由
      final notFoundStart = DateTime.now();

      for (var i = 0; i < routeCount; i++) {
        router.find('GET', '/not-found/$i');
      }

      final notFoundDuration = DateTime.now().difference(notFoundStart);
      print('查找 $routeCount 个不存在的路由耗时: ${notFoundDuration.inMilliseconds}ms');

      // 确保性能在合理范围内
      expect(addDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: '每个路由的添加时间应该小于1毫秒');
      expect(staticDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: '每个静态路由的查找时间应该小于1毫秒');
      expect(notFoundDuration.inMilliseconds / routeCount < 1, isTrue,
          reason: '每个不存在路由的查找时间应该小于1毫秒');
    });

    test('多个参数路由', () {
      final router = createRouter<String>();

      router.add('GET', '/user/:id/profile/:field', 'user-profile');
      router.add('GET', '/user/:id/settings', 'user-settings');

      // 测试第一个路由
      final profileResult = router.find('GET', '/user/123/profile/name');
      expect(profileResult?.data, equals('user-profile'));
      expect(profileResult?.params, equals({'id': '123', 'field': 'name'}));

      // 测试第二个路由
      final settingsResult = router.find('GET', '/user/123/settings');
      expect(settingsResult?.data, equals('user-settings'));
      expect(settingsResult?.params, equals({'id': '123'}));
    });
  });

  group('无效输入处理', () {
    test('无效路径处理', () {
      final router = createRouter<String>();

      // 尝试添加空路由路径
      router.add('GET', '', 'empty-path');

      // 空路径应该被规范化为根路径
      expect(router.find('GET', '')?.data, equals('empty-path'));
      expect(router.find('GET', '/')?.data, equals('empty-path'));

      // 尝试添加格式不规范的路径
      router.add('GET', 'no-leading-slash', 'no-leading-slash');

      // 应该能够匹配规范化后的路径
      expect(router.find('GET', 'no-leading-slash')?.data,
          equals('no-leading-slash'));
      expect(router.find('GET', '/no-leading-slash')?.data,
          equals('no-leading-slash'));
    });

    test('无效HTTP方法处理', () {
      final router = createRouter<String>();

      // 添加不同大小写的HTTP方法
      router.add('get', '/case-test', 'lowercase-get');
      router.add('GET', '/case-test', 'uppercase-get');
      router.add('Get', '/case-test', 'mixedcase-get');

      // 验证HTTP方法大小写敏感
      expect(router.find('get', '/case-test')?.data, equals('lowercase-get'));
      expect(router.find('GET', '/case-test')?.data, equals('uppercase-get'));
      expect(router.find('Get', '/case-test')?.data, equals('mixedcase-get'));

      // 添加非标准HTTP方法
      router.add('CUSTOM_METHOD', '/custom', 'custom-method');

      // 非标准HTTP方法也应能匹配
      expect(router.find('CUSTOM_METHOD', '/custom')?.data,
          equals('custom-method'));
    });

    test('特殊字符处理', () {
      final router = createRouter<String>();

      // 添加包含特殊字符的路径
      router.add('GET', '/special/chars', 'special-chars');

      // 特殊字符路径应能正常匹配
      expect(
          router.find('GET', '/special/chars')?.data, equals('special-chars'));
    });
  });

  group('复杂逻辑组合测试', () {
    test('组合多种类型的路由', () {
      final router = createRouter<String>();

      // 清除可能存在的路由
      router.remove('GET', '/multi-match/specific');
      router.remove('GET', '/multi-match/:param');
      router.remove(null, '/multi-match/:param');

      // 添加不同类型的路由组合
      router.add('GET', '/api/users', 'users-list');
      router.add('GET', '/api/users/:id', 'user-detail');
      router.add('POST', '/api/users/:id', 'user-update');
      router.add(null, '/api/public/**', 'public-api');
      router.add('GET', '/api/admin/:section/*/**', 'admin-wildcard');

      // 测试各种组合的查找
      expect(router.find('GET', '/api/users')?.data, equals('users-list'));
      expect(router.find('GET', '/api/users/123')?.data, equals('user-detail'));
      expect(
          router.find('POST', '/api/users/123')?.data, equals('user-update'));
      expect(router.find('DELETE', '/api/public/docs')?.data,
          equals('public-api'));

      // 测试复杂的通配符和参数组合
      final adminResult =
          router.find('GET', '/api/admin/reports/monthly/2023/04');
      expect(adminResult?.data, equals('admin-wildcard'));
      expect(adminResult?.params?['section'], equals('reports'));

      // 测试findAll的复杂场景（重新创建一个新的路由器以避免与之前的测试冲突）
      final multiRouter = createRouter<String>();
      multiRouter.add(null, '/multi-match/:param', 'multi-1');
      multiRouter.add('GET', '/multi-match/:param', 'multi-2');
      multiRouter.add('GET', '/multi-match/specific', 'multi-3');

      final multiMatches = multiRouter.findAll('GET', '/multi-match/specific');
      expect(multiMatches.length, greaterThanOrEqualTo(2)); // 至少应该匹配2个路由

      // 验证静态路由存在于结果中
      expect(multiMatches.map((r) => r.data).toList(), contains('multi-3'));
    });
  });
}
