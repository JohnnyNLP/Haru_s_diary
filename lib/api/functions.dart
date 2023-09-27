import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Functions {
  // 필드, 생성자, 메서드 등

  // 싱글턴 패턴을 사용하여 하나의 인스턴스만 생성되게 할 수 있습니다.
  static final Functions _singleton = Functions._internal();

  final useEmul = true; // emulators 사용여부

  late FirebaseFunctions _functionsForProd;

  factory Functions() {
    return _singleton;
  }

  Functions._internal() {
    _functionsForProd = FirebaseFunctions.instanceFor();
    if (useEmul) _functionsForProd.useFunctionsEmulator('localhost', 5001);
  }

  Future<dynamic> callFunctions(functionName, keyValue) async {
    try {
      if (useEmul) _functionsForProd.useFunctionsEmulator('localhost', 5001);
      HttpsCallable callable = _functionsForProd.httpsCallable(functionName);

      final Map<String, dynamic> request = {
        ...{
          // 공통으로 적용되는 request
          'userID': FirebaseAuth.instance.currentUser!.uid,
          'OPENAI_API_KEY': dotenv.env['GPT_API_KEY'].toString(),
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

  // functions 호출용 테스트 함수
  Future<String> testFunction(functionName, keyValue) async {
    try {
      if (useEmul) _functionsForProd.useFunctionsEmulator('localhost', 5001);
      HttpsCallable callable = _functionsForProd.httpsCallable(functionName);
      final fixed = <String, dynamic>{
        'userID': FirebaseAuth.instance.currentUser!.uid,
        'OPENAI_API_KEY': dotenv.env['GPT_API_KEY'].toString(),
        'push': true,
      };
      final response = await callable.call({...fixed, ...keyValue});
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
}

final func = Functions();
