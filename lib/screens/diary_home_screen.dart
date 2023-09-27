import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/custom/custom_app_bar.dart';
import 'package:haru_diary/diary/diary_list_horizontal.dart';
import 'package:haru_diary/screens/diary_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {
    // DateTime.utc(2023, 9, 7): ['Event 1'],
    // DateTime.utc(2023, 9, 8): ['Event 2'],
    // DateTime.utc(2023, 9, 11): ['Event 3'],
    // DateTime.utc(2023, 9, 27): ['Event 3'],
  };

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

  Widget _buildListItem({bool large = false, bool round = false}) {
    return Container(
      height: large ? 100.0 : 50.0,
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            round ? BorderRadius.circular(50.0) : BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.ac_unit, color: Colors.grey), // Placeholder icon
          SizedBox(width: 16.0),
          Text('Placeholder', style: TextStyle(color: Colors.grey)),
        ],
      ),
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

  Future getMonthEvent(focusedDay) async {
    // 해당 월의 첫번째 날
    DateTime firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);

    // 해당 월의 마지막 날
    DateTime lastDayOfMonth = (focusedDay.month < 12)
        ? DateTime(focusedDay.year, focusedDay.month + 1, 0)
        : DateTime(focusedDay.year + 1, 1, 0).subtract(Duration(days: 1));

    String formattedStartDate = DateFormat('yyyyMMdd').format(firstDayOfMonth);
    String formattedEndDate = DateFormat('yyyyMMdd').format(lastDayOfMonth);

    final snapshot = await FirebaseFirestore.instance
        .collection(_collectionPath!)
        .where('date', isGreaterThanOrEqualTo: formattedStartDate)
        .where('date', isLessThanOrEqualTo: formattedEndDate)
        .get();

    for (var doc in snapshot.docs) {
      _events[DateTime.utc(
          int.parse(doc['date'].substring(0, 4)),
          int.parse(doc['date'].substring(4, 6)),
          int.parse(doc['date'].substring(6, 8)))] = ['event'];
    }
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
                  Container(
                      child: Column(
                    children: [
                      TableCalendar(
                        onCalendarCreated: (pageController) async {
                          await getMonthEvent(DateTime.now());
                          setState(() {});
                        },
                        availableGestures: AvailableGestures
                            .horizontalSwipe, // 횡스크롤만 가능하도록 하여 부모의 종스크롤은 유지
                        rowHeight: 40.h,
                        availableCalendarFormats: {
                          CalendarFormat.month: 'Month',
                        },
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          if (_events.containsKey(selectedDay)) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DiaryListScreen(
                                    date: DateFormat('yyyyMMdd')
                                        .format(selectedDay)),
                              ),
                            );
                          }
                        },
                        onPageChanged: (focusedDay) async {
                          await getMonthEvent(focusedDay);
                          _focusedDay = focusedDay;
                          setState(() {});
                        },
                        eventLoader: (day) {
                          return _events[day] ?? [];
                        },
                        calendarStyle: CalendarStyle(
                          markerDecoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  )),
                  // SizedBox(height: 16.0),
                  // _buildListItem(large: true),
                  // _buildListItem(large: true),
                  SizedBox(height: 24.0),
                  _buildSectionHeader('감정분석'),
                  SizedBox(height: 16.0),
                  _buildListItem(large: true, round: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
