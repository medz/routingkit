import 'params.dart';

typedef MatchedRoute<T> = (Params, T?);

abstract interface class Router<T> {
  MatchedRoute<T> lookup(String path);
  void register(String route, T value);
  void remove(String route);
}
