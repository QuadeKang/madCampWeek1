import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tabapp/main.dart'; // MyTabbedApp이 정의된 경로로 수정해주세요.

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyTabbedApp()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('인트로 화면', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
