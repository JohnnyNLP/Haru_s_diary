import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class Functions {
  // 필드, 생성자, 메서드 등

  // 싱글턴 패턴을 사용하여 하나의 인스턴스만 생성되게 할 수 있습니다.
  static final Functions _singleton = Functions._internal();

  final useEmul = false; // emulators 사용여부

  late FirebaseFunctions _functionsForProd;

  final _authentication = FirebaseAuth.instance; //Firebase 인증 객체 생성

  factory Functions() {
    return _singleton;
  }

  Functions._internal() {
    _functionsForProd = FirebaseFunctions.instanceFor();
    if (useEmul) _functionsForProd.useFunctionsEmulator('localhost', 5001);
  }

  Future<Map<String, dynamic>> callLambda(
      String lambdaEndpoint, Map<String, dynamic> keyValue) async {
    try {
      // Extract values from the keyValue map
      String? token = await _authentication.currentUser!.getIdToken(true);

      // Construct the URL with query parameters
      String requestUrl = "$lambdaEndpoint?";
      keyValue.forEach((key, value) {
        requestUrl += '$key=$value&';
      });

      // Print the full URL for debugging
      print("Sending request to $requestUrl");

      // print(token);
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": 'OUp8SJXQPA9dXudxv3KOi9ZWjJzsoqk77gwqzJvM',
          "token": token!, // Assuming you want to use this header for the token
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['statusCode'] == 200) {
          return data['body'] as Map<String, dynamic>;
        } else {
          throw Exception('${data['statusCode']} error: ${data['body']}');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw e; // Propagate the exception for better error handling in the caller.
    }
  }

  Future<dynamic> callFunctions(functionName, keyValue) async {
    try {
      if (useEmul) _functionsForProd.useFunctionsEmulator('localhost', 5001);
      HttpsCallable callable = _functionsForProd.httpsCallable(functionName);

      final Map<String, dynamic> request = {
        ...{
          // 공통으로 적용되는 request
          'userID': _authentication.currentUser!.uid,
          // 'OPENAI_API_KEY': dotenv.env['GPT_API_KEY'].toString(),
          'push': true,
        },
        ...keyValue // 호출 시 명시한 keyValue
      };
      // print('request: ${request}');
      final response = await callable.call(request);
      // print(response.data);
      if (response.data['statusCode'] == 200) {
        return response.data['body'];
      } else {
        return '${response.data['statusCode']} error: ${response.data['body']}';
      }
    } on FirebaseFunctionsException catch (e) {
      print(e);
      return 'Function error: ${e.code}\n${e.message}\n${e.details}';
    } catch (e) {
      print(e);
      return 'Error: $e';
    }
  }
}

final func = Functions();
