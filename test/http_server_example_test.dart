import 'dart:convert';
import 'dart:io';

import 'package:routingkit/routingkit.dart';
import 'package:test/test.dart';

// Http mock server using RoutingKit
class MockServer {
  final Router<Function> router;
  HttpServer? _server;
  int? _port;

  MockServer() : router = createRouter<Function>();

  int? get port => _port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;

    _server!.listen((request) async {
      final path = request.uri.path.isEmpty ? '/' : request.uri.path;
      final method = request.method;

      final match = router.find(method, path);

      if (match != null) {
        try {
          // Execute the handler with request and provide params
          await match.data(request, match.params);
        } catch (e) {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write('Internal server error: $e');
          await request.response.close();
        }
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('404 Not Found');
        await request.response.close();
      }
    });

    print('Mock server started on port $_port');
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _port = null;
    print('Mock server stopped');
  }
}

// Helper class to simplify response handling
class MockResponse {
  final HttpClientResponse response;

  MockResponse(this.response);

  int get statusCode => response.statusCode;

  Future<String> body() async {
    return await utf8.decodeStream(response);
  }
}

void main() {
  late MockServer server;

  // Helper functions for HTTP requests
  Future<MockResponse> get(String path) async {
    final client = HttpClient();
    final request = await client.get('localhost', server.port!, path);
    final response = await request.close();
    return MockResponse(response);
  }

  Future<MockResponse> post(String path, {String? body}) async {
    final client = HttpClient();
    final request = await client.post('localhost', server.port!, path);

    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(body);
    }

    final response = await request.close();
    return MockResponse(response);
  }

  setUp(() async {
    server = MockServer();

    // Define routes
    server.router.add('GET', '/',
        (HttpRequest request, Map<String, String> params) async {
      request.response.write('Home Page');
      await request.response.close();
    });

    server.router.add('GET', '/users',
        (HttpRequest request, Map<String, String> params) async {
      request.response.write(jsonEncode(['user1', 'user2', 'user3']));
      await request.response.close();
    });

    server.router.add('GET', '/users/:id',
        (HttpRequest request, Map<String, String> params) async {
      final id = params['id'];
      request.response.write(jsonEncode({'id': id, 'name': 'User $id'}));
      await request.response.close();
    });

    server.router.add('POST', '/users',
        (HttpRequest request, Map<String, String> params) async {
      final body = await utf8.decodeStream(request);

      request.response.statusCode = HttpStatus.created;
      request.response.write('Created user: $body');
      await request.response.close();
    });

    server.router.add('GET', '/files/**:path',
        (HttpRequest request, Map<String, String> params) async {
      final path = params['path'];
      request.response.write('Serving file: $path');
      await request.response.close();
    });

    // Start server
    await server.start();
  });

  tearDown(() async {
    await server.stop();
  });

  test('GET /', () async {
    final response = await get('/');
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(await response.body(), equals('Home Page'));
  });

  test('GET /users', () async {
    final response = await get('/users');
    expect(response.statusCode, equals(HttpStatus.ok));

    final body = await response.body();
    final List<dynamic> users = jsonDecode(body);

    expect(users, hasLength(3));
    expect(users, contains('user1'));
  });

  test('GET /users/:id', () async {
    final response = await get('/users/42');
    expect(response.statusCode, equals(HttpStatus.ok));

    final body = await response.body();
    final Map<String, dynamic> user = jsonDecode(body);

    expect(user['id'], equals('42'));
    expect(user['name'], equals('User 42'));
  });

  test('POST /users', () async {
    final userData =
        jsonEncode({'name': 'New User', 'email': 'user@example.com'});
    final response = await post('/users', body: userData);

    expect(response.statusCode, equals(HttpStatus.created));
    expect(await response.body(), contains('New User'));
  });

  test('GET /files/**:path', () async {
    final response = await get('/files/images/profile.jpg');

    expect(response.statusCode, equals(HttpStatus.ok));
    expect(await response.body(), equals('Serving file: images/profile.jpg'));
  });

  test('404 for non-existent route', () async {
    final response = await get('/nonexistent');

    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(await response.body(), contains('404'));
  });
}
