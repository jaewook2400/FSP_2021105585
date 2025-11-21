import 'dart:convert';
import 'dart:io';
import 'package:client/secure_storage.dart';

const String baseUrl = 'http://localhost:8080';
const String apiBase = '$baseUrl/api';

String? _token; // 로그인/회원가입 후 저장되는 토큰 (Authorization에 사용)

void main(List<String> args) async {
  if (args.isEmpty) {
    _printUsage();
    exit(1);
  }

  final cmd = args[0];
  try {
    switch (cmd) {
    // ---------- 온보딩 ----------
      case 'register':
      // register <username> <password>
        _requireArgs(args, 3);
        await register(args[1], args[2]);
        break;

      case 'login':
      // login <username> <password>
        _requireArgs(args, 3);
        await login(args[1], args[2]);
        break;

    // ---------- 홈 ----------
      case 'ingredient':
        await getIngredients();
        break;

      case 'preference':
      // preference true,false,true,false,true,false,true,false,true,false
        _requireArgs(args, 2);
        final pref = args[1]
            .split(',')
            .map((e) => e.trim().toLowerCase() == 'true')
            .toList();
        await postPreference(pref);
        break;

      case 'unselect':
      // unselect <recipeId>
        _requireArgs(args, 2);
        await deleteHomeSelection(int.parse(args[1]));
        break;

    // ---------- 레시피 ----------
      case 'recipes':
        await listRecipes();
        break;

      case 'recipe':
      // recipe <id>
        _requireArgs(args, 2);
        await getRecipe(int.parse(args[1]));
        break;

      case 'like':
      // like <id>
        _requireArgs(args, 2);
        await likeRecipe(int.parse(args[1]));
        break;

      case 'unlike':
      // unlike <id>
        _requireArgs(args, 2);
        await unlikeRecipe(int.parse(args[1]));
        break;

      case 'liked':
        await listLikedRecipes();
        break;

    // ---------- 기록 ----------
      case 'recorded':
        await listRecordedRecipes();
        break;

      case 'record-del':
        await deleteRecordedRecipe(args);
        break;

      case 'addrecord':
      // addrecord '{"name":"내 요리","timeToCook":10,"ingredient":["계란"],"description":"테스트","imageUrl":"http://example/300/400","process":["1","2"]}'
        _requireArgs(args, 2);
        final payload = jsonDecode(args[1]) as Map<String, dynamic>;
        await addRecordedRecipe(payload);
        break;

    // ---------- 이미지 ----------
      case 'imageurl':
        await createImageUrl();
        break;

    // ---------- 토큰 ----------
      case 'token':
        if (args.length >= 2) {
          _token = args[1];
          print('🔑 token set: $_token');
        } else {
          print('🔑 token: $_token');
        }
        break;

      default:
        print('알 수 없는 명령: $cmd');
        _printUsage();
        exit(2);
    }
  } catch (e, st) {
    print('❌ Error: $e\n$st');
    exit(10);
  }
}

// -------------- 온보딩 --------------

Future<void> register(String username, String password) async {
  final res = await _post('$apiBase/register', {'username': username, 'password': password});
  _pretty(res);
  _token = res['token']?.toString();
}

Future<void> login(String username, String password) async {
  final res = await _post('$apiBase/login', {'username': username, 'password': password});
  _pretty(res);
  _token = res['token']?.toString();
  //print(_token);
  if(_token != null){
    SecureStorage().saveAccessToken(_token!);
  }
  _nextPrompt();
}

// -------------- 홈 --------------

Future<void> getIngredients() async {
  final res = await _get('$apiBase/home/ingredient');
  _pretty(res);
  _nextPrompt();
}

Future<void> postPreference(List<bool> pref) async {
  final res = await _post('$apiBase/home/preference', {'preference': pref});
  _pretty(res);
  _nextPrompt();
}

Future<void> deleteHomeSelection(int recipeId) async {
  final res = await _delete('$apiBase/home/$recipeId');
  _pretty(res);
  _nextPrompt();
}

// -------------- 레시피 --------------

Future<void> listRecipes() async {
  final res = await _get('$apiBase/recipe');
  _pretty(res);
  _nextPrompt();
}

Future<void> getRecipe(int id) async {
  final res = await _get('$apiBase/recipe/$id');
  _pretty(res);
  _nextPrompt();
}

Future<void> likeRecipe(int id) async {
  final res = await _post('$apiBase/recipe/$id/like', {});
  _pretty(res);
  _nextPrompt();
}

Future<void> unlikeRecipe(int id) async {
  final res = await _delete('$apiBase/recipe/$id/like');
  _pretty(res);
  _nextPrompt();
}

Future<void> listLikedRecipes() async {
  final res = await _get('$apiBase/recipe/like');
  _pretty(res);
  _nextPrompt();
}

// -------------- 기록 --------------

Future<void> listRecordedRecipes() async {
  final res = await _get('$apiBase/record/recipe');
  _pretty(res);
  _nextPrompt();
}

Future<void> deleteRecordedRecipe(List<String> args) async {
  _requireArgs(args, 1);
  final id = args[1];

  final url = '$baseUrl/api/record/$id';

  final response = await _delete(url);
  print(response);
  _nextPrompt();
}

Future<void> addRecordedRecipe(Map<String, dynamic> recipe) async {
  final res = await _post('$apiBase/record/recipe', recipe);
  _pretty(res);
  _nextPrompt();
}

// -------------- 이미지 --------------

Future<void> createImageUrl() async {
  final res = await _post('$apiBase/imageUrl', {});
  _pretty(res);
  _nextPrompt();
}

// -------------- HTTP 유틸 --------------

Future<Map<String, dynamic>> _get(String url) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse(url));
    await _attachAuth(req);
    final resp = await req.close();
    final text = await utf8.decodeStream(resp);
    final json = jsonDecode(text);
    return _asMap(json);
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(Uri.parse(url));
    await _attachAuth(req);
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final resp = await req.close();
    final text = await utf8.decodeStream(resp);
    final json = jsonDecode(text);
    return _asMap(json);
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> _delete(String url) async {
  final client = HttpClient();
  try {
    final req = await client.openUrl('DELETE', Uri.parse(url));
    await _attachAuth(req);
    final resp = await req.close();
    final text = await utf8.decodeStream(resp);
    final json = jsonDecode(text);
    return _asMap(json);
  } finally {
    client.close();
  }
}

Future<void> _attachAuth(HttpClientRequest req) async {
  final token = await SecureStorage().getAccessToken();
  //print('🔐 attach token: $token');

  if (token != null && token.isNotEmpty) {
    req.headers.add(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
}

Map<String, dynamic> _asMap(dynamic json) {
  if (json is Map<String, dynamic>) return json;
  return {'data': json};
}

void _pretty(Map<String, dynamic> data) {
  final pretty = const JsonEncoder.withIndent('  ').convert(data);
  print(pretty);
}

void _requireArgs(List<String> args, int n) {
  if (args.length < n) {
    _printUsage();
    throw ArgumentError('Not enough arguments');
  }
}

void _nextPrompt() {
  print("\n👉 다음 명령어를 입력하세요:");
  print("   (예: ingredient, recipes, like 1, recorded, unselect 3 …)\n");
}

void _printUsage() {
  print('''
사용법:
  # 온보딩
  register <username> <password>
  login <username> <password>
  token [value]         # 토큰 보기/설정 (Bearer 값, 예: user1 또는 token-user1)

  # 홈
  ingredient
  preference <bool,bool,bool,...>   # 예: preference true,false,true,false,true,false,true,false,true,false
  unselect <recipeId>

  # 레시피
  recipes
  recipe <id>
  like <id>
  unlike <id>
  liked

  # 기록
  recorded
  addrecord '<json>'   # 예: addrecord '{"name":"내 요리","timeToCook":10,"ingredient":["계란"],"description":"테스트","imageUrl":"http://ex/300/400","process":["1","2"]}'

  # 이미지
  imageurl

예시:
  dart run client/bin/client.dart register user1 pass1
  dart run client/bin/client.dart login user1 pass1
  dart run client/bin/client.dart token user1
  dart run client/bin/client.dart ingredient
  dart run client/bin/client.dart preference true,false,true,false,true,false,true,false,true,false
  dart run client/bin/client.dart unselect 1
  dart run client/bin/client.dart recipes
  dart run client/bin/client.dart recipe 1
  dart run client/bin/client.dart like 1
  dart run client/bin/client.dart unlike 1
  dart run client/bin/client.dart liked
  dart run client/bin/client.dart recorded
  cli addrecord '{"name":"내 요리 2","timeToCook":10,"ingredient":["계란"],"description":"테스트","imageUrl":"http://ex/300/400","process":["1","2"]}'
  dart run client/bin/client.dart record-del 102
  dart run client/bin/client.dart imageurl
  
  유저 정보 조회: curl -X GET http://localhost:8080/api/debug/userinfo \
     -H "Authorization: Bearer token-user1"


''');
}
