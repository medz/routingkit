import 'package:routingkit/routingkit.dart';

void main() {
  final router = TrieRouter();

  // Dsiplay all log records to the console.
  router.logger.onRecord.listen(print);

  // Register a route with a constant path component.
  router.register(0, '/users/:id/friends/:friend_id'.pathComponents);
  router.register(1, '/users/:id/friends/:friend_id'.pathComponents);

  final parameters = Parameters();

  // Lookup a route with a constant path component.
  final result =
      router.lookup('/users/123/friends/456'.splitWithSlash(), parameters);

  print(result); // 1
  print(parameters.allNames); // {id, friend_id}
  print(parameters.get('id')); // 123
  print(parameters.get('friend_id')); // 456
}

// Full console output:
// ```
// [INFO] trie-router: Overriding duplicate route for users :id/friends/:friend_id
// 2
// {id, friend_id}
// 123
// 456
// ```
