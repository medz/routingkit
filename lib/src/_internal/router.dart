import '../types.dart' as types;
import 'add_route.dart';
import 'context.dart';
import 'find_all_routes.dart';
import 'find_route.dart';
import 'remove_route.dart';

class Router<T> extends Context<T>
    with AddRoute<T>, FindRoute<T>, FindAllRoutes<T>, RemoveRoute<T>
    implements types.Router<T> {
  Router({required this.anyMethodToken, required this.caseSensitive});

  @override
  final String anyMethodToken;

  @override
  final bool caseSensitive;
}
