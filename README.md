# Routing Kit

Routing Kit 是一个基于 [Trie-Node](https://en.wikipedia.org/wiki/Trie) 的高性能路由器。

Routing Kit is a high-performance router based on [Trie-Node](https://en.wikipedia.org/wiki/Trie).

## Installation

通过命令行安装:

Install via command line:

```bash
# Dart Project
$ dart pub add routingkit

# Flutter
$ flutter pub add routingkit
```

## Methods

`TrieRouter` 暴露两个方法：

`TrieRouter` exposes two methods:

- `register`: 注册路由
- `lookup`: 查找路由

- `register`: Register a value to a route
- `lookup`: Returns a value for a route

### `register`

要注册一个值到路由，需要提供一个 `path` 和一个 `value`。

To register a value to a route, you need to provide a `path` and a `value`.

```dart
router.register(0, '/a/b/c'.toPathComponents());
// Or
router.register(1, [PathComponent('a'), PathComponent('b'), PathComponent('c')]);
```

### `lookup`

要查找一个路由，需要提供一个 `path`，它会返回一个 `T?` 类型的值。

To lookup a route, you need to provide a `path`, it will return a value of type `T?`.

```dart
final parameters = Parameters();

router.lookup('/a/b/c'.splitWithSlash(), parameters);
// Or
router.lookup(['a', 'b', 'c'], parameters);
```

### Path component

每个路由注册方法都需要一个 `path`，它是一个 `Iterable<PathComponent>` 类型的值。
而 `PathComponent` 是一个抽象类，它有两个工厂构造函数和两个常量：

Each route registration method requires a `path`, which is a value of type `Iterable<PathComponent>`:

- `PathComponent.constant`: 用于注册常量路由 (`foo`)
- `PathComponent.parameter`: 用于注册参数路由 (`:foo`)
- `PathComponent.anything`: 用于注册通配符路由 (`*`)
- `PathComponent.catchAll`: 用于注册捕获所有路由 (`**`)

- `PathComponent.constant`: Used to register constant routes (`foo`)
- `PathComponent.parameter`: Used to register parameter routes (`:foo`)
- `PathComponent.anything`: Used to register wildcard routes (`*`)
- `PathComponent.catchAll`: Used to register catch-all routes (`**`)

#### Constant

它是一个静态 path 组件，仅允许在此位置注册一个具有完全匹配的请求字符串：

It is a static path component, which only allows a request string with a complete match to be registered at this location:

```dart
// represents the path `/foo/bar`
router.register(0, [PathComponent.constant('foo'), PathComponent.constant('bar')]);
```

#### Parameter

这是一个参数 path 组件，它允许在此位置注册任何请求字符串。参数路径组件用 `:` 前缀指定，后面的字符串用作参数名称。

你可以在匹配完成路由之后从 `Parameters` 对象中获取参数值。

This is a parameter path component, which allows any request string to be registered at this location. Parameter path components are specified with the `:` prefix, and the following string is used as the parameter name.

You can get the parameter value from the `Parameters` object after the route is matched.

```dart
// represents the path `/foo/:bar`
router.register(0, [PathComponent.constant('foo'), PathComponent.parameter('bar')]);

final parameters = Parameters();

router.lookup('/foo/123'.splitWithSlash(), parameters);

print(parameters.get('bar')); // 123
```

#### Anything

它与 Parameter 类似，但是它允许在此位置注册任何请求字符串。但是，它不会将参数值存储在 `Parameters` 对象中。

It is similar to Parameter, but it allows any request string to be registered at this location. However, it does not store the parameter value in the `Parameters` object.

```dart
// represents the path `/foo/*`
router.register(0, [PathComponent.constant('foo'), PathComponent.anything()]);

// or
router.register(0, '/foo/*'.toPathComponents());
```

#### Catch-all

它与 Anything 类似，但是它允许在此位置注册任何请求字符串。但是，Anyting 仅仅匹配一个路径片段，而 Catch-all 匹配所有剩余的路径片段。

It is similar to Anything, but it allows any request string to be registered at this location. However, Anyting only matches one path segment, while Catch-all matches all remaining path segments.

```dart
// represents the path `/foo/**`
router.register(0, [PathComponent.constant('foo'), PathComponent.catchAll()]);

// or
router.register(0, '/foo/**'.toPathComponents());
```

## Case sensitivity routing

默认情况下，Routing Kit 是不区分大小写的，但是你可以通过 `caseSensitive` 参数来控制是否区分大小写。

By default, Routing Kit is case-insensitive, but you can control whether it is case-sensitive through the `caseSensitive` parameter.

```dart
final router = TrieRouter(
    options: ConfigurationOptions(caseSensitive: true),
);
```
