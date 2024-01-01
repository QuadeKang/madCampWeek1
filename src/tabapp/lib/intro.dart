import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tabapp/main.dart'; // MyTabbedApp이 정의된 경로로 수정해주세요.
import 'package:flutter_svg/flutter_svg.dart';


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
      body: Center( // Center 위젯을 사용해 전체 내용을 중앙에 배치
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Column의 내용을 중앙에 배치
          children: [
            Container(
              width: 151.27,
              height: 138.72,
              child: SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 160,
                height: 160,
              ),
            ),
            Text(
              'BizLink',
              style: TextStyle(
                color: Color(0xFF0037FF),
                fontSize: 25,
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w700,
                height: 0.04,
                letterSpacing: -0.41,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
