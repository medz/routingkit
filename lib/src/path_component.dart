sealed class PathComponent {
  const factory PathComponent.constant(String constant) = ConstantPathComponent;
  const factory PathComponent.parameter(String identifier) =
      ParameterPathComponent;

  static const anything = AnythingPathComponent();
  static const catchall = CatchallPathComponent();

  factory PathComponent(String value) {
    return switch (value) {
      '*' => anything,
      '**' => catchall,
      _ => value.startsWith(':')
          ? ParameterPathComponent(value.substring(1))
          : ConstantPathComponent(value),
    };
  }

  /// Returns the path component as a [String].
  String get description;

  @override
  String toString() => description;
}

/// A normal, constant path component.
final class ConstantPathComponent implements PathComponent {
  /// The constant path component.
  final String constant;

  /// Creates a new constant path component.
  const ConstantPathComponent(this.constant);

  @override
  String get description => constant;

  @override
  String toString() => description;
}

/// A [dynamic] parameter path component.
///
/// The supplied identifier is used to generate a unique parameter name.
///
/// Represented as `:identifier`.
final class ParameterPathComponent implements PathComponent {
  /// The parameter identifier.
  final String identifier;

  /// Creates a new parameter path component.
  const ParameterPathComponent(this.identifier);

  @override
  String get description => ':$identifier';

  @override
  String toString() => description;
}

/// A dynamic parameter component with discarded value.
///
/// Represented as `*`
final class AnythingPathComponent implements PathComponent {
  /// Creates a new catch all path component.
  const AnythingPathComponent();

  @override
  String get description => '*';

  @override
  String toString() => description;
}

/// A fallback component that will match one *or more* dynamic segments.
///
/// Catch all components are represented as `**`.
class CatchallPathComponent implements PathComponent {
  /// Creates a new catch all path component.
  const CatchallPathComponent();

  @override
  String get description => '**';

  @override
  String toString() => description;
}

extension PathComponentStringHelpers on String {
  /// Converts a string into a [PathComponent].
  PathComponent get pathComponent => PathComponent(this);

  /// Converts a string into a iterable of [PathComponent].
  Iterable<PathComponent> get pathComponents =>
      splitWithSlash().map(PathComponent.new);

  /// Converts a string into [Iterable<String>].
  Iterable<String> splitWithSlash() {
    return withoutLeadingSlash.withoutTrailingSlash.split('/');
  }
}

extension on String {
  String get withoutTrailingSlash =>
      endsWith('/') ? substring(0, length - 1) : this;

  String get withoutLeadingSlash =>
      startsWith('/') ? substring(1, length) : this;
}

extension PathComponentIterableHelper on Iterable<PathComponent> {
  /// Converts an iterable of [PathComponent] into a [String].
  String get path => map((component) => component.description).join('/');
}

extension PathComponentsCastHelper on Iterable<String> {
  /// Casts an iterable of [PathComponent] into a [Iterable<PathComponent>].
  Iterable<PathComponent> get pathComponents => map(PathComponent.new);
}
