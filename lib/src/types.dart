/// 匹配的路由结果
///
/// 泛型类型 [T] 表示与路由关联的数据类型
class MatchedRoute<T> {
  /// 创建一个新的匹配路由结果
  ///
  /// [data] 与匹配路由关联的数据
  /// [params] 匹配路由的参数，可以为null
  MatchedRoute({
    required this.data,
    this.params,
  });

  /// 与匹配路由关联的数据
  final T data;

  /// 路由中提取的参数，如果没有参数则为null
  final Map<String, String>? params;

  @override
  String toString() => 'MatchedRoute(data: $data, params: $params)';
}
