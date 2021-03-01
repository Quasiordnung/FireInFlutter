import 'package:flutter/material.dart';

import 'cFlame.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testing Canvas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            Container(color: Colors.purple, width: 100, height: 100),
            Positioned(
                top: 150,
                left: 20,
                child: Text(
                    "TEXT TEXT TEXT TEXT TEXT \n TEXT TEXT TEXT TEXT TEXT \n TEXT TEXT TEXT TEXT TEXT")),
            CFlame()
          ],
        ),
      ),
    );
  }
}
