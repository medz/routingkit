import 'package:routingkit/routingkit.dart';

RouterContext<Object> createTestRouter(Iterable<(String, Object?)> routes) {
  final router = createRouter<Object>();
  for (final (path, data) in routes) {
    addRoute(router, 'GET', path, data ?? {'path': path});
  }

  return router;
}

extension MatchedRouteIterableToObject on Iterable<MatchedRoute> {
  Iterable<Object> toTestObject() {
    return map((e) => {
          'data': e.data,
          if (e.params != null && e.params?.isNotEmpty == true)
            'params': e.params
        });
  }
}
