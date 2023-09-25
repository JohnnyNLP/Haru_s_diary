import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/chat/chat_list.dart';
import 'package:haru_diary/screens/chat_screen.dart';
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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCollectionPath();
    getDocStream();
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
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance
            .collection(_collectionPath!)
            // .orderBy(FieldPath.documentId, descending: true)
            .where('date', isGreaterThan: formattedDate)
            .snapshots();
    _docStream = chatStream;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0xFFFAFAFA),
          appBar: CustomAppBar(text: '대화목록'),
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
                      sIcon: Icons.chevron_left_outlined,
                      sText: 'Back',
                      sOnPressed: () {
                        Navigator.pop(context);
                      },
                      eText: '삭제하기',
                      eIcon: Icons.delete_sweep,
                      eOnPressed: () async {
                        for (String id in selectedIds) {
                          await FirebaseFirestore.instance
                              .collection(_collectionPath!)
                              .doc(id)
                              .delete();
                        }

                        setState(() {
                          selectedIds.clear();
                        });
                      },
                    ),
                    Divider(
                      thickness: 2,
                      color: CustomTheme.of(context).alternate,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8.h, 0, 0),
                      child: Container(
                        width: 338.w,
                        height: 550.h,
                        decoration: BoxDecoration(
                          color: CustomTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24.h),
                          child: Container(
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: CustomTheme.of(context).primaryBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ChatList(_docStream!, selectedIds),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatScreen()));
                                    },
                                    icon: Icon(Icons.add_circle,size: 30.0))
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
      ),
    );
  }
}
