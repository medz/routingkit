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
  routingkit: latest
```

Or install it with `pub`:

```bash
dart pub add routingkit
# or
flutter pub add routingkit
```

## Sponsor RoutingKit

RoutingKit is an open source project based on the [MIT protocol](https://github.com/medz/routingkit?tab=MIT-1-ov-file). If your Router implementation uses RoutingKit, or you find my work helpful to you, please sponsor me on [GitHub Sponsors](https://github.com/sponsors/medz). Your support is my biggest motivation.

## Getting Started

RoutingKit improves the performance of route matching and provides a simpler API. Here is a simple example:

```dart
import 'package:routingkit/routingkit.dart';

final router = TrieRouter();

router.register(0, '/users/:user_id'.pathComponents);
router.register(1, '/users/:user_id/posts'.pathComponents);
router.register(2, '/users/:user_id/posts/:post_id'.pathComponents);

void main() {

  final zeroParams = Parameters();
  final zeroResult = router.lookup('/users/1'.splitWithSlash(), zeroParams);
  print(zeroResult); // 0
  print(zeroParams.allNames); // {user_id}
  print(zoroParams.get('user_id')); // 1

  final oneParams = Parameters();
  final oneResult = router.lookup('/users/1/posts'.splitWithSlash(), oneParams);
  print(oneResult); // 1

  final twoParams = Parameters();
  final twoResult = router.lookup('/users/1/posts/2'.splitWithSlash(), twoParams);
  print(twoResult); // 2
  print(twoParams.allNames); // {user_id, post_id}
  print(twoParams.get('user_id')); // 1
  print(twoParams.get('post_id')); // 2
}
```

Through the above example, you can see that the use of RoutingKit is very simple, just create a `TrieRouter` instance, then use the `register` method to register the route, and finally use the `lookup` method to route matching.

The `Parameters` class is a parameter container that will save the matched parameters internally after the route is successfully matched. For specific usage, please refer to [Parameters](#parameters).

## Path components

`PathComponent` is a core concept in RoutingKit. It is an abstract class with four subclasses:

- `ConstantPathComponent`: Constant path component, for example `/users`.
- `ParameterPathComponent`: Parameter path component, for example `/users/:user_id`.
- `AnythingPathComponent`: Wildcard path component, for example `/users/*`.
- `CatchallPathComponent`: Catchall path component, for example `/users/**`.

Of course, you don’t have to care about these classes, because RoutingKit has provided you with some convenient methods, for example:

```dart
'/users'.pathComponents; // [ConstantPathComponent('users')]
'/users/:user_id'.pathComponents; // [ConstantPathComponent('users'), ParameterPathComponent('user_id')]
'users'.pathComponent // ConstantPathComponent('users')
'/users/:id/*'.pathComponents; // [ConstantPathComponent('users'), ParameterPathComponent('id'), AnythingPathComponent()]
'/users/**'.pathComponents; // [ConstantPathComponent('users'), CatchallPathComponent()]
```

You can also directly pass a string to the default constructor factory function of `PathComponent`, for example:

```dart
PathComponent('users'); // ConstantPathComponent('users')
PathComponent(':user_id'); // ParameterPathComponent('user_id')
PathComponent('*'); // AnythingPathComponent()
PathComponent('**'); // CatchallPathComponent()
```

At the same time, `PathComponent` also provides literal constructors and static properties:

```dart
PathComponent.constant('users'); // ConstantPathComponent('users')
PathComponent.parameter('user_id'); // ParameterPathComponent('user_id')
PathComponent.anything; // AnythingPathComponent()
PathComponent.catchall; // CatchallPathComponent()
```

`PathComponent` has only one property `description`, which is a string used to describe the literal definition of the current path component, for example:

```dart
PathComponent.constant('users').description; // users
```

### ConstantPathComponent

The `ConstantPathComponent` is a constant path component, and its `constant` parameter is a constant string, for example:

```dart
final component = PathComponent.constant('users');
```

It returns a `component` that is a `ConstantPathComponent` instance that represents the constant string that must be matched in the path segment, for example:

```dart
router.register(0, '/users'.pathComponents);

final params = Parameters();
router.lookup('/users'.splitWithSlash(), params); // 0
router.lookup('/posts'.splitWithSlash(), params); // null
```

### ParameterPathComponent

The `ParameterPathComponent` is a parameter path component, and its `identifier` parameter is a string used to represent the name of the current parameter, for example:

```dart
final component = PathComponent.parameter('user_id');
```

It returns a `component` that is a `ParameterPathComponent` instance that represents the parameter that must be matched in the path segment, for example:

```dart
router.register(0, '/users/:user_id'.pathComponents);

final params = Parameters();

router.lookup('/users/1'.splitWithSlash(), params); // 0
print(params.allNames); // {user_id}
print(params.get('user_id')); // 1
```

### AnythingPathComponent

The `AnythingPathComponent` is a path wildcard component that matches any string in the current path segment, for example:

```dart
router.register(0, '/users/:user_id/*'.pathComponents);

final params = Parameters();

router.lookup('/users/1/posts'.splitWithSlash(), params); // 0
print(params.getCatchall()); // (posts)
```

### CatchallPathComponent

The `CatchallPathComponent` is a path capture component that matches all path segments defined after it, for example:

```dart
router.register(0, '/users/**'.pathComponents);

final params = Parameters();

router.lookup('/users/1/posts'.splitWithSlash(), params); // 0
print(params.getCatchall()); // (1, posts)
```

## Parameters

`Parameters` is a parameter container that will save the matched parameters internally after the route is successfully matched, for example:

```dart
router.register(0, '/users/:user_id'.pathComponents);

final params = Parameters();

router.lookup('/users/1'.splitWithSlash(), params); // 0

print(params.get('user_id')); // 1
print(params.allNames); // {user_id}
```

### `get`

`Parameters` provides the `get` method to get the parameter with the specified name, for example:

```dart
params.get('user_id'); // 1
```

### `getAs`

`Parameters` provides the `getAs` method to get the parameter with the specified name and convert it to the specified type, for example:

```dart
params.getAs<int>('user_id', int.parse); // 1
```

It has two parameters:

- `name`: Parameter name.
- `cast`: Parameter conversion function.

### `set`

`Parameters` provides the `set` method to set the parameter with the specified name, for example:

```dart
params.set('user_id', '1');
```

RoutingKit saves the matched parameters in `Parameters` through the `set` method. You can also set more custom parameters through the `set` method, for example:

```dart
params.set('other', '1');
```

### `allNames`

The `Parameters` provides the `allNames` property to get all parameter names, for example:

```dart
params.allNames; // {user_id, other}
```

### `getCatchall`

`Parameters` provides the `getCatchall` method to get the captured `AnythingPathComponent` or `CatchallPathComponent` parameter, for example:

```dart
router.register(0, '/users/:user_id/*'.pathComponents);
router.register(1, '/posts/**'.pathComponents);

final params = Parameters();

router.lookup('/users/1/posts'.splitWithSlash(), params); // 0
print(params.getCatchall()); // (posts)

router.lookup('/posts/1/2/3'.splitWithSlash(), params); // 1
print(params.getCatchall()); // (1, 2, 3)
```

### `setCatchall`

The `Parameters` provides the `setCatchall` method to set the captured `AnythingPathComponent` or `CatchallPathComponent` parameter. You can set the captured parameter by the `setCatchall` method, for example:

```dart
router.register(0, '/users/:user_id/*'.pathComponents);

final params = Parameters();

router.lookup('/users/1/posts'.splitWithSlash(), params); // 0
print(params.getCatchall()); // (posts)

params.setCatchall(['1', '2', '3']);
print(params.getCatchall()); // (1, 2, 3)
```

## Router

The `Router` is an interface class that has two abstract methods:

- `register`: Register route.
- `lookup`: Route matching.

In RoutingKit, `TrieRouter` is an implementation of `Router`. It is a router based on [Trie](https://en.wikipedia.org/wiki/Trie) tree. Its `register` method is used to register routes, and its `lookup` method is used for route matching.

### `register`

`register` method is used to register routes, it has two parameters:

- `value`: Route value, it is a generic parameter, specified by the generic parameter of `Router<T>`.
- `path`: Route component, it is an `Iterable<PathComponent>` type parameter.

Example:

```dart
router.register(0, '/users/:user_id'.pathComponents);
```

### `lookup`

`lookup` method is used for route matching, it has two parameters:

- `path`: 路由片段，它是一个 `Iterable<String>` 类型的参数。
- `parameters`: 参数容器，它是一个 `Parameters` 类型的参数。

- `path`: Route segment, it is an `Iterable<String>` type parameter.
- `parameters`: Parameter container, it is a `Parameters` type parameter.

Example:

```dart
router.lookup('/users/1'.splitWithSlash(), Parameters());
```

## Case sensitive

RoutingKit is case sensitive by default, you can set case sensitive through the `caseSensitive` parameter, for example:

```dart
final router = TrieRouter(
  options: ConfigurationOptions(caseSensitive: false), // `false` 表示大小写不敏感
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
