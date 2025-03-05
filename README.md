<h1 align="center" style="font-size: 36px">RoutingKit</h1>

<p align="center">
  <a href="https://pub.dev/packages/routingkit"><img alt="Pub Version" src="https://img.shields.io/pub/v/routingkit?logo=dart"/></a>
  <a href="https://github.com/medz/routingkit/actions/workflows/test.yml"><img alt="Test" src="https://github.com/medz/routingkit/actions/workflows/test.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/medz/routingkit?tab=MIT-1-ov-file"><img alt="License" src="https://img.shields.io/github/license/medz/routingkit" /></a>
  <a href="https://github.com/sponsors/medz"><img alt="Sponsors" src="https://img.shields.io/github/sponsors/medz?logo=githubsponsors" /></a>
  <a href="https://twitter.com/shiweidu"><img alt="X (formerly Twitter) Follow" src="https://img.shields.io/twitter/follow/shiweidu" /></a>
</p>

<p align="center">
RoutingKit - A lightweight, high-performance router for Dart with an elegant object-oriented API.
</p>

## Features

- 🚀 **High Performance**: Optimized route matching using a trie-based structure
- 🧩 **Flexible Routes**: Support for static, parameterized, and wildcard routes
- 💪 **Type Safety**: Generic typing for your route handlers
- 🔍 **Comprehensive Matching**: Find single or all matching routes
- 🧰 **Object-Oriented API**: Clean interface with clear separation of concerns
- 🔠 **Case Sensitivity Options**: Configure whether path matching is case sensitive or not

## Installation

Run this command:

```bash
dart pub add routingkit
```

With Flutter:

```bash
flutter pub add routingkit
```

## Usage

### Creating a Router

```dart
import 'package:routingkit/routingkit.dart';

// Create a typed router (recommended)
final router = createRouter<String>();

// For case-insensitive routing
final caseInsensitiveRouter = createRouter<String>(caseSensitive: false);

// With custom 'any' method token (default is 'any')
final customRouter = createRouter<String>(anyMethodToken: '*');
```

### Adding Routes

RoutingKit supports various route patterns:

```dart
// Static routes
router.add('GET', '/users', 'Users list handler');

// Parameter routes (with named parameters)
router.add('GET', '/users/:id', 'User details handler');

// Multiple parameters
router.add('GET', '/users/:id/posts/:postId', 'User post handler');

// Optional parameters (using separate routes)
router.add('GET', '/files/:filename/*', 'File with format handler');
router.add('GET', '/files/:filename', 'File without format handler');

// Wildcard routes
router.add('GET', '/assets/**', 'Static assets handler');

// Named wildcard segments
router.add('GET', '/docs/**:path', 'Documentation handler');

// Method-specific routes
router.add('POST', '/users', 'Create user handler');
router.add('PUT', '/users/:id', 'Update user handler');
router.add('DELETE', '/users/:id', 'Delete user handler');
```

### Matching Routes

Find the first matching route:

```dart
final match = router.find('GET', '/users/123');

if (match != null) {
  print('Handler: ${match.data}');
  print('Parameters: ${match.params}'); // {id: 123}
}
```

Find all matching routes (useful for middleware):

```dart
final matches = router.findAll('GET', '/users/123/settings');

for (final match in matches) {
  print('Handler: ${match.data}');
  print('Parameters: ${match.params}');
}
```

### Removing Routes

```dart
// Remove a specific route
router.remove('GET', '/users/:id');

// Remove all routes for a specific method
router.remove('POST', null);
```

### HTTP Method Handling

RoutingKit automatically normalizes HTTP methods to uppercase. This means that methods like 'get', 'GET', or 'Get' are all treated as 'GET'. This follows the HTTP specification and makes the router more robust.

```dart
router.add('get', '/users', 'get-users');  // Will be normalized to 'GET'
router.add('POST', '/users', 'post-users'); // Will be normalized to 'POST'

// All these will match the same route
router.find('get', '/users');   // Matches
router.find('GET', '/users');   // Matches
router.find('Get', '/users');   // Matches
```

### Advanced Configuration

#### Case Sensitivity

By default, RoutingKit performs case-sensitive path matching. You can make path matching case-insensitive:

```dart
// Create a case-insensitive router
final router = createRouter<String>(caseSensitive: false);

// Add a route with mixed case
router.add('GET', '/Users/:ID', 'user handler');

// All these will match the same route
final match1 = router.find('GET', '/users/123');    // Matches
final match2 = router.find('GET', '/Users/456');    // Matches
final match3 = router.find('GET', '/USERS/789');    // Matches

// Parameter names preserve their original case
print(match1.params);  // {ID: 123}
```

#### Custom Method Tokens

You can customize the token used to represent any HTTP method:

```dart
final router = createRouter<String>(anyMethodToken: 'ANY_METHOD');

// Add routes with different methods
router.add('GET', '/api', 'get handler');
router.add(null, '/api', 'any handler');  // Uses custom token

router.find('POST', '/api')?.data;  // Returns 'any handler'
```

## Example Applications

### HTTP Server Routing

```dart
import 'dart:io';
import 'package:routingkit/routingkit.dart';

void main() async {
  final router = createRouter<Function>();

  // Define routes with handler functions
  router.add('GET', '/', (req, res) => res.write('Home page'));
  router.add('GET', '/users', (req, res) => res.write('Users list'));
  router.add('GET', '/users/:id', (req, res) => res.write('User ${req.params['id']}'));

  final server = await HttpServer.bind('localhost', 8080);
  print('Server running on http://localhost:8080');

  await for (final request in server) {
    final response = request.response;
    final path = request.uri.path;
    final method = request.method;

    final match = router.find(method, path);

    if (match != null) {
      final handler = match.data;
      // Add params to request for handler access
      (request as dynamic).params = match.params;
      handler(request, response);
    } else {
      response.statusCode = HttpStatus.notFound;
      response.write('404 Not Found');
    }

    await response.close();
  }
}
```

## For AI Assistance

RoutingKit includes an `llms.txt` file at the root of the repository. This file is specifically designed to help Large Language Models (LLMs) understand the project structure and functionality.

If you're using AI tools like GitHub Copilot, Claude, or ChatGPT to work with this codebase, you can point them to the `llms.txt` file for better context and more accurate assistance.

```dart
// Example: Asking an AI about the project
"Please read the llms.txt file in this repository to understand the RoutingKit structure"
```

The file provides AI-friendly documentation including:
- Project overview and core concepts
- Code structure explanation
- API reference and examples
- Links to relevant implementation files

## Migration Guides

### Migration from Format Parameters

In versions prior to 0.2.0, RoutingKit supported format parameters using the syntax `:filename.:format?`. This feature has been removed due to implementation complexity and inconsistent behavior.

#### How to Migrate

1. **Replace format parameters with standard path parameters**:

   Before:
   ```dart
   router.add('GET', '/files/:filename.:format?', 'File handler');
   ```

   After:
   ```dart
   // For required format
   router.add('GET', '/files/:filename/:format', 'File handler');

   // For optional format (using two routes)
   router.add('GET', '/files/:filename/*', 'File with format handler');
   router.add('GET', '/files/:filename', 'File without format handler');
   ```

2. **Update parameter access**:

   Before:
   ```dart
   final match = router.find('GET', '/files/document.pdf');
   final filename = match?.params['filename']; // 'document'
   final format = match?.params['format'];     // 'pdf'
   ```

   After:
   ```dart
   // For standard path parameters
   final match = router.find('GET', '/files/document/pdf');
   final filename = match?.params['filename']; // 'document'
   final format = match?.params['format'];     // 'pdf'

   // For wildcard approach
   final match = router.find('GET', '/files/document/pdf');
   final filename = match?.params['filename']; // 'document'
   final format = match?.params['_0'];         // 'pdf'
   ```

### Migration from v4.x

See the [Migration Guide](https://github.com/medz/routingkit/blob/main/CHANGELOG.md#migration-guide) in the changelog.

## License

RoutingKit is open-sourced software licensed under the [MIT license](https://github.com/medz/routingkit?tab=MIT-1-ov-file).
