import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter(routes: {
    '/users/:name': 0,
  });

  final (params, value) = router.lookup('/users/seven');
  print('User name: ${params('name')}'); // seven
  print('Matched user value: $value'); // 0

  // Register a new route.
  router.register('/posts/:id', 2);
}
