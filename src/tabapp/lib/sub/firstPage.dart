import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabapp/database.dart';

class Contact {
  int? id;
  final String name;
  final String phoneNumber;
  String? memo;
  final String organization; // 소속 정보
  final String position; // 직급 정보
  final String email; // 이메일 정보
  final String photoUrl; // 사진 URL

  Contact({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.organization,
    required this.position,
    required this.email,
    required this.photoUrl,
    this.memo,
  });
}

class ExpandableContactCard extends StatefulWidget {
  final Contact contact;
  final Function(Contact) onDelete;

  const ExpandableContactCard({
    Key? key,
    required this.contact,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ExpandableContactCardState createState() => _ExpandableContactCardState();
}

class _ExpandableContactCardState extends State<ExpandableContactCard> {
  bool isExpanded = false;


  void _confirmDeletion() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('예'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('아니오'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      widget.onDelete(widget.contact);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  void _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        title: Text(widget.contact.name, style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(widget.contact.organization),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.contact.photoUrl),
        ),
        trailing: isExpanded ? null : _buildTrailingIcons(),
        children: <Widget>[
          isExpanded ? _buildExpandedCard() : _buildCollapsedCard(),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
      ),
    );
  }

  Widget _buildTrailingIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: () => _makePhoneCall(widget.contact.phoneNumber),
          icon: Icon(Icons.call),
          tooltip: '전화 걸기',
        ),
        IconButton(
          onPressed: () => _sendSMS(widget.contact.phoneNumber),
          icon: Icon(Icons.local_post_office),
          tooltip: '문자 보내기',
        ),
      ],
    );
  }

  Widget _buildExpandedCard() {
    const double horizontalPadding = 40.0 + 16.0; // 아바타 크기 + 간격

    return Padding(
      padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 전화번호 행
          Row(
            children: [
              Icon(Icons.phone, size: 20),
              SizedBox(width: 8),
              Text(widget.contact.phoneNumber),
            ],
          ),
          SizedBox(height: 8), // 행 사이 간격
          // 직급 행
          Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text(widget.contact.position),
            ],
          ),
          SizedBox(height: 8), // 행 사이 간격
          // 이메일 행
          Row(
            children: [
              Icon(Icons.alternate_email, size: 20),
              SizedBox(width: 8),
              Text(widget.contact.email),
            ],
          ),
          SizedBox(height: 8), // 행 사이 간격
          // 메모 행
          Row(
            children: [
              Icon(Icons.edit_note, size: 20),
              SizedBox(width: 8),
              widget.contact.memo != null
                ? Text(widget.contact.memo!) : Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(5)

                ),
              )

            ],
          ),
          SizedBox(height: 8), // 행 사이 간격
          // 기타 아이콘 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => _makePhoneCall(widget.contact.phoneNumber), icon: Icon(Icons.call)),
              IconButton(onPressed: () => _sendSMS(widget.contact.phoneNumber), icon: Icon(Icons.local_post_office)),
              IconButton(onPressed: (){}, icon: Icon(Icons.edit)),
              IconButton(
                onPressed: _confirmDeletion,
                icon: Icon(Icons.delete_forever_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCollapsedCard() {
    // Build the collapsed card with less details
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Put less detailed information here
          // Add more widgets as needed
        ],
      ),
    );
  }
}

class Tab1State extends State {
  final List<Contact> allContacts = [
    Contact(
      name: 'Alice Smith',
      phoneNumber: '555-0100',
      organization: 'Orbit Inc.',
      position: 'CEO',
      email: 'alice.smith@orbitinc.com',
      photoUrl: 'https://source.unsplash.com/user/c_v_r/100x100?sig=1',
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


  void deleteContact(Contact contact) {
    setState(() {
      allContacts.remove(contact);
      filteredContacts = allContacts
          .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전화번호부',style: TextStyle(fontWeight: FontWeight.bold),), // Tab1 페이지의 타이틀
        actions: <Widget>[
          Icon(Icons.add),
        ],
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
              itemCount: searchQuery.isEmpty
                  ? allContacts.length
                  : filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = searchQuery.isEmpty
                    ? allContacts[index]
                    : filteredContacts[index];

                return ExpandableContactCard(
                  contact: contact,
                  onDelete: deleteContact,

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
