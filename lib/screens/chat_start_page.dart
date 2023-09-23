import 'package:flutter/material.dart';
import 'chat_screen.dart';  // ChatScreen()이 정의된 파일의 경로를 여기에 입력하세요.
import 'navi.dart';

class StartChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
        child: Center(
          child: Text(
            '새로운 대화 시작하기',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  // 원하는 스타일로 조절 가능
          ),
        ),
      ),
    );
  }
}