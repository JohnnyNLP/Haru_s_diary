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

            return CheckboxListTile(
              value: isChecked[index],
              onChanged: (bool? value) {
                setState(() {
                  isChecked[index] = value!;
                });
                widget.onSelectedItems(isChecked, chatDocs);
              },
              title: Bookmarks(
                doc.id,
                dateForm,
                doc.data().containsKey('title') ? doc['title'] : '무제',
                doc.data().containsKey('content') ? doc['content'] : '',
              ),
            );
          },
        );
      },
    );
  }
}