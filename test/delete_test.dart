import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

void main() {
  test('理解Router行为', () {
    // 创建全新的路由器实例
    final router = createRouter<String>();

    // 先查看当前状态
    final initial = router.findAll('GET', '/test');
    print('初始状态: ${initial.length} 条路由');

    // 不管当前状态如何，尝试清空所有路由
    bool removed;
    do {
      removed = router.remove('GET', '/test');
      if (removed) {
        print('删除了一个路由');
      }
    } while (removed);

    // 验证清空成功
    final afterClear = router.findAll('GET', '/test');
    print('清空后: ${afterClear.length} 条路由');
    expect(afterClear.length, equals(0));

    // 添加单个路由
    router.add('GET', '/test', 'test1');
    final afterAdd1 = router.findAll('GET', '/test');
    print(
        '添加一条后: ${afterAdd1.length} 条路由, 数据: ${afterAdd1.map((r) => r.data).toList()}');

    // 添加另一个路由
    router.add('GET', '/test', 'test2');
    final afterAdd2 = router.findAll('GET', '/test');
    print(
        '添加两条后: ${afterAdd2.length} 条路由, 数据: ${afterAdd2.map((r) => r.data).toList()}');

    // 删除第二个路由
    final removedData = router.remove('GET', '/test', 'test2');
    print('删除特定数据: $removedData');

    // 查看删除后的状态
    final afterRemove = router.findAll('GET', '/test');
    print(
        '删除一条后: ${afterRemove.length} 条路由, 数据: ${afterRemove.map((r) => r.data).toList()}');

    // 检查Router.find的行为
    final findResult = router.find('GET', '/test');
    print('find结果: ${findResult?.data}');
  });
}
