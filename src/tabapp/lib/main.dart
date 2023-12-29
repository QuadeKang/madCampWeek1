import 'package:flutter/material.dart';
import 'sub/firstPage.dart';
import 'sub/secondPage.dart';
import 'sub/thirdPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyTabbedApp(),
      theme: ThemeData(
        fontFamily: 'PretendardRegular',
      ),
    );
  }
}

class MyTabbedApp extends StatefulWidget {
  @override
  _MyTabbedAppState createState() => _MyTabbedAppState();
}

class _Tab1 extends StatefulWidget {
  @override
  Tab1State createState() => Tab1State();
}

class _Tab2 extends StatefulWidget {
  @override
  Tab2State createState() => Tab2State();
}

class _Tab3 extends StatefulWidget {
  @override
  Tab3State createState() => Tab3State();
}

class _MyTabbedAppState extends State<MyTabbedApp> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        children: <Widget>[_Tab1(), _Tab2(), _Tab3()],
        controller: controller,
      ),
      bottomNavigationBar: Material(
        child: TabBar(
          tabs: <Tab>[
            Tab(icon: Icon(Icons.person), text: '전화번호부'),
            Tab(icon: Icon(Icons.photo), text: '이미지'),
            Tab(icon: Icon(Icons.nfc), text: 'NFC'),
          ],
          controller: controller,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
