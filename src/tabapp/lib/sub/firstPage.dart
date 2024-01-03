import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart' as cs;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:tabapp/colors.dart';
import 'package:tabapp/sub/contactManager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tabapp/customDialog.dart';
import 'package:tabapp/main.dart';

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
        return CustomDialog(
          title: '사진 삭제',
          content: '사진을 삭제하시겠습니까?',
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
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
    phoneNumber = formatPhoneNumber(phoneNumber);
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

    Map<String, bool> _showError = {
      'name': false,
      'phoneNumber': false,
      'organization': false,
      'position': false,
      'email': false,
    };

    void checkAndSetError() {
      _showError['name'] = _nameController.text.isEmpty;
      _showError['phoneNumber'] = _phoneNumberController.text.isEmpty;
      _showError['organization'] = _organizationController.text.isEmpty;
      _showError['position'] = _positionController.text.isEmpty;
      _showError['email'] = _emailController.text.isEmpty;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // border-radius: 10px;
            ),
            backgroundColor: Colors.white, // background: #FFF;
            surfaceTintColor: Colors.transparent,
            title: const Text(
              '연락처 수정',
              style: TextStyle(
                color: Color(0xFF476BEC), // Primary blue color for the title
                fontFamily: 'Pretendard Variable',
                fontSize: 22,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.408,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  CustomTextField(
                    controller: _nameController,
                    labelText: '이름',
                    showError: _showError['name'] ?? false,
                  ),
                  if (_showError['name']!) // 이름 필드에 대한 경고 메시지
                    Text('이름을 입력해주세요', style: TextStyle(color: Colors.red)),
                  CustomTextField(
                    controller: _phoneNumberController,
                    labelText: '전화번호',
                    keyboardType: TextInputType.phone,
                    showError: _showError['phoneNumber'] ?? false,
                  ),
                  if (_showError['phoneNumber']!) // 이름 필드에 대한 경고 메시지
                    Text('전화번호를 입력해주세요', style: TextStyle(color: Colors.red)),
                  CustomTextField(
                    controller: _organizationController,
                    labelText: '조직',
                    showError: _showError['organization'] ?? false,
                  ),
                  if (_showError['organization']!)
                    Text('조직명을 입력해주세요.', style: TextStyle(color: Colors.red)),
                  CustomTextField(
                    controller: _positionController,
                    labelText: '직급',
                    showError: _showError['position'] ?? false,
                  ),
                  if (_showError['position']!)
                    Text('직급을 입력해주세요.', style: TextStyle(color: Colors.red)),
                  CustomTextField(
                    controller: _emailController,
                    labelText: '이메일',
                    keyboardType: TextInputType.emailAddress,
                    showError: _showError['email'] ?? false,
                  ),
                  if (_showError['email']!)
                    Text('이메일을 입력해주세요.', style: TextStyle(color: Colors.red)),
                  CustomTextField(
                    controller: _memoController,
                    labelText: '메모',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    checkAndSetError(); // 필드 검사 및 오류 설정
                  });
                  if (!_showError.containsValue(true)) {
                    Navigator.of(context).pop();
                    _updateContact(
                      _nameController.text,
                      formatPhoneNumber(_phoneNumberController.text),
                      _organizationController.text,
                      _positionController.text,
                      _emailController.text,
                      widget.contact.photoPath,
                      _memoController.text.isEmpty
                          ? null
                          : _memoController.text,
                    );
                  }
                },
                child: Text(
                  '저장',
                  textAlign: TextAlign.center, // text-align: center;
                  style: TextStyle(
                    color: Colors.black, // color: var(--black, #000);
                    fontFamily:
                        'Pretendard Variable', // font-family: Pretendard Variable;
                    fontSize: 16, // font-size: 16px;
                    fontStyle: FontStyle.normal, // font-style: normal;
                    fontWeight: FontWeight.w500, // font-weight: 500;
                    letterSpacing: -0.408, // letter-spacing: -0.408px;
                    height:
                        1.375, // Approximately 137.5% line-height (22px / 16px)
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  textAlign: TextAlign.center, // text-align: center;
                  style: TextStyle(
                    color: Colors.black, // color: var(--black, #000);
                    fontFamily:
                        'Pretendard Variable', // font-family: Pretendard Variable;
                    fontSize: 16, // font-size: 16px;
                    fontStyle: FontStyle.normal, // font-style: normal;
                    fontWeight: FontWeight.w500, // font-weight: 500;
                    letterSpacing: -0.408, // letter-spacing: -0.408px;
                    height:
                        1.375, // Approximately 137.5% line-height (22px / 16px)
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _confirmDeletion() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: '연락처 삭제',
          content: '연락처를 삭제하시겠습니까?',
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
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

  void _openGmail(String email) async {
    // URL 인코딩을 사용하여 이메일 링크 생성
    final url = 'mailto:$email';

    // 만약 링크를 열 수 있다면 열기
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open Gmail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0, // Given from your original Flutter code
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10), // Adjusted to 10px to match the CSS
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF), // Equivalent to #FFF
          borderRadius: BorderRadius.circular(10), // 10px border radius
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(widget.contact.name,
                style: const TextStyle(
                  color: Color(0xFF000000), // Equivalent to #000 or black
                  fontFamily:
                      'Pretendard Variable', // Ensure the font is included in your project
                  fontSize: 18.0, // Font size
                  fontStyle: FontStyle.normal, // Normal font style
                  fontWeight: FontWeight
                      .w700, // Font weight 700 is equivalent to FontWeight.w700
                  height: 22 /
                      18, // Line height divided by font size for line-height percentage
                  letterSpacing: -0.408, // Letter spacing
                )),
            subtitle: Text(
              widget.contact.organization,
              style: const TextStyle(
                color: Color(0xFF000000), // Equivalent to #000 or black
                fontFamily:
                    'Pretendard Variable', // Ensure the font is included in your project
                fontSize: 14.0, // Font size
                fontStyle: FontStyle.normal, // Normal font style
                fontWeight: FontWeight
                    .w300, // Font weight 300 is equivalent to FontWeight.w300
                height: 22 /
                    14, // Line height divided by font size for line-height percentage
                letterSpacing: -0.408, // Letter spacing
              ),
            ),
            leading: GestureDetector(
              onTap: _pickImage,
              onLongPress: _confirmRemoveImage, // 여기를 수정합니다.
              child: CircleAvatar(
                backgroundImage: widget.contact.photoPath != null
                    ? FileImage(File(widget.contact.photoPath!))
                    : null,
                backgroundColor: Colors.grey,
                child: widget.contact.photoPath == null
                    ? SvgPicture.asset(
                        'assets/images/profilephoto.svg',
                        width: 45,
                        height: 45,
                      )
                    : null,
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
        ),
      ),
    );
  }

  Widget _buildTrailingIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: () => _makePhoneCall(widget.contact.phoneNumber),
          icon: SvgPicture.asset(
            'assets/images/callButton.svg',
            width: 29,
            height: 29,
          ),
          tooltip: '전화 걸기',
        ),
        IconButton(
          onPressed: () => _sendSMS(widget.contact.phoneNumber),
          icon: SvgPicture.asset(
            'assets/images/messageButtonFilled.svg',
            width: 29,
            height: 29,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // border-radius: 10px;
            ),
            backgroundColor: Colors.white, // background: #FFF;
            surfaceTintColor: Colors.transparent,
            title: Text(
              '메모 입력',
              style: TextStyle(
                color: Color(0xFF476BEC), // Primary blue color for the title
                fontFamily: 'Pretendard Variable',
                fontSize: 22,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.408,
              ),
            ),
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
                    formatPhoneNumber(widget.contact.phoneNumber),
                    widget.contact.organization,
                    widget.contact.position,
                    widget.contact.email,
                    widget.contact.photoPath,
                    _memoController.text.isEmpty ? null : _memoController.text,
                  );
                },
                child: Text(
                  '저장',
                  textAlign: TextAlign.center, // text-align: center;
                  style: TextStyle(
                    color: Colors.black, // color: var(--black, #000);
                    fontFamily:
                        'Pretendard Variable', // font-family: Pretendard Variable;
                    fontSize: 16, // font-size: 16px;
                    fontStyle: FontStyle.normal, // font-style: normal;
                    fontWeight: FontWeight.w500, // font-weight: 500;
                    letterSpacing: -0.408, // letter-spacing: -0.408px;
                    height:
                        1.375, // Approximately 137.5% line-height (22px / 16px)
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '취소',
                  textAlign: TextAlign.center, // text-align: center;
                  style: TextStyle(
                    color: Colors.black, // color: var(--black, #000);
                    fontFamily:
                        'Pretendard Variable', // font-family: Pretendard Variable;
                    fontSize: 16, // font-size: 16px;
                    fontStyle: FontStyle.normal, // font-style: normal;
                    fontWeight: FontWeight.w500, // font-weight: 500;
                    letterSpacing: -0.408, // letter-spacing: -0.408px;
                    height:
                        1.375, // Approximately 137.5% line-height (22px / 16px)
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(
          left: horizontalPadding + 14,
          right: horizontalPadding,
          top: 8.0,
          bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 전화번호 행
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 20,
                color: Color(0xFF979797),
              ),
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
              Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF979797),
              ),
              SizedBox(width: 8),
              Text(widget.contact.position),
            ],
          ),
          SizedBox(height: 8), // 행 사이 간격
          // 이메일 행
          Row(
            children: [
              Icon(
                Icons.alternate_email,
                size: 20,
                color: Color(0xFF979797),
              ),
              SizedBox(width: 8),
              Expanded(
                // 이메일 텍스트를 Expanded로 감싸 전체 사용 가능한 공간을 채움
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                  child: Container(
                    child: InkWell(
                      onTap: () => _openGmail(widget.contact.email),
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
              Icon(
                Icons.edit_note,
                size: 20,
                color: Color(0xFF979797),
              ),
              SizedBox(width: 8),
              Expanded(
                child: widget.contact.memo != null && widget.contact.memo !=''
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
                icon: SvgPicture.asset(
                  'assets/images/callButton.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              IconButton(
                onPressed: () => _sendSMS(widget.contact.phoneNumber),
                icon: SvgPicture.asset(
                  'assets/images/messageButtonFilled.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/editButton.svg',
                  width: 30,
                  height: 30,
                ),
                onPressed: _showEditContactDialog,
              ),
              IconButton(
                onPressed: _confirmDeletion,
                icon: SvgPicture.asset(
                  'assets/images/deleteButton.svg',
                  width: 30,
                  height: 30,
                ),
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

  void sortContacts(List<Contact> contacts) {
    print('sort');
    contacts.sort((a, b) {
      return _compareContacts(a.name, b.name);
    });
  }

  int _compareContacts(String a, String b) {
    // 한글 체크
    bool isKoreanA = _isKorean(a);
    bool isKoreanB = _isKorean(b);

    if (isKoreanA && !isKoreanB) return -1;
    if (!isKoreanA && isKoreanB) return 1;

    // 영어의 경우 대소문자를 구분하지 않고 비교, 같으면 대문자가 먼저 오도록
    int caseInsensitiveCompare = a.toLowerCase().compareTo(b.toLowerCase());
    if (caseInsensitiveCompare != 0) {
      return caseInsensitiveCompare;
    } else {
      return -a.compareTo(b); // 대문자가 먼저 오도록
    }
  }

  bool _isKorean(String text) {
    // 한글 유니코드 범위 체크
    return text.isNotEmpty &&
        text.codeUnitAt(0) >= 0xAC00 &&
        text.codeUnitAt(0) <= 0xD7A3;
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
          sortContacts(allContacts);
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
        name: '김민준',
        phoneNumber: '010-1234-5678',
        organization: '천재그룹',
        position: 'CEO',
        email: 'minjun.kim@naver.com',
      ),
      Contact(
        name: '이서아',
        phoneNumber: '010-2345-6789',
        organization: '하늘그룹',
        position: 'CEO',
        email: 'seoah.lee@gmail.com',
      ),
      Contact(
        name: '박지훈',
        phoneNumber: '010-3456-7890',
        organization: '대한기업',
        position: '매니저',
        email: 'jihun.park@naver.com',
      ),
      Contact(
        name: '최예진',
        phoneNumber: '010-4567-8901',
        organization: '블루웨이브',
        position: '디렉터',
        email: 'yejin.choi@gmail.com',
      ),
      Contact(
        name: '정다빈',
        phoneNumber: '010-5678-9012',
        organization: '솔라리스',
        position: '연구원',
        email: 'dabin.jung@naver.com',
      ),
      Contact(
        name: '한지우',
        phoneNumber: '010-6789-0123',
        organization: '테크노밸리',
        position: '개발자',
        email: 'jiwoo.han@gmail.com',
      ),
      Contact(
        name: '유하은',
        phoneNumber: '010-7890-1234',
        organization: '크리에이티브랩',
        position: '아티스트',
        email: 'haeun.yoo@naver.com',
      ),
      Contact(
        name: '손태양',
        phoneNumber: '010-8901-2345',
        organization: '선샤인미디어',
        position: '마케터',
        email: 'taeyang.son@gmail.com',
      ),
      Contact(
        name: '노하늘',
        phoneNumber: '010-9012-3456',
        organization: '드림캐쳐스',
        position: '기획자',
        email: 'haneul.noh@naver.com',
      ),
      Contact(
        name: '문주연',
        phoneNumber: '010-0123-4567',
        organization: '뷰티퀸',
        position: '스타일리스트',
        email: 'juwon.moon@gmail.com',
      ),
      Contact(
        name: '우지호',
        phoneNumber: '010-1234-5600',
        organization: '에코프렌즈',
        position: '운영자',
        email: 'jiho.woo@naver.com',
      ),
      Contact(
        name: '서은경',
        phoneNumber: '010-2345-6700',
        organization: '인피니티코드',
        position: '프로그래머',
        email: 'eunkyung.seo@gmail.com',
      ),
      Contact(
        name: '남주희',
        phoneNumber: '010-3456-7800',
        organization: '월드클래스',
        position: '교육자',
        email: 'juhee.nam@naver.com',
      ),
      Contact(
        name: '정민재',
        phoneNumber: '010-4567-8900',
        organization: '헬스매니아',
        position: '트레이너',
        email: 'minjae.jung@gmail.com',
      ),
      Contact(
        name: '김태현',
        phoneNumber: '010-5678-9000',
        organization: '데이터웍스',
        position: '분석가',
        email: 'taehyun.kim@naver.com',
      ),
    ];

    setState(() {
      allContacts.addAll(defaultContacts);
      sortContacts(allContacts);
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
      sortContacts(filteredContacts);
    });
  }

  void updateContact(Contact oldContact, Contact newContact) {
    setState(() {
      int index = allContacts.indexOf(oldContact);
      if (index != -1) {
        allContacts[index] = newContact;
        sortContacts(allContacts);
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
      sortContacts(allContacts);
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
    Map<String, bool> _showError = {
      'name': false,
      'phoneNumber': false,
      'organization': false,
      'position': false,
      'email': false,
    };

    void checkAndSetError() {
      _showError['name'] = _nameController.text.isEmpty;
      _showError['phoneNumber'] = _phoneNumberController.text.isEmpty;
      _showError['organization'] = _organizationController.text.isEmpty;
      _showError['position'] = _positionController.text.isEmpty;
      _showError['email'] = _emailController.text.isEmpty;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // border-radius: 10px;
              ),
              backgroundColor: Colors.white, // background: #FFF;
              surfaceTintColor: Colors.transparent,
              title: const Text(
                '새 연락처 추가',
                style: TextStyle(
                  color: Color(0xFF476BEC), // Primary blue color for the title
                  fontFamily: 'Pretendard Variable',
                  fontSize: 22,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.408,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    CustomTextField(
                      controller: _nameController,
                      labelText: '이름',
                      showError: _showError['name'] ?? false, // 'name' 키가 null인 경우 false를 반환
                    ),
                    if (_showError['name']!) // 이름 필드에 대한 경고 메시지
                      Text('이름을 입력해주세요', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _phoneNumberController,
                      labelText: '전화번호',
                      keyboardType: TextInputType.phone,
                      showError: _showError['phoneNumber'] ?? false,
                    ),
                    if (_showError['phoneNumber']!) // 이름 필드에 대한 경고 메시지
                      Text('전화번호를 입력해주세요', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _organizationController,
                      labelText: '조직',
                      showError: _showError['organization'] ?? false,
                    ),
                    if (_showError['organization']!)
                      Text('조직명을 입력해주세요.', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _positionController,
                      labelText: '직급',
                      showError: _showError['position'] ?? false,
                    ),
                    if (_showError['position']!)
                      Text('직급을 입력해주세요.', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _emailController,
                      labelText: '이메일',
                      keyboardType: TextInputType.emailAddress,
                      showError: _showError['email'] ?? false,
                    ),
                    if (_showError['email']!)
                      Text('이메일을 입력해주세요.', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      checkAndSetError(); // 필드 검사 및 오류 설정
                    });
                    if (!_showError.containsValue(true)) {
                      Navigator.of(context).pop();
                      _addNewContact(
                        _nameController.text,
                        _phoneNumberController.text,
                        _organizationController.text,
                        _positionController.text,
                        _emailController.text,
                      );
                    }
                  },
                  child: Text(
                    '저장',
                    textAlign: TextAlign.center, // text-align: center;
                    style: TextStyle(
                      color: Colors.black, // color: var(--black, #000);
                      fontFamily:
                          'Pretendard Variable', // font-family: Pretendard Variable;
                      fontSize: 16, // font-size: 16px;
                      fontStyle: FontStyle.normal, // font-style: normal;
                      fontWeight: FontWeight.w500, // font-weight: 500;
                      letterSpacing: -0.408, // letter-spacing: -0.408px;
                      height:
                          1.375, // Approximately 137.5% line-height (22px / 16px)
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    textAlign: TextAlign.center, // text-align: center;
                    style: TextStyle(
                      color: Colors.black, // color: var(--black, #000);
                      fontFamily:
                          'Pretendard Variable', // font-family: Pretendard Variable;
                      fontSize: 16, // font-size: 16px;
                      fontStyle: FontStyle.normal, // font-style: normal;
                      fontWeight: FontWeight.w500, // font-weight: 500;
                      letterSpacing: -0.408, // letter-spacing: -0.408px;
                      height:
                          1.375, // Approximately 137.5% line-height (22px / 16px)
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addNewContact(String name, String phoneNumber, String organization,
      String position, String email) {
    phoneNumber = formatPhoneNumber(phoneNumber);
    Contact newContact = Contact(
      name: name,
      phoneNumber: phoneNumber,
      organization: organization,
      position: position,
      email: email,
    );
    setState(() {
      allContacts.add(newContact);
      sortContacts(allContacts);
      ContactManager.saveContacts(allContacts); // SharedPreferences에 저장
    });
  }

  void _resetContacts() {
    setState(() {
      allContacts.clear(); // 기존 데이터를 모두 제거
      _addDefaultContacts(); // 기본 연락처를 다시 추가
    });
  }

  Future<void> _loadContactsFromPhone() async {
    // 연락처 접근 권한 체크
    var permissionStatus = await Permission.contacts.status;

    // 권한이 부여되지 않았다면 요청
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.contacts.request();
    }

    // 권한이 부여되면 연락처를 불러옴
    if (permissionStatus.isGranted) {
      Iterable<cs.Contact> phoneContacts =
          await cs.ContactsService.getContacts();

      // 사용자가 연락처를 선택할 수 있는 다이얼로그를 표시
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // border-radius: 10px;
            ),
            backgroundColor: Colors.white, // background: #FFF;
            surfaceTintColor: Colors.transparent,

            title: Text(
              '연락처 불러오기',
              style: TextStyle(
                color: Color(0xFF476BEC), // Primary blue color for the title
                fontFamily: 'Pretendard Variable',
                fontSize: 22,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.408,
              ),
            ),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: SizedBox(
                  width: double.infinity, // 또는 특정 크기
                  height: double.infinity, // 또는 특정 크기
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('불러올 연락처를 선택하세요',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white, // Background color
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .zero, // 모서리를 네모나게 만듦 (Radius를 0으로 설정)
                          ),
                        ),
                        onPressed: () {
                          _addNewContactDialog();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                                width:
                                    4), // Optional: provide some space between the icon and the text
                            Icon(Icons.add,
                                color:
                                    Colors.black), // The "+" icon on the left
                            SizedBox(
                                width:
                                    8), // Optional: provide some space between the icon and the text
                            Expanded(
                              // This will take up all available space, pushing the icon to the left
                              child: Text(
                                '새로운 연락처', // The button's text
                                style: TextStyle(
                                    color: Colors.black), // Set the text color
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1, // 선의 높이, 버튼의 높이에 맞춰 조정할 수 있습니다.
                        width: double.infinity, // 선의 두께, 1px로 설정.
                        color: Color(
                            0xFF7C7C7C), // var(--icongray, #7C7C7C)에 해당하는 색상.
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: phoneContacts.length,
                          itemBuilder: (BuildContext context, int index) {
                            cs.Contact contact = phoneContacts.elementAt(index);
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(
                                        0xFF7C7C7C), // var(--icongray, #7C7C7C) 대응 색상
                                    width: 1.0, // 1px 테두리
                                  ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 4),
                                leading: Icon(Icons.person), // 'person' 아이콘 추가
                                title: Text(
                                  contact.displayName ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                    contact.phones?.isNotEmpty ?? false
                                        ? contact.phones!.first.value ??
                                            'No phone number'
                                        : 'No phone number'),
                                onTap: () {
                                  // 연락처 선택 시 처리
                                  Navigator.of(context).pop();
                                  _addSelectedContact(contact);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      );
    } else {
      // 권한 거부 처리
      print("연락처 접근 권한이 거부되었습니다.");
      // 필요한 경우 사용자에게 권한 거부에 대한 안내 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white, // background: #FFF;
            surfaceTintColor: Colors.transparent,
            title: Text('권한 필요'),
            content: Text('연락처에 접근하려면 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
            actions: <Widget>[
              TextButton(
                child: Text('설정 열기'),
                onPressed: () {
                  openAppSettings(); // 앱 설정 페이지를 열어 사용자가 권한을 변경할 수 있도록 함
                },
              ),
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _addSelectedContact(cs.Contact phoneContact) {
    // 필수 정보의 누락 여부를 확인합니다.
    bool isInfoMissing = phoneContact.displayName == null ||
        phoneContact.displayName!.isEmpty ||
        phoneContact.phones == null ||
        phoneContact.phones!.isEmpty ||
        phoneContact.emails == null ||
        phoneContact.emails!.isEmpty ||
        phoneContact.company == null ||
        phoneContact.company!.isEmpty ||
        phoneContact.jobTitle == null ||
        phoneContact.jobTitle!.isEmpty;

    if (isInfoMissing) {
      // 필수 정보가 누락된 경우, 정보 입력 대화상자를 표시합니다.
      _showContactDialogForIncompleteInfo(
          phoneContact.displayName ?? '',
          phoneContact.phones?.isNotEmpty ?? false
              ? phoneContact.phones!.first.value ?? ''
              : '',
          phoneContact.company ?? '',
          phoneContact.jobTitle ?? '',
          phoneContact.emails?.isNotEmpty ?? false
              ? phoneContact.emails!.first.value ?? ''
              : '');
    } else {
      // 필수 정보가 모두 있는 경우, 연락처를 직접 추가합니다.
      Contact newContact = Contact(
        name: phoneContact.displayName ?? '',
        phoneNumber: phoneContact.phones?.isNotEmpty ?? false
            ? phoneContact.phones!.first.value ?? ''
            : '',
        organization: phoneContact.company ?? '',
        position: phoneContact.jobTitle ?? '',
        email: phoneContact.emails?.isNotEmpty ?? false
            ? phoneContact.emails!.first.value ?? ''
            : '',
      );

      setState(() {
        allContacts.add(newContact);
        sortContacts(allContacts);
        ContactManager.saveContacts(allContacts); // SharedPreferences에 저장
      });
    }
  }

// 불러온 연락처 정보가 누락된 경우 대화상자 표시
  Future<void> _showContactDialogForIncompleteInfo(
      String name,
      String phoneNumber,
      String organization,
      String position,
      String email) async {
    final _nameController = TextEditingController(text: name);
    final _phoneNumberController = TextEditingController(text: phoneNumber);
    final _organizationController = TextEditingController(text: organization);
    final _positionController = TextEditingController(text: position);
    final _emailController = TextEditingController(text: email);

    // 각 필드별 오류 상태를 추적하는 Map
    Map<String, bool> _showError = {
      'name': false,
      'phoneNumber': false,
      'organization': false,
      'position': false,
      'email': false,
    };

    // 오류 상태를 업데이트하는 함수
    void checkAndSetError() {
      _showError['name'] = _nameController.text.isEmpty;
      _showError['phoneNumber'] = _phoneNumberController.text.isEmpty;
      _showError['organization'] = _organizationController.text.isEmpty;
      _showError['position'] = _positionController.text.isEmpty;
      _showError['email'] = _emailController.text.isEmpty;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                '연락처 정보 입력',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    CustomTextField(
                      controller: _nameController,
                      labelText: '이름',
                      showError: _showError['name'] ?? false,
                    ),
                    if (_showError['name']!)
                      Text('이름을 입력해주세요.', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _phoneNumberController,
                      labelText: '전화번호',
                      keyboardType: TextInputType.phone,
                      showError: _showError['phoneNumber'] ?? false,
                    ),
                    if (_showError['phoneNumber']!)
                      Text('전화번호를 입력해주세요.',
                          style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _organizationController,
                      labelText: '조직',
                      showError: _showError['organization'] ?? false,
                    ),
                    if (_showError['organization']!)
                      Text('조직명을 입력해주세요.', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _positionController,
                      labelText: '직급',
                      showError: _showError['position'] ?? false,
                    ),
                    if (_showError['position']!)
                      Text('직급을 입력해주세요.', style: TextStyle(color: Colors.red)),
                    CustomTextField(
                      controller: _emailController,
                      labelText: '이메일',
                      keyboardType: TextInputType.emailAddress,
                      showError: _showError['email'] ?? false,
                    ),
                    if (_showError['email']!)
                      Text('이메일을 입력해주세요.', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      checkAndSetError(); // 필드 상태 확인 및 오류 설정
                    });
                    if (!_showError.containsValue(true)) {
                      Navigator.of(context).pop();
                      phoneNumber = _phoneNumberController.text;
                      _addContactToApp(Contact(
                        name: _nameController.text,
                        phoneNumber: formatPhoneNumber(phoneNumber),
                        organization: _organizationController.text,
                        position: _positionController.text,
                        email: _emailController.text,
                      ));
                    }
                  },
                  child: Text(
                    '저장',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Pretendard Variable',
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.408,
                      height: 1.375,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Pretendard Variable',
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.408,
                      height: 1.375,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// 연락처를 앱의 목록에 추가하는 메소드
  void _addContactToApp(Contact contact) {
    setState(() {
      allContacts.add(contact);
      sortContacts(allContacts);
      ContactManager.saveContacts(allContacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECECEC),
      //appBar: AppBar(
        //title: Text('연락처', style: TextStyle(fontWeight: FontWeight.bold)),
        //actions: <Widget>[
          //IconButton(
            //icon: Icon(Icons.refresh), // 새로고침 아이콘 추가
            //onPressed: _resetContacts, // 새로고침 기능을 실행할 메소드
          //),
        //],
      //),
      body: Stack(
        // Use Stack to overlay widgets
        children: [
          Column(
            // Your existing column
            children: [
              Container(
                color: Colors.white,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      _searchContacts(value);
                    },
                    decoration: InputDecoration(
                      hintText: '연락처 검색',
                      // Removes default underline border
                      border: InputBorder.none,
                      // Removes border when TextField is enabled
                      enabledBorder: InputBorder.none,
                      // Removes border when TextField is focused (clicked or tapped)
                      focusedBorder: InputBorder.none,
                      hintStyle: const TextStyle(
                        color: Color(0xFF979797), // var(--gray, #979797)
                        fontFamily:
                            'Pretendard Variable', // Make sure this font is added to your pubspec.yaml
                        fontSize: 20.0, // font-size: 20px
                        fontStyle: FontStyle.normal, // font-style: normal
                        fontWeight: FontWeight.w500, // font-weight: 500
                        height:
                            1.1, // line-height: 110% (approximation using height as a multiplier)
                        letterSpacing: -0.408, // letter-spacing: -0.408px
                      ),
                      prefixIcon: Padding(
                        padding:
                            EdgeInsets.all(10.0), // padding을 조절하여 아이콘의 크기를 조정
                        child: SvgPicture.asset(
                          'assets/images/searchIcon.svg',
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(
                          0xFF000000), // var(--black, #000) for input text
                      fontFamily: 'Pretendard Variable',
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      letterSpacing: -0.408,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  itemCount: searchQuery.isEmpty
                      ? allContacts.length
                      : filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = searchQuery.isEmpty
                        ? allContacts[index]
                        : filteredContacts[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0), // 양쪽에 간격 추가
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
          Positioned(
            // Correctly positioned within the Stack
            bottom: 10.0,
            right: 10.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(1, 1), // 오른쪽 아래로 그림자
                  ),
                ],
              ),
              child: ClipOval(
                child: InkWell(
                  onTap: () => _loadContactsFromPhone(),
                  child: SvgPicture.asset('assets/images/addContact.svg'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
