import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haru_diary/diary/bookmark.dart';

class WeeklyList extends StatelessWidget {
  const WeeklyList(this._userDiaryStream, {super.key});

  final _userDiaryStream;

  @override
  Widget build(BuildContext context) {
    final weekDay = ['', '월', '화', '수', '목', '금', '토', '일'];
    return StreamBuilder(
      stream: _userDiaryStream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;
        return ListView.builder(
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            // DateTime dateTime = (chatDocs[index]['time'] as Timestamp).toDate();
            DateTime dateTime = DateTime.parse(chatDocs[index].id);
            String dateForm =
                '${weekDay[dateTime.weekday]} (${dateTime.year}. ${dateTime.month}. ${dateTime.day})';
            final doc = chatDocs[index];
            return Bookmarks(
              doc.id,
              dateForm,
              doc.data().containsKey('title') ? doc['title'] : '무제',
              doc.data().containsKey('content') ? doc['content'] : '',
            );
          },
        );
      },
    );
  }
}