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

  void _tapBig() {
    setState(() {
      isEnlarged = !isEnlarged; // Toggle the boolean value
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        double cardWidth = math.min(600, maxWidth);
        double cardHeight = cardWidth * (5 / 9);

        if (cardWidth > maxHeight) {
          cardWidth = maxHeight;
          cardHeight = cardWidth * (5 / 9);
        }

        return GestureDetector(
          onTap: _tapBig,
          child: Center(
            child: RepaintBoundary( // Add RepaintBoundary here
            key: _globalKey, // Assign GlobalKey to RepaintBoundary
              child: Transform.rotate(
                angle: math.pi / 2,
                child: Transform.scale(
                  scale: isEnlarged ? 1.5 : 1.0,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                                      width: 100.0,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    // File does not exist, display a placeholder or error widget
                                    return Container(
                                      width: 100,
                                      height: double.infinity,
                                      child: Center( // This centers the child widget both horizontally and vertically
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 60, // Adjust the size as needed
                                          color: Colors.blue, // Optional: to make the icon stand out
                                        ),
                                      ),
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
                                padding: const EdgeInsets.only(left: 16.0),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.center, // 여기를 추가하세요
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(widget.contactInfo.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text("Tel : ${widget.contactInfo.phone}"),
                                    Text("Email : ${widget.contactInfo.email}"),
                                    Text("Organization : ${widget.contactInfo.organization}"),
                                    Text("Position : ${widget.contactInfo.position}"),
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

            TextField(
              controller: _nameController,
              cursorColor: AppColors.primaryBlue,
              decoration: const InputDecoration(
                  hintText: "이름",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue,width: 2.0),
                ),
              ),
            ),

            TextField(
              controller: _phoneController,
              cursorColor: AppColors.primaryBlue,
              decoration: const InputDecoration(hintText: "전화번호",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue,width: 2.0),
                ),),
            ),

            TextField(
              controller: _emailController,
              cursorColor: AppColors.primaryBlue,
              decoration: const InputDecoration(hintText: "이메일",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue,width: 2.0),
                ),),
            ),

            TextField(
              controller: _organizationController,
              cursorColor: AppColors.primaryBlue,
              decoration: const InputDecoration(hintText: "조직",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue,width: 2.0),
                ),),
            ),

            TextField(
              controller: _positionController,
              cursorColor: AppColors.primaryBlue,
              decoration: const InputDecoration(hintText: "직급",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryBlue,width: 2.0),
                ),),
            ),
            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FutureBuilder<File>(
                future: _loadFile(_photoUrl.split('?')[0]), // Function to load the file
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While the file is loading, display a loading icon
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    // File is loaded, display the image
                    return Image.file(
                      snapshot.data!,
                      key: ValueKey(_randKey), // Using ValueKey to ensure the widget rebuilds when the key changes
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        // If an error occurs, reopen the existing image
                        return Image.file(
                          File(_photoUrl.split('?')[0]), // Reopen the existing image
                        );
                      },
                    );
                  } else {
                    // If there is no data (file not found or other issues), display an error icon
                    return SvgPicture.asset('assets/images/addphotosquare.svg');
                  }
                },
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
            Center(
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
            SizedBox(height: 20), // Spacing between buttons
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:AppColors.gray.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(1, 1), // 오른쪽 아래로 그림자
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: InkWell(
                        onTap: () => _showInputScreen(),
                        child: SvgPicture.asset('assets/images/editinfo.svg'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Spacing between buttons
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:AppColors.gray.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(1, 1), // 오른쪽 아래로 그림자
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: InkWell(
                        onTap: () => _showCardShare(),
                        child: SvgPicture.asset('assets/images/share.svg'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Spacing between buttons
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:AppColors.gray.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(1, 1), // 오른쪽 아래로 그림자
                        ),
                      ],
                    ),
                    child: ClipOval(
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
                  width: cardWidth,
                  height: cardHeight,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Photo
                          SizedBox(width: 10),

                          // Contact Info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("Tel: ${widget.phone}"),
                                  Text("Email: ${widget.email}"),
                                  Text("Organization: ${widget.organization}"),
                                  Text("Position: ${widget.position}"),
                                ],
                              ),
                            ),
                          ),
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
                        onPressed: () {
                          saveRepaintBoundaryAsImage(_globalKey);
                        },
                        child: Text('Save Business Card'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            saveMyContacts();
                          } catch (e) {
                            print("Failed to save contacts: $e");
                          }
                        },
                        child: Text('Save Contact'),
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