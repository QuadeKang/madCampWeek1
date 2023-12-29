import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:tabapp/findpath.dart';

class Tab2 extends StatefulWidget {
  @override
  Tab2State createState() => Tab2State();
}

class Tab2State extends State<Tab2> {
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
    final String directoryPath = await findPath;
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
      final String directoryPath = await findPath;
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
      final String localPath = await findPath; // Assuming _localPath is a function returning the path as String

      for (final photo in photos) {
        final String fileName = path.basename(photo.path);
        final File localImage = await File(photo.path).copy('$localPath/$fileName');

        setState(() {
          images.add(localImage);
        });
      }
    }
  }


  Future<File?> _cropImage(File imageFile) async {

    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
          ],
          aspectRatio: CropAspectRatio(
            ratioX: 9, // Custom aspect ratio
            ratioY: 5,
          ),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            )
          ]
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      // Handle any exceptions here
      print('Error in _cropImage: $e');
    }
    return null;
  }

  Future<bool> _overwriteOriginalFile(File originalFile, File croppedFile) async {
    try {
      // Check if the cropped file exists
      if (await croppedFile.exists()) {
        // Copy the cropped file to the original file path
        await croppedFile.copy(originalFile.path);
        return true;
      }
    } catch (e) {
      print("Error in overwriting file: $e");
    }
    return false;
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              // You can adjust childAspectRatio to match the ratio you want.
              // The ratio is width / height. So for a 9:5 ratio, it would be 9 / 5.
              childAspectRatio: 9 / 5,
            ),
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
                        ? Border.all(color: Colors.grey, width: 3)
                        : null,
                  ),
                  child:Stack (children: <Widget>[
                    Padding (
                      padding: EdgeInsets.all(8.0),
                      child:
                      Image.file(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                  ],),

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
                onPressed: () async {
                  try {
                    // Check if a photo is selected
                    if (selectedPhotoIndex != null && selectedPhotoIndex! < images.length) {
                      // Call the cropImage function and pass the selected image
                      final File? croppedImage = await _cropImage(images[selectedPhotoIndex!]);
                      if (croppedImage != null) {
                        bool success = await _overwriteOriginalFile(images[selectedPhotoIndex!], croppedImage);
                        if (success) {
                          print("Image successfully overwritten.");
                          setState(() {
                            // Update the image list with the cropped image
                            images[selectedPhotoIndex!] = croppedImage;
                          });
                        } else {
                          print("Failed to overwrite image.");
                        }

                      }
                    }
                  } catch (e) {
                    // Handle any exceptions here
                    print('Error cropping image: $e');
                  }
                  // Hide the buttons after the operation
                  setState(() {
                    showButtons = false;
                  });
                },
                child: Text('Edit Photo'),
              ),
            ),
          ),
        ],

      ),
    );
  }
}
