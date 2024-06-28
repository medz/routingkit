import 'radix_trie_router/radix_trie_router_driver.dart';
import 'router.dart';
import 'router_driver.dart';
import 'router_options.dart';

Router<T> createRouter<T>({
  RouterDriver driver = const RadixTrieRouterDriver(),
  bool caseSensitive = false,
  Map<String, T> routes = const {},
}) {
  final options = RouterOptions(caseSensitive: caseSensitive);
  final router = driver.createRouter<T>(options);

  for (final e in routes.entries) {
    router.register(e.key, e.value);
  }

  return router;
}
