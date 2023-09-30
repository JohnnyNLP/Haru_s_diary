import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/screens/diary_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../chat/message.dart';
import '../custom/custom_app_bar.dart';
import '../custom/custom_theme.dart';
import '../custom/custom_top_container.dart';
import '../provider/common_provider.dart';
import '/chat/new_message.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({this.docId, this.date, super.key});
  final String? docId;
  final String? date;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedUser;
  String? collectionPath;
  Stream<QuerySnapshot<Map<String, dynamic>>>? userChatStream;
  String? docId;
  String? date;
  bool? readOnly;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    Future.delayed(Duration.zero, () async {
      await setCollectionPath();
      setState(setChatStream);
    });
  }

  void checkDocumentExistence(String path) async {
    DocumentReference documentReference = _firestore.doc(path);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    setState(() {
      readOnly = documentSnapshot.exists;
    });
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
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream = _firestore
        .collection(collectionPath!)
        .orderBy('time', descending: true)
        .snapshots();
    userChatStream = chatStream;
  }

  Future setCollectionPath() async {
    docId = widget.docId;
    date = widget.date;
    if (docId == null) {
      date = DateFormat('yyyyMMdd').format(DateTime.now());
      await _firestore.collection('/user/${loggedUser!.uid}/chat').add({
        'date': date,
      }).then((DocumentReference document) {
        docId = document.id;
      });
    }
    collectionPath = '/user/${loggedUser!.uid}/chat/${docId}/conversation';
    checkDocumentExistence('/user/${loggedUser!.uid}/diary/${docId}');
  }

  @override
  Widget build(BuildContext context) {
    if (userChatStream == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      Provider.of<CommonProvider>(context, listen: false).setUserPrefs();
      return Scaffold(
          appBar: CustomAppBar(text: '오하루'),
          body: ModalProgressHUD(
            inAsyncCall:
                false, // Provider.of<CommonProvider>(context).isProgress!,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTopContainer(
                    // sText: 'Back',
                    sIcon: Icons.chevron_left_outlined,
                    sOnPressed: () {
                      Navigator.pop(context);
                    },
                    eText: readOnly == false ? '하루의 일기쓰기' : '일기 읽어보기',
                    eIcon: readOnly == false
                        ? Icons.create_outlined
                        : Icons.chrome_reader_mode_rounded,
                    eOnPressed: () async {
                      var conv =
                          await _firestore.collection(collectionPath!).get();
                      var len = conv.docs.length;
                      if (len < 5) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('알림'),
                              content: Text(
                                  '대화가 충분히 이루어지면, 하루가 대신 일기를 작성해줍니다.\n대화를 조금만 더 진행해주세요.\n\n하루와 한 대화: ${len}마디'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('확인'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                DiaryScreen(widget.docId!, date!)));
                      }
                    },
                  ),
                  Divider(
                    thickness: 2,
                    color: CustomTheme.of(context).alternate,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 0),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(128, 217, 149, 81),
                        // borderRadius: BorderRadius.circular(15),
                      ),
                      child: Messages(collectionPath!, userChatStream!),
                      // child: null,
                    ),
                  ),
                  readOnly == true
                      ? SizedBox(height: 7.h)
                      : NewMessage(collectionPath!, userChatStream!, docId!),
                ],
              ),
            ),
          ));
    }
  }
}
