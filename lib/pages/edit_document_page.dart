import 'dart:io';

import 'package:docscanner/components/my_button.dart';
import 'package:docscanner/components/my_custom_home_page_transition.dart';
import 'package:docscanner/components/my_pdf_view.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/pages/document_page.dart';
import 'package:docscanner/pages/home_page.dart';
import 'package:docscanner/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class EditDocumentPage extends StatefulWidget {
  final String documentName;
  final String uId;
  final List<String> currentListDocumentValues;
  const EditDocumentPage({
    super.key,
    required this.documentName,
    required this.uId,
    required this.currentListDocumentValues,
  });

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

double screenHeight = 0.0;
double screenWidth = 0.0;

class _EditDocumentPageState extends State<EditDocumentPage> {
  late List<String> _editedImages;
  File? imageFile;
  final picker = ImagePicker();
  List<dynamic> updatedListDocumentValues = [];
  void back() {
    Navigator.pop(context);
  }

  void onSaveChanges() async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF4BBFF),
          ),
        ),
      );
      await updateImageOrder(
        widget.uId,
        widget.documentName,
        _editedImages,
        widget.currentListDocumentValues,
      );
      // Show success message or navigate back to previous screen
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MyCustomHomePageRoute(
          HomePage(),
        ),
      );
      mySnackBar(context, 'Image order updated successfully', Colors.green);
    } catch (e) {
      Navigator.pop(context);
      mySnackBar(context, 'Failed to update image order', Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _editedImages = List.from(widget.currentListDocumentValues);
  }

  _cropImage(File pickedImage) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ]
          : [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
            ],
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: const Color(0xFFF4BBFF),
          toolbarTitle: "Crop the selected image",
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: const Color(0xFFF4BBFF),
        ),
        IOSUiSettings(
          title: "Crop the selected image",
          aspectRatioLockEnabled: false,
        )
      ],
    );

    //image cropped
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        imageFile = File(croppedFile.path);
      });

      try {
        showDialog(
          context: context,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF4BBFF),
            ),
          ),
        );

        final imageUploadSuccess = await addNewImage(
          context,
          widget.documentName,
          imageFile!,
          widget.uId,
        );
        if (imageUploadSuccess) {
          // Navigator.pop(context);
          mySnackBar(
            context,
            'image added successfully',
            Colors.green,
          );
          // getDocumentValue(widget.uId);
          Navigator.pushReplacement(
            context,
            MyCustomHomePageRoute(
              DocumentPage(
                documentName: widget.documentName,
                uId: widget.uId,
              ),
            ),
          );
        } else {
          mySnackBar(
            context,
            'Failed to create document',
            Colors.red,
          );
        }
      } catch (e) {
        mySnackBar(context, e.toString(), Colors.red);
      }
    }
  }

  _imagePickFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 100)
        .then((pickedImage) {
      if (pickedImage != null) {
        _cropImage(File(pickedImage.path));
      }
    });
  }

  _imagePickFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 100)
        .then((pickedImage) {
      if (pickedImage != null) {
        _cropImage(File(pickedImage.path));
      }
    });
  }

  Future _displayAddNewImageBottomSheet(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.5),
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Select Image From",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  Column(
                    children: [
                      MyButton(
                        height: 55,
                        width: double.infinity,
                        buttonText: "Gallery",
                        onTap: () {
                          Navigator.pop(context);
                          _imagePickFromGallery();
                        },
                        buttonColor: const Color(0xFFF4BBFF),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      MyButton(
                        height: 55,
                        width: double.infinity,
                        buttonText: "Camera",
                        onTap: () {
                          _imagePickFromCamera();
                        },
                        buttonColor: const Color(0xFFF4BBFF),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2.5),
            ),
            child: MyButton(
              height: 55,
              width: 130,
              buttonText: "Add Image",
              onTap: () {
                _displayAddNewImageBottomSheet(context);
              },
              buttonColor: const Color(0xFFF4BBFF),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: back,
                        icon: const Icon(
                          color: Color(0xFFF4BBFF),
                          Icons.arrow_back_rounded,
                          size: 32,
                        ),
                      ),
                      Text(
                        "Edit Document",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onSaveChanges,
                    icon: const Icon(
                      size: 27,
                      color: Color(0xFFF4BBFF),
                      Icons.save_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Expanded(
                child: ReorderableGridView.builder(
                  onReorder: ((oldIndex, newIndex) {
                    setState(() {
                      final String item = _editedImages.removeAt(oldIndex);
                      if (newIndex >= _editedImages.length) {
                        _editedImages.add(item);
                      } else {
                        _editedImages.insert(newIndex, item);
                      }
                    });
                  }),

                  // onReorder: ((oldIndex, newIndex) {
                  //   setState(() {
                  //     final String item = _editedImages.removeAt(oldIndex);
                  //     if (newIndex >= _editedImages.length) {
                  //       _editedImages.add(item);
                  //     } else {
                  //       _editedImages.insert(newIndex, item);
                  //     }
                  //   });
                  // }),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: _editedImages.length,
                  itemBuilder: (context, index) {
                    String imageName = _editedImages[index];
                    final uId = widget.uId;
                    final documentName = widget.documentName;
                    String imageUrl =
                        '$uId/documentName/$documentName/$imageName'; // Replace with your Firebase Storage bucket URL
                    return FutureBuilder(
                      future: FirebaseStorage.instance
                          .ref()
                          .child(imageUrl)
                          .getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(
                                color: Color(0xFFF4BBFF),
                              ),
                            ),
                          ); // Display loading indicator while image is loading
                        }
                        final imageUrl = snapshot.data.toString();
                        return MyPdfView(
                          imageUrl: imageUrl,
                        );
                      },
                      key: UniqueKey(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
