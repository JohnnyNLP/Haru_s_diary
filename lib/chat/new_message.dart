import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/api/functions.dart';
import 'package:provider/provider.dart';
import '../provider/common_provider.dart';

class NewMessage extends StatefulWidget {
  const NewMessage(this.collectionPath, this.userChatStream, this.docId,
      {super.key});

  final String collectionPath;
  final Stream<QuerySnapshot<Map<String, dynamic>>> userChatStream;
  final String docId;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _userEnterMessage = '';
  late final chatModel;
  final user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot<Map<String, dynamic>>? userData;
  bool isWaitting = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      // 여기에서 비동기 작업을 수행
      final conv = await getConv();
      userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(user!.uid)
          .get();
      if (conv.length == 0) {
        setState(() {
          isWaitting = true;
          print('isWaitting: ${isWaitting}');
        });
        await _gptMessage('안녕');
        setState(() {
          isWaitting = false;
          print('isWaitting: ${isWaitting}');
        });
      }
    });
    chatModel = Provider.of<CommonProvider>(context, listen: false);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getConv() async {
    final QuerySnapshot<Map<String, dynamic>> firstSnapshot =
        await widget.userChatStream.first;
    return firstSnapshot.docs;
  }

  Future<void> _gptMessage(msg) async {
    _setFakeChat(isLoading: true);

    await func.callFunctions('ChatAI', {
      'prompt': msg,
      'docId': widget.docId,
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
    setState(() {
      isWaitting = true;
      print('isWaitting: ${isWaitting}');
    });

    var message = _userEnterMessage;
    FocusScope.of(context).unfocus();
    _controller.clear();
    _userEnterMessage = '';

    Timestamp now = Timestamp.now();
    FirebaseFirestore.instance.collection(widget.collectionPath).add({
      'text': message,
      'time': now,
      'userID': user!.uid,
      'userName': userData!['userName'],
      'userImage': userData!['picked_image'],
    });

    FirebaseFirestore.instance
        .doc(widget.collectionPath.replaceAll('/conversation', ''))
        .set(
      {
        'lastTime': now,
      },
      SetOptions(merge: true),
    );

    await _gptMessage(message);

    setState(() {
      isWaitting = false;
      print('isWaitting: ${isWaitting}');
    });
  }

  void _setFakeChat({isLoading}) {
    if (isLoading != null && isLoading == true) {
      Map<String, dynamic> fakeChatMap = {
        'userName': '오하루',
        'text': '(입력중..)',
        'userID': '가상의UserID',
        'userImage': // 테스트 위해 하드코딩
            'https://firebasestorage.googleapis.com/v0/b/haru-s-diary.appspot.com/o/picked_image%2Fgpt-3.5-turbo.png?alt=media&token=684e0b0e-3bc0-41c9-b6e1-412a7b02d1ed',
      };
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
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: !isWaitting,
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                hintText: isWaitting ? '대기중..' : '메세지 보내기',
                contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            constraints: BoxConstraints.tightFor(width: 30.0, height: 30.0),
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
