import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tabapp/findpath.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tabapp/sub/contactManager.dart';
import 'package:tabapp/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tabapp/sub/firstPage.dart';
import 'package:tabapp/colors.dart';
import 'package:image_cropper/image_cropper.dart';

GlobalKey _globalKey = GlobalKey();

class ContactInfo {
  final String name;
  final String phone;
  final String email;
  final String organization;
  final String position;
  final String photoUrl;

  ContactInfo({
    required this.name,
    required this.phone,
    required this.email,
    required this.organization,
    required this.position,
    required this.photoUrl,
  });
}

class BusinessCardWidget extends StatefulWidget {
  final ContactInfo contactInfo;

  BusinessCardWidget({required this.contactInfo});

  @override
  _BusinessCardWidgetState createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardWidget> {
  bool isEnlarged = false;


  TextStyle cardInfoStyle = const TextStyle(
            color: Colors.white, // Equivalent to #FFF or var(--white, #FFF)
            shadows: [
            Shadow(
            offset: Offset(0, 4), // 0px horizontal, 4px vertical
            blurRadius: 4, // 4px blur radius
            color: Color.fromRGBO(0, 0, 0, 0.25), // RGBA color with opacity
            ),
            ],
            fontFamily: 'PretendVariable', // Ensure the font is added to your pubspec.yaml
            fontSize: 18.0, // 16px font size
            fontStyle: FontStyle.normal, // Normal font style
            fontWeight: FontWeight.w500, // Font weight 500
            // You may adjust other properties like text height if necessary
            );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        double cardWidth = math.min(200, maxWidth);
        double cardHeight = cardWidth * (9 / 5);

        if (cardWidth > maxHeight) {
          cardWidth = maxHeight;
          cardHeight = cardWidth * (9 / 5);
        }

        return Center(
          child: RepaintBoundary( // Add RepaintBoundary here
            key: _globalKey, // Assign GlobalKey to RepaintBoundary
            child: Transform.scale(
              scale: isEnlarged ? 1.5 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB4C0EE),
                      Color(0xFF6586FF),
                    ],
                    stops: [0.2255, 0.6872],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                width: cardWidth,
                height: cardHeight,
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Text(widget.contactInfo.name, style:
                        const TextStyle(
                          color: Colors.white, // Equivalent to #FFF or var(--white, #FFF)
                          shadows: [
                            Shadow(
                              offset: Offset(0, 4), // 0px horizontal, 4px vertical
                              blurRadius: 4, // 4px blur radius
                              color: Color.fromRGBO(0, 0, 0, 0.25), // RGBA color with opacity
                            ),
                          ],
                          fontFamily: 'Pretendard Variable', // Ensure the font is added to your pubspec.yaml
                          fontSize: 30.0, // 30px font size
                          fontStyle: FontStyle.normal, // Normal font style
                          fontWeight: FontWeight.w700, // Font weight 700
                          height: 0.7333, // Line height 22px on 30px font size is roughly 0.7333
                          letterSpacing: -0.408, // -0.408px letter spacing
                        ),
                        ),

                        SizedBox(height: 20),
                        // Photo
                        FutureBuilder<bool>(
                          future: File(widget.contactInfo.photoUrl).exists(),
                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            // Debug print the photo URL
                            debugPrint('Photo URL: ${widget.contactInfo.photoUrl}');

                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.data == true) {
                                // File exists, display the image
                                return Image.file(
                                  File(widget.contactInfo.photoUrl),
                                  width: cardWidth,
                                  height: cardWidth / 1.2654320987654322,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                // File does not exist, display a placeholder or error widget
                                return Container(
                                  width: cardWidth,
                                  height: cardWidth / 1.2654320987654322,
                                  // child: Center( // This centers the child widget both horizontally and vertically
                                  //   child: Icon(
                                  //     Icons.image_not_supported,
                                  //     size: 60, // Adjust the size as needed
                                  //     color: Colors.blue, // Optional: to make the icon stand out
                                  //   ),
                                  // ),
                                );


                              }
                            } else {
                              // While the future is resolving, you can show a loader or an empty container
                              return CircularProgressIndicator(); // Loader widget
                            }
                          },
                        ),
                        SizedBox(width: 10),

                        // Contact Info
                        Expanded(
                          child:
                          Padding (
                            padding: const EdgeInsets.only(left: 0),
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center, // 여기를 추가하세요
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Text(widget.contactInfo.phone,style: cardInfoStyle,),
                                Text(widget.contactInfo.email,style: cardInfoStyle,),
                                Text(widget.contactInfo.organization,style: cardInfoStyle,),
                                Text(widget.contactInfo.position,style: cardInfoStyle,),
                              ],
                            ),),

                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ),
        );
      },
    );
  }
}

Future<ContactInfo> readContactInfo(String fileName) async {
  try {
    // Get the application directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName'; // Corrected file path

    // Create a file reference
    final file = File(filePath);

    // Check if the file exists before trying to read
    if (await file.exists()) {
      final contents = await file.readAsString();

      // Assuming the format is exactly as specified
      final lines = contents.split('\n');
      String photoUrl = lines[6].split(':')[1].trim();

      // Debug print the photo URL
      debugPrint('Photo URL: $photoUrl');

      return ContactInfo(
        name: lines[0].split(':')[1].trim(),
        phone: lines[1].split(':')[1].trim(),
        email: lines[2].split(':')[1].trim(),
        organization: lines[3].split(':')[1].trim(),
        position: lines[4].split(':')[1].trim(),
        photoUrl: photoUrl,
      );

    } else {
      // If the file does not exist, create a new file with default content
      print('File does not exist. Creating a new file: $filePath');
      final defaultContent = 'Name:\nPhone:\nEmail:\nOrganization:\nPosition:\nmemo:\nPhoto URL:';
      await file.writeAsString(defaultContent);

      // Return a new ContactInfo object with empty fields
      return ContactInfo(
        name: '',
        phone: '',
        email: '',
        organization: '',
        position: '',
        photoUrl: '',
      );
    }
  } catch (e) {
    // Handle any errors
    print('Error reading contact info: $e');
    rethrow; // Rethrow to allow calling code to handle the exception
  }
}



class ContactInputScreen extends StatefulWidget {
  @override
  _ContactInputScreenState createState() => _ContactInputScreenState();
}

// 명함 만들기
class _ContactInputScreenState extends State<ContactInputScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _photoUrl = '';
  String _randKey = '';

  @override
  void initState() {
    super.initState();
    _initializePhotoPath();
    _loadContactInfo();
  }

  Future<void> _initializePhotoPath() async {
    try {
      String directoryPath = await findPath; // Ensure findPath is an async function
      String folderPath = path.join(directoryPath, 'newProfileFolder');
      String fileName = "profile.jpg";
      String newPath = path.join(folderPath, fileName);

      setState(() {
        _photoUrl = newPath;
        _randKey = math.Random().nextInt(100).toString(); // Corrected line
      });
    } catch (e) {
      print("Error initializing photo path: $e");
    }
  }


  Future<void> _loadContactInfo() async {

      // Get the local path
      final filePath = 'information.txt';


      // If the file exists, read the contact information
      final contactInfo = await readContactInfo(filePath);
      _nameController.text = contactInfo.name;
      _phoneController.text = contactInfo.phone;
      _emailController.text = contactInfo.email;
      _organizationController.text = contactInfo.organization;
      _positionController.text = contactInfo.position;

  }

  Future<void> clearImageCache(String imagePath) async {
    final imageProvider = FileImage(File(imagePath));
    await imageProvider.evict();
  }


  Future<void> _selectPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File tempFile = File(pickedFile.path);
      String directoryPath = await findPath; // Make sure findPath() returns a valid directory path
      String folderPath = path.join(directoryPath, 'newProfileFolder');
      String fileName = "profile.jpg";
      String newPath = path.join(folderPath, fileName);

      try {
        final directory = Directory(folderPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        File newFile = await tempFile.copy(newPath);

        setState(() {
          _photoUrl = newPath;
          clearImageCache(newPath);
        });

      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }

  Future<File> _loadFile(String path) async {
    try {
      // Create a file instance from the path
      final file = File(path);

      // Check if the file exists
      if (await file.exists()) {
        // If the file exists, return it
        return file;
      } else {
        // If the file does not exist, throw an exception
        throw Exception('File not found');
      }
    } catch (e) {
      // If any error occurs, rethrow the exception
      rethrow;
    }
  }

  Future<void> _deleteProfilePhoto() async {
    String directoryPath = await findPath; // 이 함수는 비동기 함수여야 함
    String folderPath = path.join(directoryPath, 'newProfileFolder');
    String fileName = "profile.jpg";
    String newPath = path.join(folderPath, fileName);

    File file = File(newPath);

    if (await file.exists()) {
      try {
        await file.delete();
        // 파일 삭제 성공
      } catch (e) {
        // 파일 삭제 중 오류 발생
      }
    } else {
      // 파일이 존재하지 않음
    }
  }

  Future<bool> _overwriteOriginalFile(File original, File newFile) async {
    try {
      await original.writeAsBytes(await newFile.readAsBytes());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {


      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
          ],
          aspectRatio: const CropAspectRatio(
            ratioX: 1.2654, // Custom aspect ratio
            ratioY: 0.7902,
          ),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: '명함 수정',
                toolbarColor: AppColors.primaryBlue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                activeControlsWidgetColor: AppColors.primaryBlue,
                lockAspectRatio: true),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            )
          ]);

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      // Handle any exceptions here
      print('Error in _cropImage: $e');
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 명함 정보 입력",style: TextStyle(
          fontWeight: FontWeight.w500,
        ),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomTextField(
              controller: _nameController,
              labelText: '이름',
            ),
            CustomTextField(
              controller: _phoneController,
              labelText: '전화번호',
              keyboardType: TextInputType.phone,
            ),
            CustomTextField(
              controller: _organizationController,
              labelText: '조직',
            ),
            CustomTextField(
              controller: _positionController,
              labelText: '직급',
            ),
            CustomTextField(
              controller: _emailController,
              labelText: '이메일',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AspectRatio(
              aspectRatio: 1.2654 / 0.7902, // 원하는 비율
                child: FutureBuilder<File>(
                  future: _loadFile(_photoUrl.split('?')[0]), // Function to load the file
                  builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the file is loading, display a loading icon
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      // File is loaded, display the image
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), // border-radius: 10px;
                                ),
                                backgroundColor: Colors.white, // background: #FFF;
                                surfaceTintColor: Colors.transparent,
                                title: Text('사진 옵션',
                                  style: TextStyle(
                                    color: Color(0xFF476BEC), // Primary blue color
                                    fontFamily: 'Pretendard Variable',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.408,
                                    height: 1.0, // 100% line-height
                                  ),),
                                content: Text('원하는 작업을 선택하세요.',
                                  style: TextStyle(
                                    color: Colors.black, // Black color
                                    fontFamily: 'Pretendard Variable',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.408,
                                    height: 1.41667, // 141.667% line-height
                                  ),),
                                actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center, // Align buttons to the center
                                    children: <Widget>[

                                      ElevatedButton(
                                        child: Text('크롭'),
                                        style: ElevatedButton.styleFrom(
                                          primary: AppColors.primaryBlue,  // Background color
                                          onPrimary: Colors.white,  // Text color
                                          elevation: 5,  // Shadow elevation
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),  // Rounded corners
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),  // Button padding
                                        ),
                                        onPressed: () async {
                                          try {
                                            // 경로 설정
                                            String directoryPath = await findPath; // 비동기 함수가 필요
                                            String folderPath = path.join(directoryPath, 'newProfileFolder');
                                            String fileName = "profile.jpg";
                                            String newPath = path.join(folderPath, fileName);

                                            // 파일 인스턴스 생성
                                            File originalFile = File(newPath);

                                            // 이미지 수정 (예: 자르기)
                                            final File? croppedImage = await _cropImage(originalFile);
                                            if (croppedImage != null) {
                                              // 원본 파일에 수정된 이미지 덮어쓰기
                                              bool success = await _overwriteOriginalFile(originalFile, croppedImage);
                                              if (success) {
                                                print("Image successfully overwritten.");
                                                // 필요한 경우 상태 업데이트
                                                setState(() {
                                                  // 예: 이미지 목록 업데이트
                                                });
                                              } else {
                                                print("Failed to overwrite image.");
                                              }
                                            }
                                          } catch (e) {
                                            // 예외 처리
                                            print('Error processing image: $e');
                                          }
                                          clearImageCache(_photoUrl);
                                          setState(() {

                                          });
                                          // 버튼 2를 눌렀을 때의 작업
                                          Navigator.of(context).pop(); // 다이얼로그 닫기
                                        },
                                      ),

                                      const SizedBox(width:10),

                                      ElevatedButton(
                                        child: Text('삭제'),
                                        style: ElevatedButton.styleFrom(
                                          primary: AppColors.primaryBlue,  // Background color
                                          onPrimary: Colors.white,  // Text color
                                          elevation: 5,  // Shadow elevation
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),  // Rounded corners
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),  // Button padding
                                        ),
                                        onPressed: () async {
                                          await _deleteProfilePhoto();
                                          await clearImageCache(_photoUrl);
                                          setState(() {

                                          });

                                          Navigator.of(context).pop(); // 다이얼로그 닫기
                                        },
                                      ),
                                    ]
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Image.file(
                          snapshot.data!,
                          key: ValueKey(_randKey),
                          fit: BoxFit.cover, // Added BoxFit.cover here
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return AspectRatio(
                              aspectRatio: 1.2654 / 0.7902,
                              child: ClipRect(
                                child: Image.file(
                                  File(_photoUrl.split('?')[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      );

                    } else {
                      // If there is no data (file not found or other issues), display an error icon
                      return GestureDetector(
                        onTap: () {
                          _selectPhoto().then((_) async {
                            await clearImageCache(_photoUrl);
                          });
                          setState(() {

                          });
                        },
                        child: SvgPicture.asset('assets/images/addphotosquare.svg'),
                      );
                    }
                  },
                ),
              ),
            ),


            // Add other text fields for phone, memo, etc.
            ElevatedButton(
              onPressed: () {
                _selectPhoto().then((_) async {
                  await clearImageCache(_photoUrl);
                });
              },
              child: Text("사진 선택"),
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryBlue,  // Background color
                onPrimary: Colors.white,  // Text color
                elevation: 5,  // Shadow elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),  // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),  // Button padding
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text;
                String phone = _phoneController.text;
                String email = _emailController.text;
                String organization = _organizationController.text;
                String position = _positionController.text;

                String contactInfo = 'Name:$name\nPhone:$phone\nEmail:$email\nOrganization:$organization\nPosition:$position\nMemo:\nPhoto URL:$_photoUrl';
                debugPrint(contactInfo);

                try {
                  final directory = await getApplicationDocumentsDirectory();
                  final filePath = '${directory.path}/information.txt'; // Corrected file path

                  // Create a file reference
                  final file = File(filePath);

                  // Check if the file exists
                  if (!await file.exists()) {
                    // If the file does not exist, create it
                    await file.create(recursive: true);
                  }

                  // Write the information
                  await file.writeAsString(contactInfo);
                } catch (e) {
                  // Handle the error
                  print('Error saving contact info: $e');
                }

                // Close the dialog
                Navigator.of(context).pop();

              },
              child: Text("저장"),
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryBlue,  // Background color
                onPrimary: Colors.white,  // Text color
                elevation: 5,  // Shadow elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),  // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),  // Button padding
              ),
            ),

          ],
        ),
      ),
    );
  }
}




class Tab3State extends State {

  void _showInputScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactInputScreen()),
    ).then((_) {
      // When returning back to this screen, refresh the state
      setState(() {
        // Update your data here
      });
    });
  }

  void _showCardShare() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardShareScreen()),
    );
  }

  void _showCardRecieve() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardReceiveScreen()),
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: SubAppBar(
          titleRow: Column(
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/images/tab3logo.svg'),
                  SizedBox(width: 9.0),
                  Text('명함 공유하기'),
                ],
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
          Positioned(
            top: 20, // Adjust this value to move the widget higher
            left: 0,
            right: 0,
              child :Center(
                child: FutureBuilder<ContactInfo>(
                  future: readContactInfo('information.txt'), // Replace with your actual method to get contact info
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        // When data is loaded, display the business card
                        return BusinessCardWidget(contactInfo: snapshot.data!);
                      } else if (snapshot.hasError) {
                        // In case of an error
                        return Text('Error loading data: ${snapshot.error}');
                      } else {
                        // If data is not yet available
                        return Text('No data found');
                      }
                    } else {
                      // While data is loading, show a progress indicator
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(3, 3), // 오른쪽 아래로 그림자
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 라운드 정사각형 모서리 반경
                      child: InkWell(
                        onTap: () => _showInputScreen(),
                        child: SvgPicture.asset('assets/images/editinfo.svg'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Spacing between buttons
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(3, 3), // 오른쪽 아래로 그림자
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 라운드 정사각형 모서리 반경
                      child: InkWell(
                        onTap: () => _showCardShare(),
                        child: SvgPicture.asset('assets/images/share.svg'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Spacing between buttons
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gray.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(3, 3), // 오른쪽 아래로 그림자
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 라운드 정사각형 모서리 반경
                      child: InkWell(
                        onTap: () => _showCardRecieve(),
                        child: SvgPicture.asset('assets/images/scanQR.svg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class CardShareScreen extends StatefulWidget {
  @override
  _CardShareScreenState createState() => _CardShareScreenState();
}

class _CardShareScreenState extends State<CardShareScreen> {
  String data = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/information.txt';
    final file = File(filePath);
    if (await file.exists()) {
      String fileContents = await file.readAsString();
      // Split the contents into lines
      List<String> lines = fileContents.split('\n');

      // Check if there's more than one line
      if (lines.length > 1) {
        // Remove the last line
        lines.removeLast();
      }

      // Combine the remaining lines back into a single string
      String modifiedContents = lines.join('\n');

      setState(() {
        // Update the data with the modified contents
        data = modifiedContents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR로 명함 공유',style: TextStyle(
          fontWeight: FontWeight.w500,
        ),),
      ),
      body: Center(
        child: data.isNotEmpty
            ? QrImage(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
        )
            : Text('Loading or No data found!'),
      ),
    );
  }
}



/* ------------------------------------------------------------- */


class CardReceiveScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CardReceiveScreenState();
}

class _CardReceiveScreenState extends State<CardReceiveScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR 스캔해서 명함 저장",style: TextStyle(
          fontWeight: FontWeight.w500,
        ),),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> parseScannedData(String scannedData) {
    Map<String, String> cardData = {};
    List<String> lines = scannedData.split('\n');

    for (String line in lines) {
      List<String> parts = line.split(':');
      if (parts.length >= 2) {
        String key = parts[0].trim();
        String value = parts.sublist(1).join(':').trim(); // Join back if there were multiple ':' in the data.
        cardData[key] = value;
      }
    }
    return cardData;
  }

  void _onQRViewCreated(QRViewController controller) {

    this.controller = controller;
    bool hasNavigated = false;

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (!hasNavigated) {
          result = scanData;
          String? code = result?.code;

          if (code != null && code.isNotEmpty) {
            Map<String, String> cardData = parseScannedData(code);

            // Navigate to the business card screen with the parsed data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => getBusinessCardWidget(
                  name: cardData['Name'] ?? '',
                  phone: cardData['Phone'] ?? '',
                  email: cardData['Email'] ?? '',
                  organization: cardData['Organization'] ?? '',
                  position: cardData['Position'] ?? '',
                ),
              ),
            ).then((_) => hasNavigated = false); // Reset the flag when back to the previous screen

            hasNavigated = true;
            controller.pauseCamera(); // Optionally pause the camera
          } else {
            print('QR Code is empty, invalid, or scanning not complete.');
          }
        }
      });
    });
  }




  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class getBusinessCardWidget extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String organization;
  final String position;

  getBusinessCardWidget({
    required this.name,
    required this.phone,
    required this.email,
    required this.organization,
    required this.position,
  });

  @override
  _getBusinessCardWidgetState createState() => _getBusinessCardWidgetState();
}

class _getBusinessCardWidgetState extends State<getBusinessCardWidget> {
  final GlobalKey _globalKey = GlobalKey();
  final List<Contact> allContacts = [];
  late Contact contact;

  @override
  void initState() {
    super.initState();

    // Initialize contact here where you have access to widget
    contact = Contact(
      name: widget.name,
      phoneNumber: widget.phone,
      organization: widget.organization,
      position: widget.position,
      email: widget.email,
      memo: '',
    );
  }

  Future<bool> _onWillPop() async {
    int count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 2; // Replace 2 with the number of screens you want to go back
    });
    return true;
  }

  TextStyle cardInfoStyle = const TextStyle(
    color: Colors.white, // Equivalent to #FFF or var(--white, #FFF)
    shadows: [
      Shadow(
        offset: Offset(0, 4), // 0px horizontal, 4px vertical
        blurRadius: 4, // 4px blur radius
        color: Color.fromRGBO(0, 0, 0, 0.25), // RGBA color with opacity
      ),
    ],
    fontFamily: 'PretendVariable', // Ensure the font is added to your pubspec.yaml
    fontSize: 18.0, // 16px font size
    fontStyle: FontStyle.normal, // Normal font style
    fontWeight: FontWeight.w500, // Font weight 500
    // You may adjust other properties like text height if necessary
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double cardWidth = math.min(600, maxWidth);
        double cardHeight = cardWidth * (5 / 9);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  decoration: BoxDecoration(

                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB4C0EE), // 끝 색상
                        Color(0xFF6586FF), // 시작 색상
                      ],
                      stops: [0.1955, 0.843], // 색상의 위치
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: Offset(3, 1),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: Offset(0, -3),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],

                  ),

                  width: cardWidth,
                  height: cardHeight,
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          // Photo
                          Text(widget.name, style:
                          const TextStyle(
                            color: Colors.white, // Equivalent to #FFF or var(--white, #FFF)
                            shadows: [
                              Shadow(
                                offset: Offset(0, 4), // 0px horizontal, 4px vertical
                                blurRadius: 4, // 4px blur radius
                                color: Color.fromRGBO(0, 0, 0, 0.25), // RGBA color with opacity
                              ),
                            ],

                            fontFamily: 'Pretendard Variable', // Ensure the font is added to your pubspec.yaml
                            fontSize: 35,
                            fontStyle: FontStyle.normal, // Normal font style
                            fontWeight: FontWeight.w700, // Font weight 700
                            height: 0.7333, // Line height 22px on 30px font size is roughly 0.7333
                            letterSpacing: -0.408, // -0.408px letter spacing
                          ),),
                          // Contact

                          const Spacer(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[

                                  Text(widget.organization,style: cardInfoStyle,),
                                  Text(widget.position,style: cardInfoStyle,),
                                  Text(widget.phone,style: cardInfoStyle,),
                                  Text(widget.email,style: cardInfoStyle,),
                                ],
                              ),
                            ),
                          ],),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // This will space the buttons evenly
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF476BEC), // --primary-blue 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // border-radius: 15px;
                          ),
                        ),
                        onPressed: () {
                          saveRepaintBoundaryAsImage(_globalKey);
                        },
                        child: const Text('Save Business Card',
                          textAlign: TextAlign.center, // text-align: center;
                          style: TextStyle(
                            color: Colors.white, // var(--white, #FFF)
                            fontFamily: 'Pretendard Variable', // font-family: Pretendard Variable;
                            fontSize: 17, // font-size: 17px;
                            fontWeight: FontWeight.w500, // font-weight: 500;
                            height: 1.2941, // line-height: 129.412%;
                            letterSpacing: -0.408, // letter-spacing: -0.408px;
                          ),
                        )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF476BEC), // --primary-blue 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // border-radius: 15px;
                          ),
                        ),
                        onPressed: () {
                          try {
                            saveMyContacts();
                          } catch (e) {
                            print("Failed to save contacts: $e");
                          }
                        },
                        child: const Text('Save Contact',
                          textAlign: TextAlign.center, // text-align: center;
                          style: TextStyle(
                            color: Colors.white, // var(--white, #FFF)
                            fontFamily: 'Pretendard Variable', // font-family: Pretendard Variable;
                            fontSize: 17, // font-size: 17px;
                            fontWeight: FontWeight.w500, // font-weight: 500;
                            height: 1.2941, // line-height: 129.412%;
                            letterSpacing: -0.408, // letter-spacing: -0.408px;
                          ),
                        )
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
      )
    );
  }

  Future<void> saveRepaintBoundaryAsImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get the directory to store the image
      final directory = await findPath;

      // Generate a random string
      var rng = math.Random();
      String randomString = DateTime.now().millisecondsSinceEpoch.toString() + rng.nextInt(10000).toString();

      final imagePath = '${directory}/business_card_$randomString.jpg';
      final imageFile = File(imagePath);

      // Save the image to the file
      await imageFile.writeAsBytes(pngBytes);

      print('Image saved to $imagePath');
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> saveMyContacts() async {
    List<Contact> loadedContacts = []; // Declare it outside the try-catch block

    try {
      loadedContacts = await ContactManager.loadContacts();
      if (loadedContacts.isEmpty) {
        // Add default contacts. This function should update 'loadedContacts'
        // loadedContacts = _addDefaultContacts.defaultContacts;
      } else {
        loadedContacts.add(contact); // Assuming 'contact' is defined and valid
      }
    } catch (e) {
      print("Error loading contacts: $e");
    }

    // Use ContactManager to save the contacts
    await ContactManager.saveContacts(loadedContacts);
    print('Contacts have been saved successfully');
  }

}