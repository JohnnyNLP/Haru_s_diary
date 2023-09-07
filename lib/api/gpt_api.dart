import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GptApiClass {
  // 필드, 생성자, 메서드 등

  // 싱글턴 패턴을 사용하여 하나의 인스턴스만 생성되게 할 수 있습니다.
  static final GptApiClass _singleton = GptApiClass._internal();

  factory GptApiClass() {
    return _singleton;
  }

  GptApiClass._internal();

  Future<String> sendMessage(messages) async {
    final _apiKey = dotenv.env['GPT_API_KEY'].toString();
    final _model = 'gpt-3.5-turbo';
    final _max_tokens = 1000;
    final initMessage = [
      {
        'role': 'system',
        // 'content': '너는 나의 오늘 하루 있었던 일을 궁금해 해. 공감과 위로 칭찬 위주로 반말로 한마디로 대답해줘.'
        'content':
            'Your name is "오하루". You are a friend who gives sympathy and comforting compliments without formality.'
      },
    ];
    final send = initMessage + messages;
    print(send);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    final body = jsonEncode({
      'model': _model,
      'messages': send,
      'max_tokens': _max_tokens,
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      print(data);
      return data['choices'][0]['message']['content'];
    } else {
      return 'Error: ${response.body}';
    }
  }

  Future<String> makeDiary(messages) async {
    final _apiKey = dotenv.env['GPT_API_KEY'].toString();
    final _model = 'gpt-4';
    final _max_tokens = 1000;
    final initMessage = [
      {
        'role': 'system',
        'content':
            "You are user's secretary who is good at summarizing a conversation and writing a diary.\nYou will be given a conversation history between 'user' and 'assistant.'\nWhen answering, focus on the user's sentence, not on assistant's.\nWhen answering, pick up 3 subtitles for each entry.\nWhen answering, write everything in Korean.\nThe output should be formed like the following example:\n\n[일의 압박감]\n오늘은 회사에서 일이 너무 많았다.\n마감 기한 때문에 스트레스를 많이 받고 있다.\n효율적으로 일을 접근하고, 조금씩 휴식을 취해야겠다.\n\n[스트레스 해소 방법]\n담배와 커피로 스트레스를 푼다.\n담배 대신 다른 방법을 찾아봐야겠다.\n저녁에는 운동을 가야겠다.\n\n[음악으로 하루를 마무리]\n잔잔한 음악을 들으며 하루를 마무리해야겠다."
      },
    ];
    final send = initMessage + messages;
    print(send);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    final body = jsonEncode({
      'model': _model,
      'messages': send,
      'max_tokens': _max_tokens,
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      print(data);
      return data['choices'][0]['message']['content'];
    } else {
      return 'Error: ${response.body}';
    }
  }

  int calculateSomething(int a, int b) {
    // 계산 로직
    return a + b;
  }
}
