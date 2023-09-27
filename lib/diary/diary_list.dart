import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/diary/bookmark.dart';

class DiaryList extends StatefulWidget {
  const DiaryList(this._userDiaryStream, this.selectedIds, this.showCheckbox,
      {super.key});

  final _userDiaryStream;
  final Set<String> selectedIds;
  final bool showCheckbox;

  @override
  State<DiaryList> createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList> {
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
        return ListView.builder(
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            DateTime dateTime = DateTime.parse(chatDocs[index]['date']);
            String dateForm =
                '${weekDay[dateTime.weekday]} (${dateTime.year}. ${dateTime.month}. ${dateTime.day})';
            final doc = chatDocs[index];
            return ListTile(
              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              horizontalTitleGap: 0,
              title: Bookmarks(
                doc.id,
                chatDocs[index]['date'],
                dateForm,
                doc.data().containsKey('title') ? doc['title'] : '무제',
                doc.data().containsKey('content') ? doc['content'] : '',
              ),
              leading: widget.showCheckbox
                  ? Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Checkbox(
                        value: widget.selectedIds.contains(doc.id),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              widget.selectedIds.add(doc.id);
                            } else {
                              widget.selectedIds.remove(doc.id);
                            }
                          });
                        },
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
