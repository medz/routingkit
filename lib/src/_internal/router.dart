import '../types.dart' as types;
import 'add_route.dart';
import 'context.dart';
import 'find_route.dart';

class Router<T> extends Context<T>
    with AddRoute<T>, FindRoute<T>
    implements types.Router<T> {
  Router({required this.anyMethodToken, required this.caseSensitive});

  @override
  final String anyMethodToken;

  @override
  final bool caseSensitive;

  @override
  Iterable<types.MatchedRoute<T>> findAll(String? method, String path) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  void remove(String? method, String path) {
    // TODO: implement remove
  }
}
