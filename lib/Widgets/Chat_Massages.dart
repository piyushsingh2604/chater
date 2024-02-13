import 'package:chater/Screens/Message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMassages extends StatelessWidget {
  const ChatMassages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return Center(
              child: Text("Something went wrong..."),
            );
          }
          if (chatSnapshots.hasError) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final loadedMessages = chatSnapshots.data!.docs;
          return ListView.builder(
              padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                final chatMassage = loadedMessages[index].data();
                final nextChatMassage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMassage['userId'];
                final nextChatMassageUserId =
                    nextChatMassage != null ? nextChatMassage['userId'] : null;
                final nextUserIsSame =
                    nextChatMassageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMassage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  );
                } else {
                  return MessageBubble.first(
                      userImage:chatMassage['userImage'],
                      username: chatMassage['username'],
                      message:chatMassage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId,);
                }
              });
        });
  }
}
