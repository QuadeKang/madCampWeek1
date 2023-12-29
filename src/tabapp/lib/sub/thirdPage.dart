import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';


class ContactInputScreen extends StatefulWidget {
  @override
  _ContactInputScreenState createState() => _ContactInputScreenState();
}

class _ContactInputScreenState extends State<ContactInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Add other controllers for phone, memo, organization, position, email
  String _photoUrl = '';

  void _selectPhoto() async {
    // Implement photo selection logic
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoUrl = pickedFile.path; // Or copy the file and use the new path
      });
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

                String contactInfo = 'Name: $name\nPhone: $phone\nEmail: $email\nOrganization: $organization\nPosition: $position\nPhoto URL: $_photoUrl';

                // Get the local path
                final directory = await getApplicationDocumentsDirectory();
                final path = directory.path;

                // Create a file to write
                final file = File('$path/information.txt');

                // Write the information
                await file.writeAsString(contactInfo);

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
  String _photoUrl = '';

  void _showInputScreen() async {
    final photoUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactInputScreen()),
    );

    if (photoUrl != null) {
      setState(() {
        _photoUrl = photoUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Display your content here
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInputScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
