import 'package:routingkit/routingkit.dart';

Router<String> createSimpleRouter(Iterable<String> routes) {
  final router = createRouter<String>();
  for (final route in routes) {
    router.add('GET', route, route);
  }

  return router;
}

Router<T> createMapRouter<T>(Map<String, T> routes) {
  final router = createRouter<T>();
  for (final entry in routes.entries) {
    router.add('GET', entry.key, entry.value);
  }

  return router;
}
