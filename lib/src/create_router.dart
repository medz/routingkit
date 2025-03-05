import 'types.dart' as types;
import '_internal/router.dart' as internal;

/// Creates a new router instance with the specified configuration.
///
/// The generic type [T] defines the data type associated with routes.
/// This allows for type-safe route handlers, such as:
/// - Specific function types: `createRouter<void Function(Request, Response)>()`
/// - Controller classes: `createRouter<UserController>()`
/// - Simple data: `createRouter<String>()`
///
/// ## Parameters:
///
/// - [anyMethodToken]: Token used to represent any HTTP method.
///   When a route is registered with a null method, this token is used internally.
///   Default is 'any'.
///
/// - [caseSensitive]: Whether path matching should be case-sensitive.
///   When true (default), paths like '/users' and '/Users' are considered different.
///   When false, case is ignored during matching.
///
/// ## Example:
///
/// ```dart
/// // Create a router with default settings
/// final router = createRouter<String>();
///
/// // Create a case-insensitive router
/// final router = createRouter<String>(caseSensitive: false);
///
/// // Create a router with custom anyMethodToken
/// final router = createRouter<String>(anyMethodToken: '*');
/// ```
///
/// Returns a typed [types.Router] instance.
types.Router<T> createRouter<T>({
  String anyMethodToken = 'any',
  bool caseSensitive = true,
}) {
  return internal.Router<T>(
    anyMethodToken: anyMethodToken,
    caseSensitive: caseSensitive,
  );
}
