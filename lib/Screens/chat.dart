import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tut/Screens/login.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;

  const ChatScreen({Key key, this.chatRoomId}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState(chatRoomId);
}

FirebaseAuth auth = FirebaseAuth.instance;
User currentUser;

class _ChatScreenState extends State<ChatScreen> {
  final String chatRoomId;
  String otherPerson;

  _ChatScreenState(this.chatRoomId);

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in! with display name: ' + user.displayName);
        currentUser = user;
      }
    });
    firestore.collection("chatRooms").doc(chatRoomId).get().then((value) {
      print("value from chatroom " + chatRoomId.toString());
      // print(value.data()['users']);
      for (var user in value.data()['users']) {
        print(user);
        if (user != currentUser.email) {
          otherPerson = user;
          setState(() {
            otherPerson = user;
          });
        }
      }
    });

    super.initState();

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      } else {
        timer.cancel();
      }
    });
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = new TextEditingController();
    String text;

    return Scaffold(
        appBar: AppBar(
          title: otherPerson == null ? Text("Chat") : Text(otherPerson),
        ),
        body: Column(
          children: [
            Flexible(
              child: StreamBuilder(
                stream: firestore
                    .collection('chatRooms')
                    .doc(chatRoomId)
                    .collection("chats")
                    .orderBy("timestamp")
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  print("chatRoomId" + chatRoomId.toString());
                  print("snapshot incoming " +
                      snapshot.data.documents.toString());
                  if (!snapshot.hasData) {
                    return new Text('Loading...');
                  } else {
                    print("else t");
                    return new ListView(
                      controller: scrollController,
                      children: snapshot.data.documents.map<Widget>((document) {
                        if (document['sentBy'] == currentUser.email) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: 8, left: 100, bottom: 8, top: 8),
                            child: Container(
                              color: Colors.greenAccent,
                              alignment: Alignment.bottomRight,
                              child: new ListTile(
                                title: new Text(document['message']),
                                subtitle: new Text(document['sentBy']),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 100, bottom: 8, top: 8),
                            child: Container(
                              color: Colors.blueAccent,
                              alignment: Alignment.bottomRight,
                              child: new ListTile(
                                title: new Text(document['message']),
                                subtitle: new Text(document['sentBy']),
                              ),
                            ),
                          );
                        }
                      }).toList(),
                    );
                  }
                },
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 66,
                    child: TextFormField(
                      controller: textEditingController,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (textEditingController.text == "") return;

                      firestore
                          .collection("chatRooms")
                          .doc(chatRoomId)
                          .collection("chats")
                          .add({
                        "message": textEditingController.text,
                        "sentBy": currentUser.email,
                        "timestamp": DateTime.now(),
                      });

                      textEditingController.clear();
                    },
                    child: Image.asset(
                      "assets/images/send.png",
                      width: 40,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
