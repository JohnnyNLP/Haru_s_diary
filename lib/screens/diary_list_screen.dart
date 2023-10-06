import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/diary/diary_list.dart';
import 'package:intl/intl.dart';

import '../custom/custom_app_bar.dart';
import '../custom/custom_top_container.dart';
import '/custom/custom_theme.dart';
import 'package:flutter/material.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({this.date, Key? key}) : super(key: key);

  final String? date;

  @override
  DiaryListScreenState createState() => DiaryListScreenState();
}

class DiaryListScreenState extends State<DiaryListScreen> {
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
          content: Text('${selectedIds.length}개의 일기가 선택되었습니다.\n정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                deleteSelectedIds();
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
    _collectionPath = '/user/${loggedUser!.uid}/diary';
  }

  void getDocStream() {
    // print('aaaaa${widget.date}');
    DateTime now = DateTime.now();
    DateTime lastSunday = now.subtract(Duration(days: now.weekday));
    String formattedDate = DateFormat('yyyyMMdd').format(lastSunday);
    // formattedDate = '20230101'; // 테스트 위해 하드코딩
    final Stream<QuerySnapshot<Map<String, dynamic>>> diaryStream;
    if (widget.date == null) {
      diaryStream = FirebaseFirestore.instance
          .collection(_collectionPath!)
          .where('date', isGreaterThan: formattedDate)
          .orderBy('date', descending: true)
          .snapshots();
    } else {
      diaryStream = FirebaseFirestore.instance
          .collection(_collectionPath!)
          .where('date', isEqualTo: widget.date)
          .snapshots();
    }
    _docStream = diaryStream;
  }

  @override
  Widget build(BuildContext context) {
    String? dateForm;
    if (widget.date != null) {
      final weekDay = ['', '월', '화', '수', '목', '금', '토', '일'];
      var dateTime = DateTime.parse(widget.date!);
      dateForm =
          '${weekDay[dateTime.weekday]} (${dateTime.year}. ${dateTime.month}. ${dateTime.day})';
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: dateForm ?? 'Diary'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 16.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTopContainer(
                    sBtns: [
                      {
                        'icon': Icons.chevron_left_outlined,
                        'onPressed': () {
                          Navigator.of(context).pop();
                        },
                      },
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
                      height: 582.h,
                      decoration: BoxDecoration(
                        color: CustomTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24.h),
                        child: Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: CustomTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: DiaryList(
                                    _docStream!, selectedIds, showCheckbox),
                                // child: DiaryListHorizontal(_docStream!),
                              ),
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
