import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/chat/chat_list.dart';
import 'package:haru_diary/screens/chat_screen.dart';
// import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../custom/custom_app_bar.dart';
import '../custom/custom_top_container.dart';
import '/custom/custom_theme.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? _collectionPath;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _docStream;

  Set<String> selectedIds = Set<String>();
  bool showCheckbox = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCollectionPath();
    getDocStream();
  }

  void deleteBtnClick() {
    if (selectedIds.length == 0) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('확인'),
          content: Text('${selectedIds.length}개의 대화가 선택되었습니다.\n정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('예'),
              onPressed: () {
                deleteSelectedIds();
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  void deleteSelectedIds() async {
    for (String id in selectedIds) {
      await FirebaseFirestore.instance
          .collection(_collectionPath!)
          .doc(id)
          .delete();
    }

    setState(() {
      selectedIds.clear();
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

  void getCollectionPath() {
    _collectionPath = '/user/${loggedUser!.uid}/chat';
  }

  void getDocStream() {
    DateTime now = DateTime.now();
    // DateTime lastDay = now.subtract(Duration(days: now.weekday));
    DateTime lastDay = now.subtract(Duration(days: 1));
    String formattedDate = DateFormat('yyyyMMdd').format(lastDay);
    formattedDate = '20230101'; // 테스트 위해 하드코딩
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance
            .collection(_collectionPath!)
            .where('date', isGreaterThan: formattedDate)
            .orderBy('date', descending: true)
            .orderBy('lastTime', descending: true)
            .snapshots();
    _docStream = chatStream;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: '오늘의 대화'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.all(16.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTopContainer(
                    sBtns: [
                      // {
                      //   'icon': Icons.chevron_left_outlined,
                      //   'onPressed': () {
                      //     Navigator.of(context).pop();
                      //   },
                      // },
                    ],
                    eBtns: [
                      {
                        'icon': showCheckbox ? Icons.delete_sweep : null,
                        'onPressed': deleteBtnClick,
                      },
                      {
                        'icon': showCheckbox
                            ? Icons.playlist_add_check_circle
                            : Icons.playlist_add_check_circle_outlined,
                        'onPressed': () {
                          setState(() {
                            selectedIds.clear();
                            showCheckbox = !showCheckbox;
                          });
                        },
                      },
                    ],
                  ),
                  Divider(
                    thickness: 2,
                    color: CustomTheme.of(context).alternate,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 8.h, 0, 0),
                    child: Container(
                      width: 338.w,
                      height: 590.h,
                      decoration: BoxDecoration(
                        color: CustomTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16.h),
                        child: Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: CustomTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ChatList(
                                    _docStream!, selectedIds, showCheckbox),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChatScreen()));
                                  },
                                  icon: Icon(Icons.add_circle_outline,
                                      color: CustomTheme.of(context).tertiary,
                                      size: 30.0.h))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
