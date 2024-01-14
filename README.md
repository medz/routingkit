<h1 align="center" style="font-size: 36px">RoutingKit</h1>

<p align="center">
  <a href="https://pub.dev/packages/routingkit"><img alt="Pub Version" src="https://img.shields.io/pub/v/routingkit?logo=dart"/></a>
  <a href="https://github.com/medz/routingkit/actions/workflows/test.yml"><img alt="Test" src="https://github.com/medz/routingkit/actions/workflows/test.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/medz/routingkit?tab=MIT-1-ov-file"><img alt="License" src="https://img.shields.io/github/license/medz/routingkit" /></a>
  <a href="https://github.com/sponsors/medz"><img alt="Sponsors" src="https://img.shields.io/github/sponsors/medz?logo=githubsponsors" /></a>
  <a href="https://twitter.com/shiweidu"><img alt="X (formerly Twitter) Follow" src="https://img.shields.io/twitter/follow/shiweidu" /></a>
</p>

<p align="center">
Routing Kit is a High-performance trie-node router.
</p>

- **High-performance**：Based on [Trie](https://en.wikipedia.org/wiki/Trie) tree implementation, efficient performance.
- **Accurate**：Using `/` to split trie-node nodes can accurately match routes.
- **Flexible**：Support dynamic routing matching

## Installation

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  routingkit: 0.2.0
```

Or install it with `pub`:

```bash
dart pub add routingkit
# or
flutter pub add routingkit
```

## Sponsor RoutingKit

RoutingKit is an open source project based on the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file). If your Router implementation uses RoutingKit, or you find my work helpful to you, please sponsor me on [GitHub Sponsors](https://github.com/sponsors/medz). Your support is my biggest motivation.

## Getting Started

RoutingKit improves the performance of route matching and provides a simpler API. Here is a simple example:

```dart
import 'package:routingkit/routingkit.dart';

final router = TrieRouter();

router.register(0, '/users/:user_id'.asSegments);
router.register(1, '/users/:user_id/posts'.asSegments);
router.register(2, '/users/:user_id/posts/:post_id'.asSegments);

void main() {

  final zeroParams = Params();
  final zeroResult = router.lookup('/users/1'.asPaths, zeroParams);
  print(zeroResult); // 0
  print(zeroParams.keys); // {user_id}
  print(zoroParams.get('user_id')); // 1

  final oneParams = Params();
  final oneResult = router.lookup('/users/1/posts'.asPaths, oneParams);
  print(oneResult); // 1

  final twoParams = Params();
  final twoResult = router.lookup('/users/1/posts/2'.asPaths, twoParams);
  print(twoResult); // 2
  print(twoParams.keys); // {user_id, post_id}
  print(twoParams.get('user_id')); // 1
  print(twoParams.get('post_id')); // 2
}
```

Through the above example, you can see that the use of RoutingKit is very simple, just create a `TrieRouter` instance, then use the `register` method to register the route, and finally use the `lookup` method to route matching.

The `Parameters` class is a parameter container that will save the matched parameters internally after the route is successfully matched. For specific usage, please refer to [Params](#parameters).

## Path Segments

`Segment` is a core concept in RoutingKit. It is an abstract class with four subclasses:

- `ConstSegment`: Constant path component, for example `/users`.
- `ParamSegment`: Parameter path component, for example `/users/:user_id`.
- `AnySegment`: Wildcard path component, for example `/users/*`.
- `CatchallSegment`: Catchall path component, for example `/users/**`.

Of course, you don’t have to care about these classes, because RoutingKit has provided you with some convenient methods, for example:

```dart
'/users'.asSegments; // [ConstSegment('users')]
'/users/:user_id'.asSegments; // [ConstSegment('users'), ParamSegment('user_id')]
'users'.asSegments // ConstSegment('users')
'/users/:id/*'.asSegments; // [ConstSegment('users'), ParamSegment('id'), AnySegment()]
'/users/**'.asSegments; // [ConstSegment('users'), CatchallSegment()]
```

You can also directly pass a string to the default constructor factory function of `Segment`, for example:

```dart
Segment('users'); // ConstSegment('users')
Segment(':user_id'); // ParamSegment('user_id')
Segment('*'); // AnySegment()
Segment('**'); // CatchallSegment()
```

At the same time, `Segment` also provides literal constructors and static properties:

```dart
Segment.constant('users'); // ConstSegment('users')
Segment.parma('user_id'); // ParamSegment('user_id')
Segment.any(); // AnySegment()
Segment.catchall(); // CatchallSegment()
```

`Segment` has only one property `description`, which is a string used to describe the literal definition of the current path component, for example:

```dart
Segment.constant('users').description; // users
```

### ConstSegment

The `ConstSegment` is a constant path component, and its `constant` parameter is a constant string, for example:

```dart
final component = Segment.constant('users');
```

It returns a `component` that is a `ConstSegment` instance that represents the constant string that must be matched in the path segment, for example:

```dart
router.register(0, '/users'.asSegments);

final params = Params();
router.lookup('/users'.asPaths, params); // 0
router.lookup('/posts'.asPaths, params); // null
```

### ParamSegment

The `ParamSegment` is a parameter path component, and its `identifier` parameter is a string used to represent the name of the current parameter, for example:

```dart
final component = Segment.param('user_id');
```

It returns a `component` that is a `ParamSegment` instance that represents the parameter that must be matched in the path segment, for example:

```dart
router.register(0, '/users/:user_id'.asSegments);

final params = Params();

router.lookup('/users/1'.asPaths, params); // 0
print(params.keys); // {user_id}
print(params.get('user_id')); // 1
```

### AnySegment

The `AnySegment` is a path wildcard component that matches any string in the current path segment, for example:

```dart
router.register(0, '/users/:user_id/*'.asSegments);

final params = Params();

router.lookup('/users/1/posts'.asPaths, params); // 0
print(params.catchall); // (posts)
```

### CatchallSegment

The `CatchallSegment` is a path capture component that matches all path segments defined after it, for example:

```dart
router.register(0, '/users/**'.asSegments);

final params = Params();

router.lookup('/users/1/posts'.asPaths, params); // 0
print(params.catchall); // (1, posts)
```

## Parameters

`Parameters` is a parameter container that will save the matched parameters internally after the route is successfully matched, for example:

```dart
router.register(0, '/users/:user_id'.asSegments);

final params = Params();

router.lookup('/users/1'.asPaths, params); // 0

print(params.get('user_id')); // 1
print(params.keys); // {user_id}
```

### `get`

`Parameters` provides the `get` method to get the parameter with the specified name, for example:

```dart
params.get('user_id'); // 1
```

### `getAll`

`Parameters` provides the `getAll` method to get all parameters with the specified name, for example:

```dart
params.getAll('user_id'); // [1]
```

### `set`

`Parameters` provides the `set` method to set the parameter with the specified name, for example:

```dart
params.set('user_id', '1');
```

RoutingKit saves the matched parameters in `Parameters` through the `set` method. You can also set more custom parameters through the `set` method, for example:

```dart
params.set('other', '1');
```

### `keys`

The `Parameters` provides the `keys` property to get all parameter names, for example:

```dart
params.keys; // {user_id, other}
```

### `catchall`

`Parameters` provides the `catchall` field to get the captured `AnySegment` or `CatchallSegment` parameter, for example:

```dart
router.register(0, '/users/:user_id/*'.asSegments);
router.register(1, '/posts/**'.asSegments);

final params = Params();

router.lookup('/users/1/posts'.asPaths, params); // 0
print(params.catchall); // (posts)

router.lookup('/posts/1/2/3'.asPaths, params); // 1
print(params.catchall); // (1, 2, 3)
```

### `setCatchall`

The `Parameters` provides the `set catchall` method to set the captured `AnySegment` or `CatchallSegment` parameter. You can set the captured parameter by the `set catchall` method, for example:

```dart
router.register(0, '/users/:user_id/*'.asSegments);

final params = Params();

router.lookup('/users/1/posts'.asPaths, params); // 0
print(params.catchall); // (posts)

params.catchall = ['1', '2', '3'];
print(params.catchall); // (1, 2, 3)
```

## Router

The `Router` is an interface class that has two abstract methods:

- `register`: Register route.
- `lookup`: Route matching.

In RoutingKit, `TrieRouter` is an implementation of `Router`. It is a router based on [Trie](https://en.wikipedia.org/wiki/Trie) tree. Its `register` method is used to register routes, and its `lookup` method is used for route matching.

### `register`

`register` method is used to register routes, it has two parameters:

- `value`: Route value, it is a generic parameter, specified by the generic parameter of `Router<T>`.
- `path`: Route component, it is an `Iterable<Segment>` type parameter.

Example:

```dart
router.register(0, '/users/:user_id'.asSegments);
```

### `lookup`

`lookup` method is used for route matching, it has two parameters:

- `path`: 路由片段，它是一个 `Iterable<String>` 类型的参数。
- `parameters`: 参数容器，它是一个 `Parameters` 类型的参数。

- `path`: Route segment, it is an `Iterable<String>` type parameter.
- `parameters`: Parameter container, it is a `Parameters` type parameter.

Example:

```dart
router.lookup('/users/1'.asPaths, Params());
```

## Case sensitive

RoutingKit is case sensitive by default, you can set case sensitive through the `caseSensitive` parameter, for example:

```dart
final router = TrieRouter(
  caseSensitive: false, // False is case insensitive. default is true.
);
```

## Benchmark

RoutingKit provides a benchmark test, you can find it in the `benchmark/main.dart` file, and its test results are as follows:

```log
(caseSensitive: true) Routing match first(RunTime): 0.60953 us.
(caseSensitive: false) Routing match first(RunTime): 0.656843 us.
(caseSensitive: true) Routing match last(RunTime): 0.6479385 us.
(caseSensitive: false) Routing match last(RunTime): 0.7026445 us.
(caseSensitive: true) Routing minimum match(RunTime): 0.26883614654192156 us.
(caseSensitive: false) Routing minimum match(RunTime): 0.2979291527317985 us.
(caseSensitive: true) Router match early fail(RunTime): 0.22558736156240886 us.
(caseSensitive: false) Router match early fail(RunTime): 0.2578717881655905 us.
```

> **NOTE**: The test result is run through the `dart run benchmark/main.dart` command, and the test environment is:
>
> ```
> Dart SDK version: 3.2.3
> OS: macOS 14.1.2 (23B92)
> CPU: Apple M1
> Memory: 8 GB
> ```

## License

RoutingKit is open-sourced software licensed under the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file).
