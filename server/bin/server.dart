import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('✅ Server running on http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    if (request.method == 'GET' && request.uri.path == '/hello') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({'message': 'Hello from Dart server!'}))
        ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('404 Not Found')
        ..close();
    }
  }
}
