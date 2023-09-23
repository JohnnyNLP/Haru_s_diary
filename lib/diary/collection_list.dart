import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haru_diary/diary/bookmark.dart';

class CollectionList extends StatefulWidget {
  final _userDiaryStream;
  final Function(List<bool>, List<DocumentSnapshot>) onSelectedItems;

  CollectionList(this._userDiaryStream, {required this.onSelectedItems, Key? key}) : super(key: key);

  @override
  _CollectionListState createState() => _CollectionListState();
}

class _CollectionListState extends State<CollectionList> {
  List<bool> isChecked = [];

  @override
  Widget build(BuildContext context) {
    final weekDay = ['', '월', '화', '수', '목', '금', '토', '일'];
    return StreamBuilder(
      stream: widget._userDiaryStream,
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final chatDocs = snapshot.data!.docs;
        if (isChecked.isEmpty && chatDocs.isNotEmpty) {
          isChecked = List.filled(chatDocs.length, false);
        }

        return ListView.builder(
          reverse: false,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final doc = chatDocs[index];
            DateTime dateTime = DateTime.parse(doc.id);
            String dateForm =
                '${weekDay[dateTime.weekday]} (${dateTime.year}. ${dateTime.month}. ${dateTime.day})';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),  // 여기는 원하는 대로 조절하세요
          child: Row(
            children: [
              // 체크박스
              Checkbox(
                value: isChecked[index],
                onChanged: (bool? value) {
                  setState(() {
                    isChecked[index] = value!;
                  });
                  widget.onSelectedItems(isChecked, chatDocs);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 이 부분을 추가
              ),

              // 체크박스와 Bookmarks 사이의 간격 (원하는 만큼 조절하세요)
              SizedBox(width: 5.0), 

              // Bookmarks 위젯
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isChecked[index] = !isChecked[index];
                    });
                    widget.onSelectedItems(isChecked, chatDocs);
                  },
                   child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),  // 원하는 패딩 값을 설정
                    child: Bookmarks(
                      doc.id,
                      dateForm,
                      doc.data().containsKey('title') ? doc['title'] : '무제',
                      doc.data().containsKey('content') ? doc['content'] : '',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }
}