import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haru_diary/screens/diary_screen.dart';
import '../chat/message.dart';
import '../custom/custom_app_bar.dart';
import '../custom/custom_theme.dart';
import '../custom/custom_top_container.dart';
import '/chat/new_message.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? collectionPath;
  Stream<QuerySnapshot<Map<String, dynamic>>>? userChatStream;
  List<Map<String, String>>? conversation;
  String? _date;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setCollectionPath();
    setChatStream();
    getConversation();
    // Provider.of<ProgressProvider>(context, listen: false).setProgress(false);
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void setChatStream() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance
            .collection(collectionPath!)
            .orderBy('time', descending: true)
            .snapshots();
    userChatStream = chatStream;
  }

  void setCollectionPath() {
    _date = DateFormat('yyyyMMdd').format(DateTime.now());
    collectionPath = '/user/${loggedUser!.uid}/chat/${_date}/conversation';
  }

  void getConversation() async {
    try {
      conversation = <Map<String, String>>[];
      final QuerySnapshot<Map<String, dynamic>> firstSnapshot =
          await userChatStream!.first;
      for (QueryDocumentSnapshot doc in firstSnapshot.docs
          .sublist(0, min(100, firstSnapshot.docs.length))
          .reversed) {
        conversation!.add({
          'role': doc['userID'] == 'gpt-3.5-turbo' ? 'assistant' : 'user',
          'content': '${doc['text']}'
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(text: '하루의 대화방'),
        body: ModalProgressHUD(
          inAsyncCall:
              false, //Provider.of<ProgressProvider>(context).isProgress!,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTopContainer(
                  sText: 'Back',
                  sIcon: Icons.chevron_left_outlined,
                  sOnPressed: () {
                    Navigator.pop(context);
                  },
                  eText: '일기쓰기',
                  eIcon: Icons.create_outlined,
                  eOnPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DiaryScreen(_date!, conversation!)));
                  },
                ),
                Divider(
                  thickness: 2,
                  color: CustomTheme.of(context).alternate,
                ),
                Expanded(
                  child: Container(
                      margin: EdgeInsets.only(top: 6),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0E3E3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Messages(collectionPath!, userChatStream!)),
                ),
                NewMessage(collectionPath!, userChatStream!),
              ],
            ),
          ),
        ));
  }
}
