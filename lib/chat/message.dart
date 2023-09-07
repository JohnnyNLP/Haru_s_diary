import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/chat/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatelessWidget {
  const Messages(this.collectionPath, this.userChatStream, {super.key});

  final String collectionPath;
  final userChatStream;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: userChatStream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            // child: null,
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            return ChatBubbles(
                chatDocs[index]['text'],
                (chatDocs[index].data().toString().contains('userID')
                        ? chatDocs[index]['userID'].toString()
                        : '') ==
                    user!.uid,
                (chatDocs[index].data().toString().contains('userName')
                    ? chatDocs[index]['userName'].toString()
                    : '낯선이'),
                (chatDocs[index].data().toString().contains('userImage')
                    ? chatDocs[index]['userImage'].toString()
                    : ''));
          },
        );
      },
    );
  }
}
