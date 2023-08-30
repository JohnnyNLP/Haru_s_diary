import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:haru_diary/provider/progress_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _userEnterMessage = '';
  final _apiKey = dotenv.env['GPT_API_KEY'].toString();

  final conversation = [
    {'role': 'system', 'content': '한국어로 짧게 대답해.'},
  ];

  void _gptMessage() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    conversation.add({'role': 'user', 'content': _userEnterMessage});
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo', // 사용하려는 모델을 명시하세요.
      'messages': conversation,
      'max_tokens': 150,
    });

    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.setProgress(true); //  todo: 왜 두 줄로 뜨지.... 해결 필요

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      final message = data['choices'][0]['message']['content'];
      FirebaseFirestore.instance.collection('chat').add({
        'text': message,
        'time': Timestamp.now(),
        'userID': 'gpt-3.5-turbo',
      });
      conversation.add({'role': 'assistant', 'content': message});

      print(conversation);
    } else {
      print('Error: ${response.body}');
    }

    progressProvider.setProgress(false);
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'userID': user.uid,
      'userName': userData.data()!['userName'],
    });
    _controller.clear();
    _gptMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Expanded(
          child: TextField(
            maxLines: null,
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Send a message...',
            ),
            onChanged: (value) {
              setState(() {
                _userEnterMessage = value;
              });
            },
          ),
        ),
        IconButton(
          onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
          icon: Icon(Icons.send),
          color: Colors.blue,
        ),
      ]),
    );
  }
}
