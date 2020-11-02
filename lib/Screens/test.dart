import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("test ssss"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                  onTap: () {
                    print("login button tapped");
                  },
                  child: Icon(Icons.login)),
            )
          ],
        ),
        body: Column(
          children: [
            Image.network(
              "https://via.placeholder.com/150",
            )
          ],
        ));
  }
}
