import 'types.dart' as types;
import '_internal/router.dart' as internal;

types.Router<T> createRouter<T>({
  String anyMethodToken = 'any',
  bool caseSensitive = true,
}) {
  return internal.Router<T>(
    anyMethodToken: anyMethodToken,
    caseSensitive: caseSensitive,
  );
}
