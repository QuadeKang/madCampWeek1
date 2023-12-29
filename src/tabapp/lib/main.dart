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
    );
  }
}

class MyTabbedApp extends StatefulWidget {
  @override
  _MyTabbedAppState createState() => _MyTabbedAppState();
}

class Tab1 extends StatefulWidget {
  @override
  Tab1State createState() => Tab1State();
}

class Tab2 extends StatefulWidget {
  @override
  Tab2State createState() => Tab2State();
}

class Tab3 extends StatefulWidget {
  @override
  Tab3State createState() => Tab3State();
}

class _MyTabbedAppState extends State<MyTabbedApp>
  with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        children: <Widget>[Tab1(), Tab2(), Tab3()],
        controller: controller,
      ),
      bottomNavigationBar: TabBar(tabs: <Tab>[
        Tab(
          icon: Icon(Icons.home),
          text: '전화번호부',
        ),
        Tab(
          icon: Icon(Icons.search),
          text: '이미지',
        ),
        Tab(
          icon: Icon(Icons.nfc),
          text: 'NFC',
        )
      ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}