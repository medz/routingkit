import 'package:routingkit/routingkit.dart';

RouterContext<String> createSimpleRouter(Iterable<String> routes) {
  final router = createRouter<String>();
  for (final route in routes) {
    addRoute(router, 'GET', route, route);
  }

  return router;
}

RouterContext<T> createMapRouter<T>(Map<String, T> routes) {
  final router = createRouter<T>();
  for (final entry in routes.entries) {
    addRoute(router, 'GET', entry.key, entry.value);
  }

  return router;
}
