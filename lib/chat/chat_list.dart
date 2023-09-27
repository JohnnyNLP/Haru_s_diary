import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/chat/chat_room.dart';
import 'package:intl/intl.dart';

class ChatList extends StatefulWidget {
  const ChatList(this._userChatStream, this.selectedIds, this.showCheckbox,
      {super.key});

  final _userChatStream;
  final Set<String> selectedIds;
  final bool showCheckbox;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget._userChatStream,
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
            final doc = chatDocs[index];
            var date = doc.data()['date'];
            return FutureBuilder<DocumentSnapshot>(
              future: doc.reference
                  .collection('conversation')
                  .orderBy('time', descending: true)
                  .limit(1)
                  .get()
                  .then((querySnapshot) => querySnapshot.docs.first),
              builder: (context, futureSnapshot) {
                final Map<String, dynamic>? data =
                    futureSnapshot.data?.data() as Map<String, dynamic>?;
                final String text =
                    (data?.containsKey('text') ?? false) ? data!['text'] : '';
                final String time = (data?.containsKey('time') ?? false)
                    // ? DateFormat('a h:mm', 'ko_KR')
                    ? DateFormat('a h:mm')
                        .format((data!['time'] as Timestamp).toDate())
                    : '';
                return ListTile(
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  horizontalTitleGap: 0,
                  title: ChatRoom(
                      doc.id, futureSnapshot.hasData ? time : '', text, date),
                  leading: widget.showCheckbox
                      ? Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Checkbox(
                            value: widget.selectedIds.contains(doc.id),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
      },
    );
  }
}
