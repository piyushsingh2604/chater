import 'package:flutter/material.dart';



class SpalshScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Loding..."),
      ),
    );
  }
}