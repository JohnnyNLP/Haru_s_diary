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

  final calendarKey = GlobalKey<CalendarState>();
  final sentimentNavi = GlobalKey<NavigatorState>();
  final sentimentKey = GlobalKey<SentimentChartState>();

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
    // formattedDate = '20230101'; // 테스트 위해 하드코딩
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
      height: 90.h,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 5.h),
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
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 16.h),
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
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DiaryListScreen(),
                              ),
                            );
                            calendarKey.currentState?.getMonthEvent();
                            sentimentKey.currentState?.getSentiment();
                          },
                          icon: Icon(Icons.list_alt_rounded))
                    ],
                  ),
                  _buildDiaryList(),
                  SizedBox(height: 24.0.h),
                  _buildSectionHeader('캘린더'),
                  Calendar(key: calendarKey, collectionPath: _collectionPath),
                  SizedBox(height: 20.0.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '감정분석',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0.sp),
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      Tooltip(
                        message:
                            '사용자의 대화를 기반으로 최대 8가지\n카테고리로 감정 분석을 진행합니다.\n\n8가지 감정은 다음과 같습니다:\n기쁨, 기대, 열정, 애정, 슬픔, 분노, 우울, 불쾌',
                        child: Icon(Icons.info_outline, size: 20.w),
                      ),
                    ],
                  ),
                  SentimentChart(
                      key: sentimentKey, navigatorKey: sentimentNavi),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
