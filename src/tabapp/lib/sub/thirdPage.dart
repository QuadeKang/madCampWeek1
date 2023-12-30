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
                                    return Icon(Icons.image_not_supported); // Placeholder icon
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
      // Handle the case where the file does not exist
      print('File does not exist: $filePath');
      throw FileSystemException('File not found', filePath);
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
        _randKey = math.Random().nextInt(100) as String;
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Contact Information"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),

            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(hintText: "Phone"),
            ),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: "E-mail"),
            ),

            TextField(
              controller: _organizationController,
              decoration: const InputDecoration(hintText: "Organization"),
            ),

            TextField(
              controller: _positionController,
              decoration: const InputDecoration(hintText: "Position"),
            ),
            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.file(
                File(_photoUrl.split('?')[0]), // Split to get the actual file path without the query parameter
                key: ValueKey(_randKey), // Using ValueKey to ensure the widget rebuilds when the key changes
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Image.file(File(_photoUrl)); // Placeholder widget for errors
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
              child: Text("Select Photo"),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,  // Background color
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
                String phothUrl = '';

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
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,  // Background color
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
    );

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
        body: Center(
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
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton(
              onPressed: _showInputScreen,
              child: Icon(Icons.add),
              heroTag: 'btn1', // Ensure each button has a unique heroTag
            ),
          ),
          Positioned(
            right: 10,
            bottom: 130,
            child: FloatingActionButton(
              onPressed:_showCardShare,
              child: Icon(Icons.share),
              heroTag: 'btn2',
            ),
          ),
          Positioned(
            right: 10,
            bottom: 70,
            child: FloatingActionButton(
              onPressed:_showCardRecieve,
              child: Icon(Icons.download),
              heroTag: 'btn3',
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
        title: Text('Card Share Screen'),
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
        title: Text('Card Receive Screen'),
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
                          // Add your action for Button B
                        },
                        child: Text('Button B'),
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
}

