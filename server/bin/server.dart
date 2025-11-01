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

        // 고정된 레시피 응답
        final recipeResponse = {
          "recipeId": 1,
          "name": "계란볶음밥",
          "timeToCook": 15,
          "ingredient": ["계란", "밥"],
          "description": "계란을 이용한 밥 요리입니다.",
          "imageUrl": "http://fiscom/300/400",
          "process": [
            "프라이팬에 기름을 부어 달군다.",
            "계란과 밥을 넣어 볶는다.",
            "기호에 맞게 양념을 추가한다."
          ]
        };

        request.response
          ..headers.contentType = ContentType.json
          ..statusCode = HttpStatus.ok
          ..write(jsonEncode(recipeResponse))
          ..close();
      } catch (e) {
        // JSON parse 실패 등 오류 캐치
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
