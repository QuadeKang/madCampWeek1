import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:tabapp/findpath.dart';
import 'package:tabapp/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tabapp/main.dart';
import 'package:tabapp/customDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tab2State extends State {
  List<File> images = [];
  bool showButtons = false; // State to control button visibility
  late int selectedImageIndex; // To keep track of the selected image
  int? selectedPhotoIndex;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // 이미지 파일 경로의 순서를 저장
  Future<void> _saveImageOrder() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> imagePathList = images.map((image) => image.path).toList();
    await prefs.setStringList('imageOrder', imagePathList);
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedImagePathList = prefs.getStringList('imageOrder') ?? [];

    final String directoryPath = await findPath;
    final directory = Directory(directoryPath);
    List<FileSystemEntity> entries = await directory.list().toList();

    List<File> imageFiles = [];

    // 저장된 이미지 경로 리스트가 있는 경우
    for (String path in savedImagePathList) {
      final file = File(path);
      if (await file.exists()) {
        imageFiles.add(file);
      }
    }

    // 저장된 경로 리스트가 비어있거나 파일이 존재하지 않는 경우
    if (imageFiles.isEmpty) {
      List<FileSystemEntity> filteredEntries = entries.where((file) {
        return file.path != '$findPath/profile.jpg';
      }).toList();

      // Filter out only image files
      List<File> tempImageFiles = filteredEntries.whereType<File>().where((file) {
        String extension = path.extension(file.path).toLowerCase();
        return ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension);
      }).toList();

      // Sort the image files by modification date in descending order
      Map<File, DateTime> fileModificationTimes = {};
      for (File file in tempImageFiles) {
        var stat = await file.stat();
        fileModificationTimes[file] = stat.modified;
      }

      tempImageFiles.sort((a, b) {
        return fileModificationTimes[b]!.compareTo(fileModificationTimes[a]!);
      });

      imageFiles = tempImageFiles;
    }

    // Update the state with the list of image files
    setState(() {
      images = imageFiles;
      print("Images loaded: ${images.length}");
    });
  }


  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final String directoryPath = await findPath;
      final String fileName = photo.path.split(Platform.pathSeparator).last;
      final File localImage =
          await File(photo.path).copy('$directoryPath/$fileName');

      setState(() {
        images.insert(
            0, localImage); // Add the new image at the start of the list
        _sortImages(); // Sort the images list
      });
    }
  }

  Future<void> _getPhotos() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? photos =
        await _picker.pickMultiImage(); // Pick multiple images

    if (photos != null && photos.isNotEmpty) {
      final String localPath =
          await findPath; // Assuming _localPath is a function returning the path as String

      for (final photo in photos) {
        final String fileName = path.basename(photo.path);
        final File localImage =
            await File(photo.path).copy('$localPath/$fileName');

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

  Future<bool> _overwriteOriginalFile(
      File originalFile, File croppedFile) async {
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
      backgroundColor: AppColors.backgroundGray,
      appBar: SubAppBar(
        titleRow: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/images/tab2logo.svg'),
                SizedBox(width: 9.0),
                Text('명함 모아보기'),
              ],
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),

      body: Stack(
        children: [
          ReorderableListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Column(
                key: ValueKey(images[index]), // 고유한 key 제공
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedPhotoIndex == index) {
                          showButtons = !showButtons;
                          if (!showButtons) {
                            selectedPhotoIndex = null;
                          }
                        } else {
                          showButtons = true;
                          selectedPhotoIndex = index;
                        }
                      });
                      _scrollToSelected();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        decoration: selectedPhotoIndex == index && showButtons
                            ? BoxDecoration(
                          border: Border.all(
                            color: AppColors.icongray,
                            width: 3.0,
                          ),
                        )
                            : null,
                        child: AspectRatio(
                          aspectRatio: 9 / 5,
                          child: Image.file(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showButtons && selectedPhotoIndex == index)
                    _buildButtonOverlay(),
                ],
              );
            },
            // ReorderableListView의 onReorder 콜백
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final image = images.removeAt(oldIndex);
                images.insert(newIndex, image);
                _saveImageOrder(); // 변경된 순서를 저장
              });
            },
            scrollController: scrollController,
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gray.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(3, 3), // 오른쪽 아래로 그림자
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: InkWell(
                      onTap: () => _takePicture(),
                      child: SvgPicture.asset('assets/images/takephoto.svg'),
                    ),
                  ),
                ),
                SizedBox(width: 1,),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:AppColors.gray.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(3,3), // 오른쪽 아래로 그림자
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: InkWell(
                      onTap: () => _getPhotos(),
                      child: SvgPicture.asset('assets/images/photoadd.svg'),
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

  void _scrollToSelected() {
    if (selectedPhotoIndex != null && scrollController.hasClients) {
      final offset = selectedPhotoIndex! * 200.0; // 예상 아이템 높이
      scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


  Widget _buildButtonOverlay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 5),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  // Check if a photo is selected
                  if (selectedPhotoIndex != null &&
                      selectedPhotoIndex! < images.length) {
                    // Call the cropImage function and pass the selected image
                    final File? croppedImage =
                        await _cropImage(images[selectedPhotoIndex!]);
                    if (croppedImage != null) {
                      bool success = await _overwriteOriginalFile(
                          images[selectedPhotoIndex!], croppedImage);
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
              child: Text(
                '수정하기',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryBlue,
                onPrimary: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 5, right: 10),
            child: ElevatedButton(
              onPressed: () async {
                // Show confirmation dialog
                final result = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: '명함 삭제',
                      content: '삭제하시겠습니까?',
                      onConfirm: () => Navigator.of(context).pop(true),
                      onCancel: () => Navigator.of(context).pop(false),
                    );
                  },
                );

                // If 'Yes' was pressed, delete the photo file and remove it from the list
                if (result == true) {
                  File photoFile = images[selectedPhotoIndex!];
                  await photoFile.delete(); // Delete the file from storage
                  setState(() {
                    images
                        .removeAt(selectedPhotoIndex!); // Remove from the list
                    showButtons = false;
                    selectedPhotoIndex = null;
                  });
                }
              },
              child: Text(
                '명함 삭제',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryBlue,
                onPrimary: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
