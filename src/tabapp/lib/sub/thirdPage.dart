import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tabapp/findpath.dart';

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

class BusinessCardWidget extends StatelessWidget {
  final ContactInfo contactInfo;

  BusinessCardWidget({required this.contactInfo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the size for the business card
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        double cardWidth = math.min(600, maxWidth);
        double cardHeight = cardWidth * (5 / 9); // Set the ratio to 5:9

        // Ensure the card fits within the screen when rotated
        if (cardWidth > maxHeight) {
          cardWidth = maxHeight;
          cardHeight = cardWidth * (5 / 9);
        }

        return Center(
          child: Transform.rotate(
            angle: math.pi / 2, // Rotate 90 degrees
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
                      if (contactInfo.photoUrl.isNotEmpty)
                        Image.file(
                          File(contactInfo.photoUrl),
                          width: 100.0, // Adjust the width as needed
                          height: double.infinity, // Adjust the height as needed
                          fit: BoxFit.cover,
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
                                Text(contactInfo.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text("Tel : ${contactInfo.phone}"),
                                Text("Email : ${contactInfo.email}"),
                                Text("Organization : ${contactInfo.organization}"),
                                Text("Position : ${contactInfo.position}"),
                              ],
                            ),),

                      ),
                    ],
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
    debugPrint(filePath);

    // Create a file reference
    final file = File(filePath);

    // Check if the file exists before trying to read
    if (await file.exists()) {
      final contents = await file.readAsString();

      // Assuming the format is exactly as specified
      final lines = contents.split('\n');
      return ContactInfo(
        name: lines[0].split(':')[1].trim(),
        phone: lines[1].split(':')[1].trim(),
        email: lines[2].split(':')[1].trim(),
        organization: lines[3].split(':')[1].trim(),
        position: lines[4].split(':')[1].trim(),
        photoUrl: lines[5].split(':')[1].trim(),
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

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
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


  Future<void> _selectPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File tempFile = File(pickedFile.path);
      String directoryPath = await findPath; // Assuming findPath() returns a valid directory path
      String folderPath = path.join(directoryPath, 'profile');
      String fileName = "profile.jpg";
      String newPath = path.join(folderPath, fileName);

      try {
        final file = File(folderPath);
        if (await file.exists()) {
          // If the path is a file, you could choose to delete it or use another path
          // WARNING: Deleting a file is irreversible
          // await file.delete();

          // Alternatively, change the path
          folderPath = path.join(directoryPath, 'newProfileFolder');
          newPath = path.join(folderPath, fileName);
        }

        final directory = Directory(folderPath);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        File newFile = await tempFile.copy(newPath);

        setState(() {
          _photoUrl = newFile.path;
        });
      } catch (e) {
        print("Error: $e");
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
                File(_photoUrl),
                width: 100.0, // You can adjust the size
                fit: BoxFit.cover,
              ),
            ),

            // Add other text fields for phone, memo, etc.
            ElevatedButton(
              onPressed: _selectPhoto,
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
                String pathUrl = '/data/user/0/com.example.tabapp/app_flutter/business_card/newProfileFolder/profile.jpg';

                String contactInfo = 'Name:$name\nPhone:$phone\nEmail:$email\nOrganization:$organization\nPosition:$position\nMemo:\nPhoto URL:$pathUrl';
                debugPrint(contactInfo);

                try {
                  // Get the local path
                  final filePath = '/data/user/0/com.example.tabapp/app_flutter/business_card/information.txt';

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

                setState(() {

                });
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
    final photoUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactInputScreen()),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<ContactInfo>(
          future: readContactInfo('information.txt'), // Replace with your filename
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showInputScreen, // Make sure this function is defined
        child: Icon(Icons.add),
      ),
    );
  }
}
