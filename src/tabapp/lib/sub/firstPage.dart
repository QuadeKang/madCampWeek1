import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:tabapp/sub/contactManager.dart';
import 'package:image_picker/image_picker.dart';


class Contact {
  String name;
  String phoneNumber;
  String organization;
  String position;
  String email;
  String? photoPath; // Optional field
  String? memo; // Optional field

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.organization,
    required this.position,
    required this.email,
    this.photoPath,
    this.memo,
  });

  factory Contact.fromJson(Map<String, dynamic> jsonData) {
    return Contact(
      name: jsonData['name'],
      phoneNumber: jsonData['phoneNumber'],
      organization: jsonData['organization'],
      position: jsonData['position'],
      email: jsonData['email'],
      photoPath: jsonData['photoPath'] as String?, // Handle optional field
      memo: jsonData['memo'] as String?, // Handle optional field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'organization': organization,
      'position': position,
      'email': email,
      'photoPath': photoPath, // Optional field
      'memo': memo, // Optional field
    };
  }
}

class ExpandableContactCard extends StatefulWidget {
  final Contact contact;
  final Function(Contact) onDelete;
  final Function(Contact, Contact) onUpdate; // 추가: 연락처 업데이트 콜백

  const ExpandableContactCard({
    Key? key,
    required this.contact,
    required this.onDelete,
    required this.onUpdate, // 추가
  }) : super(key: key);

  @override
  _ExpandableContactCardState createState() => _ExpandableContactCardState();
}

class _ExpandableContactCardState extends State<ExpandableContactCard> {
  bool isExpanded = false;


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _updateContactWithImage(image.path);
    }
  }

  Future<void> _confirmRemoveImage() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사진 삭제'),
          content: Text('사진을 삭제하시겠습니까?'),
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
      _removeImage();
    }
  }
  void _removeImage() {
    _updateContactWithImage(null);
  }
  void _updateContactWithImage(String? imagePath) {
    Contact updatedContact = Contact(
      name: widget.contact.name,
      phoneNumber: widget.contact.phoneNumber,
      organization: widget.contact.organization,
      position: widget.contact.position,
      email: widget.contact.email,
      photoPath: imagePath,
      memo: widget.contact.memo,
    );

    widget.onUpdate(widget.contact, updatedContact);
  }




  void _updateContact(String name, String phoneNumber, String organization,
      String position, String email, String? photoPath, String? memo) {
    Contact updatedContact = Contact(
      name: name,
      phoneNumber: phoneNumber,
      organization: organization,
      position: position,
      email: email,
      photoPath: photoPath,
      memo: memo,
    );

    widget.onUpdate(widget.contact, updatedContact);
  }

  void _showEditContactDialog() async {
    final _nameController = TextEditingController(text: widget.contact.name);
    final _phoneNumberController =
        TextEditingController(text: widget.contact.phoneNumber);
    final _organizationController =
        TextEditingController(text: widget.contact.organization);
    final _positionController =
        TextEditingController(text: widget.contact.position);
    final _emailController = TextEditingController(text: widget.contact.email);
    final _memoController = TextEditingController(text: widget.contact.memo);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('연락처 수정'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: '이름')),
                TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: '전화번호')),
                TextField(
                    controller: _organizationController,
                    decoration: InputDecoration(labelText: '조직')),
                TextField(
                    controller: _positionController,
                    decoration: InputDecoration(labelText: '직급')),
                TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: '이메일')),
                TextField(
                    controller: _memoController,
                    decoration: InputDecoration(labelText: '메모')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateContact(
                  _nameController.text,
                  _phoneNumberController.text,
                  _organizationController.text,
                  _positionController.text,
                  _emailController.text,
                  widget.contact.photoPath, // 사진 URL은 변경하지 않음
                  _memoController.text.isEmpty ? null : _memoController.text,
                );
              },
              child: Text('저장'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletion() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('연락처 삭제'),
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

  void _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  void _sendEmailViaGmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Example Subject', // 이메일 제목을 여기에 추가
        'body': 'Example Body', // 이메일 본문을 여기에 추가
      },
    );

    // Android에서 Gmail 앱을 직접 열려고 시도
    if (Platform.isAndroid) {
      final Uri gmailUri = Uri(
        scheme: 'intent',
        path: '#Intent',
        query:
            'action=android.intent.action.SENDTO&data=${emailLaunchUri.toString()}&package=com.google.android.gm',
        fragment: 'Intent;end',
      );
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri);
      } else {
        throw 'Could not launch $gmailUri';
      }
    } else {
      // iOS 또는 다른 플랫폼에서는 기본 이메일 앱을 사용
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
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
        title: Text(
          widget.contact.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.contact.organization),
        leading: GestureDetector(
          onTap: _pickImage,
          onLongPress: _confirmRemoveImage, // 여기를 수정합니다.
          child: CircleAvatar(
            backgroundImage: widget.contact.photoPath != null
                ? FileImage(File(widget.contact.photoPath!))
                : null,
            child: widget.contact.photoPath == null
                ? Icon(Icons.person, color: Colors.white)
                : null,
            backgroundColor: Colors.grey,
          ),
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

    void _showMemoInputDialog() async {
      final _memoController = TextEditingController(text: widget.contact.memo);

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('메모 입력'),
            content: TextField(
              controller: _memoController,
              decoration: InputDecoration(hintText: "메모를 입력하세요"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateContact(
                    widget.contact.name,
                    widget.contact.phoneNumber,
                    widget.contact.organization,
                    widget.contact.position,
                    widget.contact.email,
                    widget.contact.photoPath,
                    _memoController.text.isEmpty ? null : _memoController.text,
                  );
                },
                child: Text('저장'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: 8.0,
          bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 전화번호 행
          Row(
            children: [
              Icon(Icons.phone, size: 20),
              SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.contact.phoneNumber));
                  // 옵션: 사용자에게 알림 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('전화번호가 복사되었습니다: ${widget.contact.phoneNumber}'),
                    ),
                  );
                },
                child: Text(widget.contact.phoneNumber),
              ),
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
              Expanded(
                // 이메일 텍스트를 Expanded로 감싸 전체 사용 가능한 공간을 채움
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                  child: Container(
                    child: InkWell(
                      onTap: () => _sendEmailViaGmail(widget.contact.email),
                      child: Text(widget.contact.email,
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8), // 행 사이 간격
          // 메모 행
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // 텍스트가 여러 줄일 경우를 고려하여 정렬 변경
            children: [
              Icon(Icons.edit_note, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: widget.contact.memo != null
                    ? Text(
                        widget.contact.memo!,
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      )
                    : GestureDetector(
                        onTap: () {
                          // 메모 입력 로직
                          _showMemoInputDialog();
                        },
                        child: Container(
                          width: 200,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0), // 왼쪽에 8.0만큼의 패딩 추가
                              child: Text('메모 추가',
                                  style: TextStyle(color: Colors.black54)),
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),

          SizedBox(height: 8), // 행 사이 간격
          // 기타 아이콘 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => _makePhoneCall(widget.contact.phoneNumber),
                  icon: Icon(Icons.call)),
              IconButton(
                  onPressed: () => _sendSMS(widget.contact.phoneNumber),
                  icon: Icon(Icons.local_post_office)),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditContactDialog,
              ),
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
  final List<Contact> allContacts = [];
  List<Contact> filteredContacts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      List<Contact> loadedContacts = await ContactManager.loadContacts();
      if (loadedContacts.isEmpty) {
        _addDefaultContacts(); // 기본 연락처 추가
      } else {
        setState(() {
          allContacts.clear();
          allContacts.addAll(loadedContacts);
          _searchContacts(searchQuery);
        });
      }
    } catch (e) {
      print("Error loading contacts: $e");
    }
  }

  void _addDefaultContacts() {
    List<Contact> defaultContacts = [
      Contact(
        name: 'Alice Smith',
        phoneNumber: '555-0100',
        organization: 'Orbit Inc.',
        position: 'CEO',
        email: 'alice.smith@orbitinc.com',
      ),
      Contact(
        name: 'Bob Johnson',
        phoneNumber: '555-0101',
        organization: 'Pixel Media',
        position: 'Art Director',
        email: 'bob.johnson@pixelmedia.com',
        memo: 'Contact for marketing materials',
      ),
      Contact(
        name: 'Carolyn White',
        phoneNumber: '555-0102',
        organization: 'Green Tech Solutions',
        position: 'Environmental Consultant',
        email: 'carolyn.white@greentech.com',
        memo: 'Expert in renewable energy',
      ),
      Contact(
        name: 'David Harris',
        phoneNumber: '555-0103',
        organization: 'Quick Finances',
        position: 'Accountant',
        email: 'david.harris@quickfinances.com',
        memo: 'Advised on tax matters',
      ),
      Contact(
        name: 'Evelyn Martinez',
        phoneNumber: '555-0104',
        organization: 'BuildBright',
        position: 'Architect',
        email: 'evelyn.martinez@buildbright.com',
        memo: 'Architect for the new office design',
      ),
      Contact(
        name: 'Franklin Green',
        phoneNumber: '555-0105',
        organization: 'AgroFarms',
        position: 'Agronomist',
        email: 'franklin.green@agrofarms.com',
        memo:
            'Consultant for organic farming practices. Try to make very long long memo. \nIs it available to change the lines?\nYes!',
      ),
      Contact(
        name: 'Gloria Young',
        phoneNumber: '555-0106',
        organization: 'TechWave',
        position: 'Software Engineer',
        email: 'gloria.young@techwave.com',
        memo: 'Lead of the app development team',
      ),
      Contact(
        name: 'Henry Foster',
        phoneNumber: '555-0107',
        organization: 'MediCare Hospital',
        position: 'Cardiologist',
        email: 'henry.foster@medicare.com',
        memo: 'Specialist for heart-related issues',
      ),
      Contact(
        name: 'Isabel Reid',
        phoneNumber: '555-0108',
        organization: 'Global Exports',
        position: 'Logistics Manager',
        email: 'isabel.reid@globalexports.com',
        memo: 'Oversees shipping and receiving',
      ),
      Contact(
        name: 'Jack Taylor',
        phoneNumber: '555-0109',
        organization: 'BrightHouse Security',
        position: 'Security Consultant',
        email: 'jack.taylor@brighthouse.com',
        memo: 'Advisor for home security system',
      ),
      Contact(
        name: 'Kathy Brown',
        phoneNumber: '555-0110',
        organization: 'EdTech Innovations',
        position: 'Educational Researcher',
        email: 'kathy.brown@edtechinnovations.com',
        memo: 'Working on a collaborative project',
      ),
      Contact(
        name: 'Luis Gonzalez',
        phoneNumber: '555-0111',
        organization: 'Healthy Living Markets',
        position: 'Nutritionist',
        email: 'luis.gonzalez@healthyliving.com',
        memo: 'Consultant for dietary planning',
      ),
      Contact(
        name: 'Megan Lopez',
        phoneNumber: '555-0112',
        organization: 'City Engineering Dept.',
        position: 'Civil Engineer',
        email: 'megan.lopez@cityeng.com',
        memo: 'Contact for public works projects',
      ),
      Contact(
        name: 'Nathan Wright',
        phoneNumber: '555-0113',
        organization: 'Wright Legal Advisors',
        position: 'Attorney',
        email: 'nathan.wright@wrightlegal.com',
        memo: 'Legal advisor for company contracts',
      ),
      Contact(
        name: 'Olivia King',
        phoneNumber: '555-0114',
        organization: 'EventStars',
        position: 'Event Coordinator',
        email: 'olivia.king@eventstars.com',
        memo: 'Organizes corporate events',
      ),
    ];

    setState(() {
      allContacts.addAll(defaultContacts);
      ContactManager.saveContacts(allContacts); // SharedPreferences에 저장
    });
  }

  void _searchContacts(String query) {
    setState(() {
      searchQuery = query.toLowerCase(); // 검색어를 소문자로 변환하여 저장
      filteredContacts = allContacts.where((contact) {
        // 모든 필드를 소문자로 변환하고 검색어가 포함되어 있는지 확인
        return contact.name.toLowerCase().contains(searchQuery) ||
            contact.phoneNumber.toLowerCase().contains(searchQuery) ||
            contact.organization.toLowerCase().contains(searchQuery) ||
            contact.position.toLowerCase().contains(searchQuery) ||
            contact.email.toLowerCase().contains(searchQuery) ||
            (contact.memo != null &&
                contact.memo!.toLowerCase().contains(searchQuery));
      }).toList();
    });
  }

  void updateContact(Contact oldContact, Contact newContact) {
    setState(() {
      int index = allContacts.indexOf(oldContact);
      if (index != -1) {
        allContacts[index] = newContact;
        ContactManager.saveContacts(allContacts); // Save to SharedPreferences
        _searchContacts(searchQuery); // Update the filteredContacts
      }
    });
  }

  void deleteContact(Contact contact) {
    setState(() {
      allContacts.remove(contact);
      ContactManager.saveContacts(allContacts); // Save to SharedPreferences
      _searchContacts(searchQuery); // Update the filteredContacts
    });
  }

  // Add a method to handle adding a new contact
  void addNewContact(Contact newContact) {
    setState(() {
      allContacts.add(newContact);
      filteredContacts = allContacts
          .where(
              (c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
      ContactManager.saveContacts(allContacts); // Save to SharedPreferences
    });
  }

  void _addNewContactDialog() async {
    final _nameController = TextEditingController();
    final _phoneNumberController = TextEditingController();
    final _organizationController = TextEditingController();
    final _positionController = TextEditingController();
    final _emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 연락처 추가'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: '이름')),
                TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: '전화번호')),
                TextField(
                    controller: _organizationController,
                    decoration: InputDecoration(labelText: '소속')),
                TextField(
                    controller: _positionController,
                    decoration: InputDecoration(labelText: '직급')),
                TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: '이메일')),
                // 필요에 따라 더 많은 필드를 추가할 수 있습니다
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addNewContact(
                  _nameController.text,
                  _phoneNumberController.text,
                  _organizationController.text,
                  _positionController.text,
                  _emailController.text,
                );
              },
              child: Text('저장'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _addNewContact(String name, String phoneNumber, String organization,
      String position, String email) {
    Contact newContact = Contact(
      name: name,
      phoneNumber: phoneNumber,
      organization: organization,
      position: position,
      email: email,
    );
    setState(() {
      allContacts.add(newContact);
      ContactManager.saveContacts(allContacts); // SharedPreferences에 저장
    });
  }
  void _resetContacts() {
    setState(() {
      allContacts.clear(); // 기존 데이터를 모두 제거
      _addDefaultContacts(); // 기본 연락처를 다시 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('연락처', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh), // 새로고침 아이콘 추가
            onPressed: _resetContacts, // 새로고침 기능을 실행할 메소드
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewContactDialog, // 여기에 연락처 추가 다이얼로그를 띄우는 기능을 연결
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _searchContacts(value);
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
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0), // 양쪽에 간격 추가
                  child: ExpandableContactCard(
                    contact: contact,
                    onDelete: deleteContact,
                    onUpdate: updateContact,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
