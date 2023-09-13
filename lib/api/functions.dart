import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Functions {
  // 필드, 생성자, 메서드 등

  // 싱글턴 패턴을 사용하여 하나의 인스턴스만 생성되게 할 수 있습니다.
  static final Functions _singleton = Functions._internal();

  final useEmul = false;

  late FirebaseFunctions _functionsForProd;

  factory Functions() {
    return _singleton;
  }

  Functions._internal() {
    _functionsForProd = FirebaseFunctions.instanceFor();
    if (useEmul)
      _functionsForProd.useFunctionsEmulator('localhost', 5001); // 에뮬 사용
  }

  Future<String> haruChat(
      prompt, date, chat_template, informal_template) async {
    try {
      if (useEmul)
        _functionsForProd.useFunctionsEmulator('localhost', 5001); // 에뮬 사용
      print([prompt, date, chat_template, informal_template]);
      HttpsCallable callable = _functionsForProd.httpsCallable('ChatAI');
      final response = await callable.call(<String, dynamic>{
        'userID': FirebaseAuth.instance.currentUser!.uid,
        'date': date,
        'prompt': prompt,
        'chat_template': chat_template,
        'informal_template': informal_template,
        'OPENAI_API_KEY': dotenv.env['GPT_API_KEY'].toString(),
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

  Future<String> callFunctions(functionName, keyValue) async {
    try {
      if (useEmul)
        _functionsForProd.useFunctionsEmulator('localhost', 5001); // 에뮬 사용
      HttpsCallable callable = _functionsForProd.httpsCallable(functionName);

      final request = {
        ...{
          // 공통으로 적용되는 request
          'userID': FirebaseAuth.instance.currentUser!.uid,
          'OPENAI_API_KEY': dotenv.env['GPT_API_KEY'].toString(),
          'push': true,
        },
        ...keyValue // 호출 시 명시한 keyValue
      };
      print(request);
      final response = await callable.call(request);
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

  // functions 호출용 테스트 함수
  Future<String> testFunction(functionName, keyValue) async {
    try {
      if (useEmul)
        _functionsForProd.useFunctionsEmulator('localhost', 5001); // 에뮬 사용
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
