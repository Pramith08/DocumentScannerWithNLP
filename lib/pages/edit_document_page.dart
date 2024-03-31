import 'package:docscanner/components/my_custom_home_page_transition.dart';
import 'package:docscanner/components/my_pdf_view.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/pages/home_page.dart';
import 'package:docscanner/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
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
