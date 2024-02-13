import 'package:chater/Widgets/Chat_Massages.dart';
import 'package:chater/Widgets/New_Massage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ChatMassages()),
          NewMassage(),
        ],
      )
    );
  }
}
