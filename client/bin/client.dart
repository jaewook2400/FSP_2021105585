import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  while (true) {
    stdout.write('> '); // 프롬프트 표시
    String? command = stdin.readLineSync();

    if (command == null || command.trim() == 'exit') {
      print('프로그램 종료');
      break;
    }

    if (command == 'hello') {
      final uri = Uri.parse('http://localhost:8080/hello');
      final response = await HttpClient().getUrl(uri)
          .then((req) => req.close());
      final body = await utf8.decodeStream(response);
      print('📨 서버 응답: $body');
    }

    else if (command == 'ingredient') {
      final uri = Uri.parse('http://localhost:8080/ingredient');
      final response = await HttpClient().getUrl(uri)
          .then((req) => req.close());
      final body = await utf8.decodeStream(response);
      print('📨 서버 응답: $body');
    } 

    else if (command == 'preference') {
      await sendPreferenceRequest();
    }
    
    else {
      print('알 수 없는 명령: $command');
    }
  }
}


Future<void> sendPreferenceRequest() async {
  final uri = Uri.parse('http://localhost:8080/preference');

  // ✅ 보낼 JSON 데이터
  final preferenceData = {
    "preference": [true, false, true, false, true, false, true, false, true, false]
  };

  final client = HttpClient();
  final request = await client.postUrl(uri);

  // ✅ 헤더 설정
  request.headers.contentType = ContentType.json;

  // ✅ body 쓰기
  request.write(jsonEncode(preferenceData));

  // ✅ 서버 응답 받기
  final response = await request.close();
  final reply = await utf8.decodeStream(response);

  print("📩 서버 응답:");
  print(reply);

  client.close();
}
