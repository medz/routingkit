# RoutingKit Tests

This directory contains tests for the RoutingKit library. These tests cover various aspects of the library, including functionality, performance, and use cases.

## Test Structure

- `routingkit_test.dart`: Core functionality tests, covering all aspects of the Router API
- `benchmark_test.dart`: Performance benchmarks for various router operations
- `http_server_example_test.dart`: Example of using RoutingKit in an HTTP server

## Running Tests

To run all tests:

```bash
dart test
```

To run a specific test file:

```bash
dart test test/routingkit_test.dart
```

To run specific tests by matching test descriptions:

```bash
dart test --name "Static routes"
```

## Performance Testing

The benchmark tests provide performance metrics for various router operations. These are useful when making changes to the library to ensure that performance is maintained or improved.

```bash
dart test test/benchmark_test.dart
```

The benchmark tests output performance metrics to the console, including:
- Route addition time
- Route matching time
- Average operation times
- Comparisons between different configuration options

## HTTP Server Example

The HTTP server example demonstrates how to use RoutingKit in a real-world scenario with a Dart HTTP server.

```bash
dart test test/http_server_example_test.dart
```

This test sets up a mock HTTP server with routes defined using RoutingKit, and tests HTTP requests against it. 