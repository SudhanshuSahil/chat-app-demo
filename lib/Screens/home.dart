import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tut/Screens/chat.dart';
import 'package:tut/Screens/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

FirebaseAuth auth = FirebaseAuth.instance;
User currentUser;
final GoogleSignIn googleSignIn = GoogleSignIn();

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }

  chatWith(email) {
    print(currentUser.email + " wants to chat with " + email);

    List<String> users = [email, currentUser.email];
    String chatRoomId;

    if (email.compareTo(currentUser.email) == -1) {
      chatRoomId = email + "_" + currentUser.email;
    } else {
      chatRoomId = currentUser.email + "_" + email;
    }

    Map<String, dynamic> map = {"chatRoomId": chatRoomId, "users": users};

    print(map.toString());

    firestore.collection('chatRooms').doc(chatRoomId).set(map);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  chatRoomId: chatRoomId,
                )));
  }

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentUser != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(currentUser.displayName),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                      onTap: () async {
                        await googleSignIn.signOut();
                        await auth.signOut();

                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return LoginScreen();
                        }));
                      },
                      child: Icon(Icons.logout)),
                )
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("All User"),
                ),
                Flexible(
                  child: StreamBuilder(
                      stream: firestore.collection('users').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) return new Text('Loading...');
                        return new ListView(
                          children:
                              snapshot.data.documents.map<Widget>((document) {
                            if (document['email'] != currentUser.email) {
                              return InkWell(
                                onTap: () {
                                  chatWith(document['email']);
                                },
                                child: new ListTile(
                                  title: new Text(document['displayName']),
                                  subtitle: new Text(document['email']),
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          }).toList(),
                        );
                      }),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(12.0),
                //   child: Text("All Contacts"),
                // ),
                // Flexible(
                //   child: StreamBuilder(
                //       stream: firestore.collection('users').snapshots(),
                //       builder: (BuildContext context, AsyncSnapshot snapshot) {
                //         if (!snapshot.hasData) return new Text('Loading...');
                //         return new ListView(
                //           children:
                //               snapshot.data.documents.map<Widget>((document) {
                //             if (document['email'] != currentUser.email) {
                //               return InkWell(
                //                 onTap: () {},
                //                 child: new ListTile(
                //                   title: new Text(document['displayName']),
                //                   subtitle: new Text(document['email']),
                //                 ),
                //               );
                //             } else {
                //               return SizedBox();
                //             }
                //           }).toList(),
                //         );
                //       }),
                // ),
              ],
            ))
        : Container();
  }
}
