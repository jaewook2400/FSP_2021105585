import 'dart:io';
import 'dart:convert';
import 'package:server/local_database.dart';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('✅ Server running on http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    if (request.method == 'GET' && request.uri.path == '/hello') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({'message': 'Hello from Dart server!'}))
        ..close();
    } 

    else if (request.method == 'GET' && request.uri.path == '/ingredient') {
      final ingredients = [
        "당근", "참치", "피망", "양파", "소시지",
        "계란", "닭가슴살", "오이", "시래기", "파"
      ];
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({"ingredient": ingredients}))
        ..close();
    }

    else if (request.method == 'POST' && request.uri.path == '/preference') {
      try {
        // 요청 body 읽기
        String content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content);

        // preference 리스트 꺼내기
        final List<dynamic> prefs = data["preference"];

        print("📩 Received preference: $prefs");

        // ✅ TODO: 선호도 분석 로직 자리 (지금은 mock)
        // 예: prefs에 따라 recipe 추천 알고리즘 만들 수 있음
        // 지금은 첫 번째 공식 레시피 추천 (임시)
        final recipe = aiMadeRecipe;

        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.ok
          ..write(jsonEncode(recipe))
          ..close();
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write(jsonEncode({"error": "Invalid JSON format"}))
          ..close();
      }
    }

    else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('404 Not Found')
        ..close();
    }
  }
}

Map<String, dynamic> removeRecipeType(Map<String, dynamic> recipe) {
  final newRecipe = Map<String, dynamic>.from(recipe);
  newRecipe.remove("recipeType");
  return newRecipe;
}
