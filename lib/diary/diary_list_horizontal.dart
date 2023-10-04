import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/diary/bookmark.dart';

class DiaryListHorizontal extends StatefulWidget {
  const DiaryListHorizontal(this._userDiaryStream, {super.key});

  final _userDiaryStream;

  @override
  State<DiaryListHorizontal> createState() => _DiaryListHorizontalState();
}

class _DiaryListHorizontalState extends State<DiaryListHorizontal> {
  late ScrollController _scrollController;
  final double itemExtent = 300; // 원하는 타일의 너비를 설정 (예: 300)
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        var offset = _scrollController.offset;
        var maxScroll = _scrollController.position.maxScrollExtent;
        var factor = maxScroll / (5 - 1);
        var currentPage = (offset / factor).round();
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _scrollController.animateTo(
            currentPage * factor,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          _scrollController.animateTo(
            currentPage * factor,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final weekDay = ['', '월', '화', '수', '목', '금', '토', '일'];
    return StreamBuilder(
      stream: widget._userDiaryStream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;
        return PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: PageController(
            viewportFraction: 0.9,
          ),
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            DateTime dateTime = DateTime.parse(chatDocs[index]['date']);
            // String dateForm =
            //     '${weekDay[dateTime.weekday]} (${dateTime.year}. ${dateTime.month}. ${dateTime.day})';
            String dateForm =
                '${weekDay[dateTime.weekday]} (${dateTime.month}. ${dateTime.day})';
            final doc = chatDocs[index];

            // 페이지의 시작과 끝에만 패딩을 적용합니다.
            bool isFirst = index == 0;
            bool isLast = index == chatDocs.length - 1;

            return Padding(
              // 조건부 패딩 적용
              padding: EdgeInsets.only(
                left: isFirst ? 0 : 5.w,
                right: isLast ? 0 : 5.w,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                horizontalTitleGap: 0,
                title: Bookmarks(
                  doc.id,
                  chatDocs[index]['date'],
                  dateForm,
                  doc.data().containsKey('title') ? doc['title'] : '무제',
                  doc.data().containsKey('content') ? doc['content'] : '',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
