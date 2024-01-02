import 'package:flutter/material.dart';
import 'sub/firstPage.dart';
import 'sub/secondPage.dart';
import 'sub/thirdPage.dart';
import 'intro.dart';
import 'package:tabapp/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntroScreen(),
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        fontFamily: 'Pretendard',
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

class _MyTabbedAppState extends State<MyTabbedApp>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BizLinkAppBar(),
      body: TabBarView(
        children: <Widget>[_Tab1(), _Tab2(), _Tab3()],
        controller: controller,
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          tabs: <Tab>[
            Tab(icon: Icon(Icons.search), text: '연락처'),
            Tab(icon: Icon(Icons.photo_library), text: '갤러리'),
            Tab(icon: Icon(Icons.folder_shared), text: '명함 공유'),
          ],
          controller: controller,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primaryBlue,
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

class BizLinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      title: Text('BizLink',style: TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // AppBar의 기본 높이
}

class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget titleRow; // Row 위젯을 매개변수로 받음

  SubAppBar({required this.titleRow}); // 생성자를 통해 Row 위젯을 초기화

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0.0,
      title: titleRow, // AppBar의 title로 Row 위젯 사용
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
        color: Colors.black,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50.0); // AppBar의 높이
}