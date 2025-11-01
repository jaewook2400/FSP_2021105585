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
      print('📨 서버 응답dd: $body');
    } else {
      print('알 수 없는 명령: $command');
    }
  }
}
