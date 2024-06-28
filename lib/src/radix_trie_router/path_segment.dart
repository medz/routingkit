import '../constants.dart';

sealed class PathSegment {}

final class ConstPathSegment implements PathSegment {
  const ConstPathSegment(this.value);

  final String value;

  @override
  get hashCode => Object.hash(runtimeType, value);

  @override
  operator ==(Object other) {
    return other is ConstPathSegment && other.hashCode == hashCode;
  }
}

final class ParamPathSegment implements PathSegment {
  const ParamPathSegment(this.name);

  final String name;

  @override
  get hashCode => Object.hash(runtimeType, name);

  @override
  operator ==(Object other) {
    return other is ParamPathSegment && other.hashCode == hashCode;
  }
}

final class AnyPathSegment implements PathSegment {
  const AnyPathSegment();

  @override
  get hashCode => Object.hash(runtimeType, '*');

  @override
  operator ==(Object other) {
    return other is AnyPathSegment && other.hashCode == hashCode;
  }
}

final class CatchallPathSegment implements PathSegment {
  const CatchallPathSegment();

  @override
  get hashCode => Object.hash(runtimeType, kCatchall);

  @override
  operator ==(Object other) {
    return other is CatchallPathSegment && other.hashCode == hashCode;
  }
}
