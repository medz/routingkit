import 'router.dart';
import 'router_options.dart';

abstract interface class RouterDriver {
  Router<T> createRouter<T>(RouterOptions options);
}
