import '../router.dart';
import '../router_driver.dart';
import '../router_options.dart';
import 'radix_trie_router.dart';
import 'route_radix_trie_node.dart';

class RadixTrieRouterDriver implements RouterDriver {
  const RadixTrieRouterDriver();

  @override
  Router<T> createRouter<T>(RouterOptions options) {
    return RadixTrieRouter<T>(
      node: RouteRadixTrieNode<T>(),
      options: options,
    );
  }
}
