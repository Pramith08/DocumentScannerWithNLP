import 'dart:convert';
// import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
// import 'package:http/http.dart' as http;
import 'package:docscanner/components/my_button.dart';
import 'package:docscanner/components/my_custom_home_page_transition.dart';
import 'package:docscanner/components/my_pdf_view.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/pages/edit_document_page.dart';
import 'package:docscanner/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class DocumentPage extends StatefulWidget {
  final String documentName;
  // final List<String> values;
  final String uId;
  const DocumentPage({
    super.key,
    required this.documentName,
    // required this.values,
    required this.uId,
  });

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

double screenHeight = 0.0;
double screenWidth = 0.0;

class _DocumentPageState extends State<DocumentPage> {
  File? imageFile;
  final picker = ImagePicker();
  List<String> listDocumentValues = [];
  void back() {
    Navigator.pop(context);
  }

  void goToEditPage() {
    Navigator.push(
      context,
      MyCustomHomePageRoute(
        EditDocumentPage(
            documentName: widget.documentName,
            uId: widget.uId,
            currentListDocumentValues: listDocumentValues),
      ),
    );
  }

  Future<List<String>> fetchOutput(List<String> inputText) async {
    try {
      Dio dio = Dio();
      Response response = await dio.post(
        'http://10.0.2.2:8000/test', // Replace with your API URL
        data: jsonEncode(<String, dynamic>{
          'text': inputText,
        }),
      );

      if (response.statusCode == 200) {
        List<String> text = List<String>.from(response.data['input']);
        return text;
      } else {
        mySnackBar(context,
            "${response.statusCode} : ${response.statusMessage}", Colors.red);
        throw Exception(
            'Failed to load output. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error connecting to server: $e');
      mySnackBar(context, e.toString(), Colors.red);
      throw Exception('Failed to connect to server: $e');
    }
  }

  void getDataAndDisplayOutput() async {
    List<String> newList = [];

    final uId = widget.uId;
    final documentName = widget.documentName;

    for (String imageName in listDocumentValues) {
      String imageUrl = '$uId/documentName/$documentName/$imageName';
      newList.add(imageUrl);
    }

    print("List Document Names: $listDocumentValues");

    try {
      List<String> processedTexts = await fetchOutput(newList);

      print("processed Text : \n$processedTexts");
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getDocumentValue(widget.uId);
  }

  void getDocumentValue(String uid) async {
    final userId = uid;
    List<String> results = await getDocumentValues(userId, widget.documentName);

    setState(() {
      listDocumentValues = results;
    });
    print(listDocumentValues);
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
            'Document created successfully',
            Colors.green,
          );
          getDocumentValue(widget.uId);
        } else {
          // Navigator.pop(context);
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
                        widget.documentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: getDataAndDisplayOutput,
                        icon: const Icon(
                          color: Color(0xFFF4BBFF),
                          Icons.download,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: goToEditPage,
                        icon: const Icon(
                          color: Color(0xFFF4BBFF),
                          Icons.edit_square,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1),
                  itemCount: listDocumentValues.length,
                  itemBuilder: (context, index) {
                    String imageName = listDocumentValues[index];
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
                        String imageUrl = snapshot.data.toString();
                        return MyPdfView(
                          imageUrl: imageUrl,
                        );
                      },
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
