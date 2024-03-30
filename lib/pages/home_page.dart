import 'dart:io';
import 'package:docscanner/components/my_button.dart';
import 'package:docscanner/components/my_custom_home_page_transition.dart';
import 'package:docscanner/components/my_document_view.dart';
import 'package:docscanner/components/my_icon_button.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/components/my_textfield.dart';
import 'package:docscanner/pages/document_page.dart';
import 'package:docscanner/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

double screenHeight = 0.0;
double screenWidth = 0.0;

// TextEditingController _documentNameController = TextEditingController();

class _HomePageState extends State<HomePage> {
  List<dynamic> listDocumentNames = [];
  late TextEditingController _documentNameController;
  File? imageFile;
  final picker = ImagePicker();
  final String uid = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  void initState() {
    super.initState();
    _documentNameController = TextEditingController();
    getDocumentName(uid);
  }

  @override
  void dispose() {
    _documentNameController.dispose();
    super.dispose();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _showMyDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF4BBFF),
          title: const Text(
            'Alert',
            style: TextStyle(
              color: Color(0xFF2D2A2E),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "MontserratMedium",
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Would you like to delete this credential nigga?',
                  style: TextStyle(
                    color: Color(0xFF2D2A2E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "MontserratMedium",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2A2E),
                  fontWeight: FontWeight.w700,
                  fontFamily: "MontserratMedium",
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontFamily: "MontserratMedium",
                ),
              ),
              onPressed: () async {},
            ),
            SizedBox(
              width: screenWidth * 0.001,
            )
          ],
        );
      },
    );
  }

  void getDocumentName(String uid) async {
    final userId = uid;
    List<dynamic> results = await getDocumentNames(userId);
    if (mounted) {
      setState(() {
        listDocumentNames = results;
      });
    }

    print("DocumentListDocument $listDocumentNames");
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

    if (croppedFile != null) {
      imageCache.clear();
      if (mounted) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
      }

      try {
        showDialog(
          context: context,
          builder: (context) {
            if (!mounted) {
              return Container(); // Return empty container if widget is disposed
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC3BBBB),
              ),
            );
          },
        );

        final imageUploadSuccess = await createNewDocument(
          context,
          _documentNameController.text.trim(),
          imageFile!,
          uid,
        );

        Navigator.pop(context); // Close the dialog

        if (mounted) {
          if (imageUploadSuccess) {
            mySnackBar(
              context,
              'Document created successfully',
              Colors.green,
            );
            getDocumentName(uid);
          } else {
            mySnackBar(
              context,
              'Failed to create document',
              Colors.red,
            );
          }
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

  Future _displayRegisterBottomSheet(BuildContext context) {
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
                        "Add New Document",
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
                  const Row(
                    children: [
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        "Document Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  MyTextField(
                    controller: _documentNameController,
                    hintText: " Enter the document name",
                    labelText: "",
                    width: double.infinity,
                    onChange: (p0) {},
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const Divider(),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
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
              buttonText: "New Document",
              onTap: () {
                _displayRegisterBottomSheet(context);
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
                  const Text(
                    "My Documents",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  MyIconButton(
                    onPressed: () {
                      logout();
                    },
                    icon: const Icon(
                      Icons.logout_sharp,
                      color: Colors.white,
                      size: 34,
                    ),
                    buttonColor: Colors.transparent,
                    buttonHeight: 50,
                    buttonWidth: 50,
                  )
                ],
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listDocumentNames.length,
                  itemBuilder: (context, index) {
                    String documentName = listDocumentNames[index];
                    // List<String> values = listDocumentNames[index][1];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 4),
                            child: MyButton(
                              height: double.infinity,
                              width: screenWidth * 0.4,
                              buttonText: "Delete",
                              buttonColor: Colors.red,
                              onTap: () {
                                _showMyDialog(index);
                              },
                            ),
                          )
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MyCustomHomePageRoute(
                              DocumentPage(
                                documentName: documentName,
                                // values: values,
                                uId: uid,
                              ),
                            ),
                          );
                        },
                        child: MyListDocumentView(
                          title: documentName,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
