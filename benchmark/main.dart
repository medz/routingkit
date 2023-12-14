import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:trie_router/trie_router.dart';

class RoutingMatchFirstBenchmark extends BenchmarkBase {
  final bool caseSensitive;

  RoutingMatchFirstBenchmark(this.caseSensitive) : super('Routing match first');

  @override
  String get name => '(caseSensitive: $caseSensitive) ${super.name}';

  late final TrieRouter router;
  late final Parameters parameters;

  @override
  void setup() {
    router = TrieRouter<String>(
      options: ConfigurationOptions(caseSensitive: caseSensitive),
    );
    parameters = Parameters();

    for (final letter in const ['a', 'b', 'c', 'd', 'e', 'f', 'g']) {
      router.register(
        letter,
        [PathComponent(letter), PathComponent.parameter('${letter}_id')],
      );
    }
  }

  @override
  void run() {
    router.lookup(const ['a', '0'], parameters);
  }
}

class RoutingMatchLastBenchmark extends BenchmarkBase {
  final bool caseSensitive;

  RoutingMatchLastBenchmark(this.caseSensitive) : super('Routing match last');

  @override
  String get name => '(caseSensitive: $caseSensitive) ${super.name}';

  late final TrieRouter router;
  late final Parameters parameters;

  @override
  void setup() {
    router = TrieRouter<String>(
      options: ConfigurationOptions(caseSensitive: caseSensitive),
    );
    parameters = Parameters();

    for (final letter in const ['a', 'b', 'c', 'd', 'e', 'f', 'g']) {
      router.register(
        letter,
        [PathComponent.parameter('${letter}_id'), PathComponent(letter)],
      );
    }
  }

  @override
  void run() {
    router.lookup(const ['g', '0'], parameters);
  }
}

class RoutingMinmumMatchBenchmark extends BenchmarkBase {
  final bool caseSensitive;

  RoutingMinmumMatchBenchmark(this.caseSensitive)
      : super('Routing minimum match');

  @override
  String get name => '(caseSensitive: $caseSensitive) ${super.name}';

  late final TrieRouter router;
  late final Parameters parameters;

  @override
  void setup() {
    router = TrieRouter<String>(
      options: ConfigurationOptions(caseSensitive: caseSensitive),
    );

    router.register('a', [PathComponent.constant('a')]);

    parameters = Parameters();
  }

  @override
  void run() {
    router.lookup(const ['a'], parameters);
  }
}

class RouterMatchEarlyFailBenchmark extends BenchmarkBase {
  final bool caseSensitive;

  RouterMatchEarlyFailBenchmark(this.caseSensitive)
      : super('Router match early fail');

  @override
  String get name => '(caseSensitive: $caseSensitive) ${super.name}';

  late final TrieRouter router;
  late final Parameters parameters;

  @override
  void setup() {
    parameters = Parameters();
    router = TrieRouter<String>(
      options: ConfigurationOptions(caseSensitive: caseSensitive),
    );

    router.register('a', [PathComponent.constant('a')]);
  }

  @override
  void run() {
    router.lookup(const ['b'], parameters);
  }
}

void main() {
  RoutingMatchFirstBenchmark(true).report();
  RoutingMatchFirstBenchmark(false).report();
  RoutingMatchLastBenchmark(true).report();
  RoutingMatchLastBenchmark(false).report();
  RoutingMinmumMatchBenchmark(true).report();
  RoutingMinmumMatchBenchmark(false).report();
  RouterMatchEarlyFailBenchmark(true).report();
  RouterMatchEarlyFailBenchmark(false).report();
}
