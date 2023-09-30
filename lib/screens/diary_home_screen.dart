import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/diary/calendar.dart';
import 'package:haru_diary/diary/sentiment_chart.dart';
import 'package:haru_diary/custom/custom_app_bar.dart';
import 'package:haru_diary/diary/diary_list_horizontal.dart';
import 'package:haru_diary/screens/diary_list_screen.dart';
import 'package:intl/intl.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? _collectionPath;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _docStream;

  final valueNotifier = ValueNotifier<int>(0);

  final sentimentNavi = GlobalKey<NavigatorState>();

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
    DateTime now = DateTime.now();
    DateTime lastSunday = now.subtract(Duration(days: now.weekday));
    print(lastSunday);
    String formattedDate = DateFormat('yyyyMMdd').format(lastSunday);
    formattedDate = '20230101'; // 테스트 위해 하드코딩
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance
            .collection(_collectionPath!)
            .where('date', isGreaterThan: formattedDate)
            .orderBy('date', descending: true)
            .snapshots();
    _docStream = chatStream;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
    );
  }

  Widget _buildDiaryList() {
    return Container(
      height: 80.h,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Expanded(child: DiaryListHorizontal(_docStream)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: 'Diary'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.all(16.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('이번 주 일기'),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DiaryListScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.list_alt_rounded))
                    ],
                  ),
                  _buildDiaryList(),
                  SizedBox(height: 24.0),
                  _buildSectionHeader('캘린더'),
                  Calendar(_collectionPath),
                  SizedBox(height: 24.0),
                  _buildSectionHeader('감정분석'),
                  SizedBox(height: 16.0),
                  // _buildListItem(large: true, round: true),
                  SentimentChart(sentimentNavi),
                  // Builder(
                  //   builder: (context) => ValueListenableBuilder<int>(
                  //     valueListenable: valueNotifier,
                  //     builder:
                  //         (BuildContext context, int value, Widget? child) {
                  //       // 이 빌더는 valueNotifier의 값이 변경될 때만 호출됩니다.
                  //       return _buildSentiment();
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
