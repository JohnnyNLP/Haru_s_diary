import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haru_diary/diary/weekly_list.dart';

import '../custom/custom_app_bar.dart';
import '../custom/custom_top_container.dart';
import '/custom/custom_icon_button.dart';
import '/custom/custom_theme.dart';
import 'package:flutter/material.dart';

class WeeklyDiaryScreen extends StatefulWidget {
  const WeeklyDiaryScreen({Key? key}) : super(key: key);

  @override
  _WeeklyDiaryScreenState createState() => _WeeklyDiaryScreenState();
}

class _WeeklyDiaryScreenState extends State<WeeklyDiaryScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? _collectionPath;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _docStream;

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
    _collectionPath = '/user/${loggedUser!.uid}/diary';
  }

  void getDocStream() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance
            .collection(_collectionPath!)
            .orderBy(FieldPath.documentId, descending: false)
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
          appBar: CustomAppBar(text: 'Weekly'),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: EdgeInsetsDirectional.all(16),
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
                    ),
                    Divider(
                      thickness: 2,
                      color: CustomTheme.of(context).alternate,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                      child: Container(
                        width: 338,
                        height: 582,
                        decoration: BoxDecoration(
                          color: CustomTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: CustomTheme.of(context).primaryBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Expanded(
                              child: WeeklyList(_docStream!),
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
