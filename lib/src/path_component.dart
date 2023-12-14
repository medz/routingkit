sealed class PathComponent {
  const factory PathComponent.constant(String constant) = ConstantPathComponent;
  const factory PathComponent.parameter(String identifier) =
      ParameterPathComponent;

  static const anything = AnythingPathComponent();
  static const catchAll = CatchAllPathComponent();

  factory PathComponent(String value) {
    return switch (value) {
      '*' => anything,
      '**' => catchAll,
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
}

/// A dynamic parameter component with discarded value.
///
/// Represented as `*`
final class AnythingPathComponent implements PathComponent {
  /// Creates a new catch all path component.
  const AnythingPathComponent();

  @override
  String get description => '*';
}

/// A fallback component that will match one *or more* dynamic segments.
///
/// Catch all components are represented as `**`.
class CatchAllPathComponent implements PathComponent {
  /// Creates a new catch all path component.
  const CatchAllPathComponent();

  @override
  String get description => '**';
}

extension ConvertStringToPathComponent on String {
  String get _withoutTrailingSlash =>
      endsWith('/') ? substring(0, length - 1) : this;

  String get _withoutLeadingSlash =>
      startsWith('/') ? substring(1, length) : this;

  /// Converts a string into [Iterable<PathComponent>].
  Iterable<PathComponent> toPathComponents() {
    return splitWithSlash().map(PathComponent.new);
  }

  /// Converts a string into [Iterable<String>].
  Iterable<String> splitWithSlash() {
    return _withoutLeadingSlash._withoutTrailingSlash.split('/');
  }
}

extension ConvertPathComponentsToString on Iterable<PathComponent> {
  /// Converts a [Iterable<PathComponent>] into a [String].
  String toPathComponentsString() {
    return map((component) => component.description).join('/');
  }
}
