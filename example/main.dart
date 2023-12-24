import 'package:routingkit/routingkit.dart';

void main() {
  final router = TrieRouter();

  // Dsiplay all log records to the console.
  router.logger.onRecord.listen(print);

  // Register a route with a constant path component.
  router.register(0, '/users/:id/friends/:friend_id'.asSegments);
  router.register(1, '/users/:id/friends/:friend_id'.asSegments);

  final params = Params();

  // Lookup a route with a constant path component.
  final result = router.lookup('/users/123/friends/456'.asPaths, params);

  print(result); // 1
  print(params.keys); // {id, friend_id}
  print(params.get('id')); // 123
  print(params.get('friend_id')); // 456
}

// Full console output:
// ```
// [INFO] Routing Kit: Overriding duplicate route for users (:id, friends, :friend_id)
// 2
// {id, friend_id}
// 123
// 456
// ```
