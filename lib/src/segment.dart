sealed class Segment {
  const factory Segment.constant(String value) = ConstSegment;
  const factory Segment.param(String name) = ParamSegment;
  const factory Segment.any() = AnySegment;
  const factory Segment.catchall() = CatchallSegment;

  factory Segment(String value) {
    return switch (value) {
      '*' => const Segment.any(),
      '**' => const Segment.catchall(),
      String name when name.startsWith(':') => Segment.param(name.substring(1)),
      String value => Segment.constant(value),
    };
  }
}

class ConstSegment implements Segment {
  final String value;

  const ConstSegment(this.value);

  @override
  String toString() => value;
}

class ParamSegment implements Segment {
  final String name;

  const ParamSegment(this.name);

  @override
  String toString() => ':$name';
}

class AnySegment implements Segment {
  const AnySegment();

  @override
  String toString() => '*';
}

class CatchallSegment implements Segment {
  const CatchallSegment();

  @override
  String toString() => '**';
}

extension String$Segments on String {
  /// As a defined route path to segments.
  Iterable<Segment> get asSegments => asPaths.map(Segment.new);

  /// As a path string with trimmed segments.
  Iterable<String> get asPaths =>
      split('/').map((e) => e.trim()).where((e) => e.isNotEmpty);
}
