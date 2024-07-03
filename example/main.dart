import 'package:routingkit/routingkit.dart';

void main() {
  final router = createRouter(routes: {
    '/users/:name': 0,
  });

  final result = router.lookup('/users/seven');
  print('User name: ${result?.params('name')}'); // seven
  print('Matched user value: ${result?.value}'); // 0

  // Register a new route.
  router.register('/posts/:id', 2);
}
