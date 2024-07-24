import '_router_mixins/add.dart';
import '_router_mixins/find.dart';
import '_router_mixins/find_all.dart';
import '_router_mixins/remove.dart';
import 'types.dart';

abstract class _MakeRouter<T> implements Router<T> {
  const _MakeRouter(this.context);

  @override
  final Context<T> context;
}

class _RouterImpl<T> = _MakeRouter<T>
    with Add<T>, Remove<T>, FindAll<T>, Find<T>;

/// Creates a new RoutingKit router context.
Router<T> createRouter<T>() {
  final context = Context<T>(
    root: Node<T>('<root>'),
    static: {},
  );

  return _RouterImpl(context);
}
