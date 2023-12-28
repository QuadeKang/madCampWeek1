import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('phonebook'),
      ),
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

  Contact({required this.name, required this.phoneNumber});
}

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  final List<Contact> allContacts = [
    Contact(name: 'John Doe', phoneNumber: '123-456-7890'),
    Contact(name: 'Jane Smith', phoneNumber: '987-654-3210'),
    Contact(name: 'Alice Johnson', phoneNumber: '555-555-5555'),
    // 필요한 만큼 데이터를 추가할 수 있습니다.
  ];

  List<Contact> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    // 초기에는 전체 연락처를 검색 결과로 설정
    filteredContacts = allContacts;
  }

  // 검색 필드의 상태를 감지하고 검색 결과를 업데이트합니다.
  void searchContacts(String query) {
    setState(() {
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
            itemCount: filteredContacts.length, // 검색 결과 항목 수
            itemBuilder: (context, index) {
              final contact = filteredContacts[index];

              return ListTile(
                title: Text(contact.name),
                subtitle: Text(contact.phoneNumber),
                onTap: () {
                  print('탭한 연락처: ${contact.name}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}



class Tab2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tab 2 Content'),
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
