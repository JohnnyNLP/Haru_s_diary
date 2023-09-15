import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haru_diary/api/functions.dart';
import 'package:provider/provider.dart';
import '../provider/common_provider.dart';

class NewMessage extends StatefulWidget {
  const NewMessage(this.collectionPath, this.userChatStream, this.date,
      {super.key});

  final String collectionPath;
  final Stream<QuerySnapshot<Map<String, dynamic>>> userChatStream;
  final String date;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _userEnterMessage = '';
  late final chatModel;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      // 여기에서 비동기 작업을 수행
      final conv = await getConversation();
      if (conv.length == 0) {
        _gptMessage('안녕');
      }
    });
    chatModel = Provider.of<CommonProvider>(context, listen: false);
  }

  Future<List<Map<String, String>>> getConversation() async {
    final conversation = <Map<String, String>>[];
    final QuerySnapshot<Map<String, dynamic>> firstSnapshot =
        await widget.userChatStream.first;
    for (QueryDocumentSnapshot doc in firstSnapshot.docs
        .sublist(0, min(10, firstSnapshot.docs.length))
        .reversed) {
      conversation.add({
        'role': doc['userID'] == 'gpt-3.5-turbo' ? 'assistant' : 'user',
        'content': '${doc['text']}'
      });
    }
    return conversation;
  }

  void _gptMessage(msg) async {
    _setFakeChat(isLoading: true);

    await func.callFunctions('ChatAI', {
      'prompt': msg,
      'date': widget.date,
      'chat_template': Provider.of<CommonProvider>(context, listen: false)
          .prefs!
          .getString('chatTemplate'),
      'informal_template': Provider.of<CommonProvider>(context, listen: false)
          .prefs!
          .getString('imformalTemplate'),
    });

    _setFakeChat(isLoading: false);
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection(widget.collectionPath).add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'userID': user.uid,
      'userName': userData.data()!['userName'],
      'userImage': userData['picked_image'],
    });
    _controller.clear();
    _gptMessage(_userEnterMessage);
  }

  void _setFakeChat({isLoading}) {
    if (isLoading == null) {
      isLoading = false;
    }
    Map<String, dynamic> fakeChatMap = {
      'userName': '오하루',
      'text': '(입력중..)',
      'userID': '가상의UserID',
      // 'userImage': '가상의UserImageURL'
    };
    if (isLoading) {
      chatModel.addFakeMessage(fakeChatMap); // 가상 메시지 추가
    } else {
      chatModel.removeFakeMessage(); // 가상 메시지 제거
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0x2957636C),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.fromLTRB(0, 12, 0, 12),
      padding: EdgeInsets.fromLTRB(16, 0, 0, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                hintText: '메세지 보내기',
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
            // color: Color(0xFFEE8B60),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
