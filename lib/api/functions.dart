import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Functions {
  // 필드, 생성자, 메서드 등

  // 싱글턴 패턴을 사용하여 하나의 인스턴스만 생성되게 할 수 있습니다.
  static final Functions _singleton = Functions._internal();

  // late FirebaseFunctions _functionsForEmulator;
  late FirebaseFunctions _functionsForProd;

  factory Functions() {
    return _singleton;
  }

  Functions._internal() {
    // _functionsForEmulator = FirebaseFunctions.instanceFor();
    // _functionsForEmulator.useFunctionsEmulator('172.30.1.42', 5001);
    // instanceFor() 로 새로운 객체 생성하려 해도 기존 객체 리턴하므로 생성자 뜯어고칠 거 아니면
    // useFunctionsEmulator 사용 후엔 재기동이 맘 편함.
    _functionsForProd = FirebaseFunctions.instanceFor();
  }

  // on_call() 방식 호출
  Future<String> defaultOpenAI(prompt) async {
    try {
      // _functionsForProd.useFunctionsEmulator('172.30.1.42', 5001); // 에뮬 사용
      HttpsCallable callable = _functionsForProd.httpsCallable('defaultOpenAI');
      final response = await callable.call(<String, dynamic>{
        'api_key': dotenv.env['GPT_API_KEY'].toString(),
        'prompt': prompt,
        'push': true,
      });
      if (response.data['statusCode'] == 200) {
        return response.data['body'];
      } else {
        return '${response.data['statusCode']} error: ${response.data['body']}';
      }
    } on FirebaseFunctionsException catch (e) {
      return 'Function error: ${e.code}\n${e.message}\n${e.details}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // on_request 방식 호출
  void requestOpenAI(prompt) async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    try {
      final response = await http.post(
        Uri.parse(
            // 'http://172.30.1.42:5001/haru-s-diary/us-central1/requestOpenAI'),
            'https://requestopenai-qu6gkckzzq-uc.a.run.app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${token!}',
        },
        body: jsonEncode({
          'api_key': dotenv.env['GPT_API_KEY'].toString(),
          'prompt': prompt,
        }),
      );
      if (response.statusCode == 200) {
        print('Server Response: ${response.body}');
      } else {
        print('Error with the request: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }
}

final func = Functions();
