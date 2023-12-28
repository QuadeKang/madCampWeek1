import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

class _MyTabbedAppState extends State<MyTabbedApp> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    Tab1(),
    Tab2(),
    Tab3(),
  ];
  final List<String> _tabTitles = ['PhoneBook', 'Gallery', 'Title for Tab3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '전화번호부',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '이미지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '?',
          ),
        ],
      ),
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;
  final String additionalInfo; // 추가 정보

  Contact({required this.name, required this.phoneNumber, required this.additionalInfo});
}

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  final List<Contact> allContacts = [
    Contact(name: 'John Doe', phoneNumber: '123-456-7890', additionalInfo: 'Additional info for John Doe'),
    Contact(name: 'Jane Smith', phoneNumber: '987-654-3210', additionalInfo: 'Additional info for Jane Smith'),
    Contact(name: 'Alice Johnson', phoneNumber: '555-555-5555', additionalInfo: 'Additional info for Alice Johnson'),
    // 필요한 만큼 데이터를 추가할 수 있습니다.
  ];

  List<Contact> filteredContacts = []; // 검색 결과를 저장하는 리스트
  String searchQuery = ''; // 검색 쿼리를 저장하는 변수

  @override
  void initState() {
    super.initState();
    // 초기에는 전체 연락처를 검색 결과로 설정
    filteredContacts = allContacts;
  }

  // 검색 필드의 상태를 감지하고 검색 결과를 업데이트합니다.
  void searchContacts(String query) {
    setState(() {
      searchQuery = query; // 검색 쿼리 업데이트
      filteredContacts = allContacts
          .where((contact) =>
          contact.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              searchContacts(value); // 검색 필드가 변경될 때 검색 수행
            },
            decoration: InputDecoration(
              hintText: '연락처 검색', // 검색 필드 힌트
              prefixIcon: Icon(Icons.search), // 검색 아이콘
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchQuery.isEmpty ? allContacts.length : filteredContacts.length, // 검색 결과 항목 수
            itemBuilder: (context, index) {
              final contact = searchQuery.isEmpty ? allContacts[index] : filteredContacts[index];

              return ExpandableListTile(
                title: Text(contact.name),
                subtitle: Text(contact.phoneNumber),
                additionalInfo: Text(contact.additionalInfo), // 추가 정보를 표시할 위젯 추가
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExpandableListTile extends StatefulWidget {
  final Widget title;
  final Widget subtitle;
  final Widget additionalInfo;

  ExpandableListTile({required this.title, required this.subtitle, required this.additionalInfo});

  @override
  _ExpandableListTileState createState() => _ExpandableListTileState();
}

class _ExpandableListTileState extends State<ExpandableListTile> {
  bool _isExpanded = false; // 확장/축소 상태 관리

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // 탭할 때 확장/축소 상태 토글
            });
          },
          title: widget.title,
          subtitle: widget.subtitle,
          trailing: _isExpanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more), // 확장/축소 아이콘
        ),
        if (_isExpanded) widget.additionalInfo, // 추가 정보 표시 여부 결정
      ],
    );
  }
}
class Tab2 extends StatefulWidget {
  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  List<File> images = [];

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        images.add(File(photo.path));
        // Optionally, save the image to a specific folder
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _takePicture,
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        itemBuilder: (context, index) {
          return Image.file(images[index]);
        },
      ),
    );
  }
}

class Tab3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tab 3 Content'),
    );
  }
}
