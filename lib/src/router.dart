import 'parameters.dart';
import 'segment.dart';

/// An object that can quickly lookup previously registered routes.
///
/// The [T] type is the type of the route's return value.
abstract interface class Router<T> {
  /// Registers a new [T] to the router.
  ///
  /// ## Parameters
  /// - [value]: The value to register.
  /// - [path]: The path to register the value to.
  void register(T value, Iterable<Segment> segments);

  /// Returns the value registered to the given [path].
  ///
  /// If not matching value is found, `null` is returned.
  ///
  /// ## Parameters
  /// - [segments]: The path to lookup.
  /// - [parameters]: The parameters to use when matching.
  T? lookup(Iterable<String> segments, Parameters parameters);
}
