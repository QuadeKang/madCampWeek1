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
  final String memo;
  final String organization; // 소속 정보
  final String position; // 직급 정보
  final String email; // 이메일 정보
  final String photoUrl; // 사진 URL

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.memo,
    required this.organization,
    required this.position,
    required this.email,
    required this.photoUrl,
  });
}

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  final List<Contact> allContacts = [
    Contact(
      name: 'Alice Smith',
      phoneNumber: '555-0100',
      organization: 'Orbit Inc.',
      position: 'CEO',
      email: 'alice.smith@orbitinc.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=1',
      memo: 'Met at tech conference',
    ),
    Contact(
      name: 'Bob Johnson',
      phoneNumber: '555-0101',
      organization: 'Pixel Media',
      position: 'Art Director',
      email: 'bob.johnson@pixelmedia.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=2',
      memo: 'Contact for marketing materials',
    ),
    Contact(
      name: 'Carolyn White',
      phoneNumber: '555-0102',
      organization: 'Green Tech Solutions',
      position: 'Environmental Consultant',
      email: 'carolyn.white@greentech.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=3',
      memo: 'Expert in renewable energy',
    ),
    Contact(
      name: 'David Harris',
      phoneNumber: '555-0103',
      organization: 'Quick Finances',
      position: 'Accountant',
      email: 'david.harris@quickfinances.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=4',
      memo: 'Advised on tax matters',
    ),
    Contact(
      name: 'Evelyn Martinez',
      phoneNumber: '555-0104',
      organization: 'BuildBright',
      position: 'Architect',
      email: 'evelyn.martinez@buildbright.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=5',
      memo: 'Architect for the new office design',
    ),
    Contact(
      name: 'Franklin Green',
      phoneNumber: '555-0105',
      organization: 'AgroFarms',
      position: 'Agronomist',
      email: 'franklin.green@agrofarms.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=6',
      memo: 'Consultant for organic farming practices',
    ),
    Contact(
      name: 'Gloria Young',
      phoneNumber: '555-0106',
      organization: 'TechWave',
      position: 'Software Engineer',
      email: 'gloria.young@techwave.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=7',
      memo: 'Lead of the app development team',
    ),
    Contact(
      name: 'Henry Foster',
      phoneNumber: '555-0107',
      organization: 'MediCare Hospital',
      position: 'Cardiologist',
      email: 'henry.foster@medicare.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=8',
      memo: 'Specialist for heart-related issues',
    ),
    Contact(
      name: 'Isabel Reid',
      phoneNumber: '555-0108',
      organization: 'Global Exports',
      position: 'Logistics Manager',
      email: 'isabel.reid@globalexports.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=9',
      memo: 'Oversees shipping and receiving',
    ),
    Contact(
      name: 'Jack Taylor',
      phoneNumber: '555-0109',
      organization: 'BrightHouse Security',
      position: 'Security Consultant',
      email: 'jack.taylor@brighthouse.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=10',
      memo: 'Advisor for home security system',
    ),
    Contact(
      name: 'Kathy Brown',
      phoneNumber: '555-0110',
      organization: 'EdTech Innovations',
      position: 'Educational Researcher',
      email: 'kathy.brown@edtechinnovations.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=11',
      memo: 'Working on a collaborative project',
    ),
    Contact(
      name: 'Luis Gonzalez',
      phoneNumber: '555-0111',
      organization: 'Healthy Living Markets',
      position: 'Nutritionist',
      email: 'luis.gonzalez@healthyliving.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=12',
      memo: 'Consultant for dietary planning',
    ),
    Contact(
      name: 'Megan Lopez',
      phoneNumber: '555-0112',
      organization: 'City Engineering Dept.',
      position: 'Civil Engineer',
      email: 'megan.lopez@cityeng.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=13',
      memo: 'Contact for public works projects',
    ),
    Contact(
      name: 'Nathan Wright',
      phoneNumber: '555-0113',
      organization: 'Wright Legal Advisors',
      position: 'Attorney',
      email: 'nathan.wright@wrightlegal.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=14',
      memo: 'Legal advisor for company contracts',
    ),
    Contact(
      name: 'Olivia King',
      phoneNumber: '555-0114',
      organization: 'EventStars',
      position: 'Event Coordinator',
      email: 'olivia.king@eventstars.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=15',
      memo: 'Organizes corporate events',
    ),
  ];


  List<Contact> filteredContacts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredContacts = allContacts;
  }

  void searchContacts(String query) {
    setState(() {
      searchQuery = query;
      filteredContacts = allContacts
          .where((contact) =>
          contact.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phonebook'), // Tab1 페이지의 타이틀
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchContacts(value);
              },
              decoration: InputDecoration(
                hintText: '연락처 검색',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchQuery.isEmpty ? allContacts.length : filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = searchQuery.isEmpty ? allContacts[index] : filteredContacts[index];

                return ExpandableListTile(
                  name: contact.name,
                  position: contact.position,
                  memo: contact.memo,
                  phoneNumber: contact.phoneNumber,
                  photoUrl: contact.photoUrl,
                  organization: contact.organization,
                  email: contact.email,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class ExpandableListTile extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String memo;
  final String organization;
  final String position;
  final String email;
  final String photoUrl;

  ExpandableListTile({
    required this.name,
    required this.phoneNumber,
    required this.memo,
    required this.organization,
    required this.position,
    required this.email,
    required this.photoUrl,
  });

  @override
  _ExpandableListTileState createState() => _ExpandableListTileState();
}

class _ExpandableListTileState extends State<ExpandableListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.photoUrl),
          ),
          title: Text(widget.name),
          subtitle: Text(widget.organization),
          trailing: _isExpanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
        ),
        if (_isExpanded) Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('phone number: ${widget.phoneNumber}'),
              Text('Position: ${widget.position}'),
              Text('Email: ${widget.email}'),
              Text('Memo: ${widget.memo}'),
              Row(
                children: [
                  Icon(Icons.call),
                  Icon(Icons.local_post_office),
                  Icon(Icons.edit),
                  Icon(Icons.remove_circle)
                ],
              )

            ],
          ),
        ),
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
