import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '/provider/progress_provider.dart';
import '/chat/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatelessWidget {
  const Messages(this.collectionPath, this.userChatStream, {super.key});

  final String collectionPath;
  final userChatStream;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final chatModel = Provider.of<ProgressProvider>(context);

    return StreamBuilder(
      stream: userChatStream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // final chatDocs = snapshot.data!.docs;
        List<Map<String, dynamic>> chatDocs =
            snapshot.data!.docs.map((doc) => doc.data()).toList();

        chatDocs.insertAll(0, chatModel.chatDocs);

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            return ChatBubbles(
              chatDocs[index]['text'],
              (chatDocs[index].containsKey('userID')
                      ? chatDocs[index]['userID'].toString()
                      : '') ==
                  user!.uid,
              (chatDocs[index].containsKey('userName')
                  ? chatDocs[index]['userName'].toString()
                  : '낯선이'),
              (chatDocs[index].containsKey('userImage')
                  ? chatDocs[index]['userImage'].toString()
                  : ''),
              key: ValueKey(index),
            );
          },
        );
      },
    );
  }
}
