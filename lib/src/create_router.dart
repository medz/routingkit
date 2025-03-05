import 'types.dart' as types;
import '_internal/router.dart' as internal;

types.Router createRouter({
  String anyMethodToken = 'any',
  bool caseSensitive = true,
}) {
  return internal.Router(
    anyMethodToken: anyMethodToken,
    caseSensitive: caseSensitive,
  );
}
