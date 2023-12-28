import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  final businessCardDir = Directory(path.join(directory.path, 'business_card'));

  if (!await businessCardDir.exists()) {
    await businessCardDir.create(recursive: true);
  }

  return businessCardDir.path;
}

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

class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(contact.photoUrl),
              radius: 30.0,
            ),
            SizedBox(height: 8.0),
            Text(
              contact.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text(
              contact.organization,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.phone, size: 16.0),
                SizedBox(width: 4.0),
                Text(contact.phoneNumber),
              ],
            ),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.badge, size: 16.0),
                SizedBox(width: 4.0),
                Text(contact.position),
              ],
            ),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.email, size: 16.0),
                SizedBox(width: 4.0),
                Text(contact.email),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
        title: Text('PhoneBook'), // Tab1 페이지의 타이틀
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
                  Icon(Icons.remove_circle),

                ],
              ),
              ContactCard(
                contact: Contact(
                  name: 'Quade Kang',
                  phoneNumber: '010-5962-1685',
                  memo: 'Junior Developer',
                  organization: 'madCamp',
                  position: 'Junior Developer',
                  email: 'quade.kang@gmail.com',
                  photoUrl: 'https://via.placeholder.com/150',
                ),
              ),

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
  bool showButtons = false; // State to control button visibility
  late int selectedImageIndex; // To keep track of the selected image
  int? selectedPhotoIndex;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final String directoryPath = await _localPath;
    final directory = Directory(directoryPath);
    List<FileSystemEntity> entries = await directory.list().toList();

    // Filter out only image files
    List<File> imageFiles = entries.whereType<File>().where((file) {
      String extension = path.extension(file.path).toLowerCase();
      return ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension);
    }).toList();

    // Get modification times for each file
    Map<File, DateTime> fileModificationTimes = {};
    for (File file in imageFiles) {
      var stat = await file.stat();
      fileModificationTimes[file] = stat.modified;
    }

    // Sort the image files by modification date in descending order
    imageFiles.sort((a, b) {
      return fileModificationTimes[b]!.compareTo(fileModificationTimes[a]!);
    });

    // Update the state with the sorted list of image files
    setState(() {
      images = imageFiles;
    });
  }

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final String directoryPath = await _localPath;
      final String fileName = photo.path.split(Platform.pathSeparator).last;
      final File localImage = await File(photo.path).copy('$directoryPath/$fileName');

      setState(() {
        images.insert(0, localImage); // Add the new image at the start of the list
        _sortImages(); // Sort the images list
      });
    }
  }

  Future<void> _getPhotos() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? photos = await _picker.pickMultiImage(); // Pick multiple images

    if (photos != null && photos.isNotEmpty) {
      final String localPath = await _localPath; // Assuming _localPath is a function returning the path as String

      for (final photo in photos) {
        final String fileName = path.basename(photo.path);
        final File localImage = await File(photo.path).copy('$localPath/$fileName');

        setState(() {
          images.add(localImage);
        });
      }
    }
  }

  void _sortImages() {
    images.sort((a, b) {
      return b.lastModifiedSync().compareTo(a.lastModifiedSync());
    });
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
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _getPhotos,
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            itemCount: images.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
            itemBuilder: (context, index) {
              bool isSelected = selectedPhotoIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedPhotoIndex == index) {
                      // Toggle visibility if the same photo is clicked again
                      showButtons = !showButtons;
                      if (!showButtons) {
                        // Reset selectedPhotoIndex when buttons are hidden
                        selectedPhotoIndex = null;
                      }
                    } else {
                      // Show buttons and update selected photo index
                      showButtons = true;
                      selectedPhotoIndex = index;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: selectedPhotoIndex == index
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                  ),
                  child: Image.file(images[index]),
                ),
              );
            },
          ),
          if (showButtons) _buildButtonOverlay(),
        ],
      ),
    );
  }


  Widget _buildButtonOverlay() {
    return Positioned(
      bottom: 0, // Position above the BottomNavigationBar
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 5),
              child: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Photo'),
                        content: Text('Do you want to delete this photo?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );

                  // If 'Yes' was pressed, delete the photo file and remove it from the list
                  if (result == true) {
                    File photoFile = images[selectedPhotoIndex!];
                    await photoFile.delete(); // Delete the file from storage
                    setState(() {
                      images.removeAt(selectedPhotoIndex!); // Remove from the list
                      showButtons = false;
                      selectedPhotoIndex = null;
                    });
                  }
                },
                child: Text('Delete Photo'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Handle Button 2 press
                  setState(() {
                    // Implement your logic for Button 2
                    showButtons = false;
                  });
                },
                child: Text('Button 2'),
              ),
            ),
          ),
        ],

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