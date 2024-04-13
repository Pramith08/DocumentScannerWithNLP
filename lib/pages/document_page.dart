import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:docscanner/components/my_button.dart';
import 'package:docscanner/components/my_custom_home_page_transition.dart';
import 'package:docscanner/components/my_pdf_view.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/pages/edit_document_page.dart';
import 'package:docscanner/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DocumentPage extends StatefulWidget {
  final String documentName;

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
  List<String> listDocumentValues = [];
  // String nlpText = "Press The Button To Start Summarization";
  String nlpText = "";
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

  Future<String> fetchOutput(List<String> inputText) async {
    try {
      Dio dio = Dio();
      print(inputText);
      // print($inputText);
      Response response = await dio.post(
        'http://10.0.2.2:8000/image_to_text', // Replace with your API URL
        data: jsonEncode(<String, dynamic>{
          'path': inputText,
        }),
      );

      if (response.statusCode == 200) {
        List<String> text = List<String>.from(response.data['text']);
        String tempText = await fetchSummary(text);
        return tempText;
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

  Future<String> fetchSummary(List<String> inputText) async {
    try {
      Dio dio = Dio();
      print(inputText);
      // print($inputText);
      Response response = await dio.post(
        'https://abhinandanb03-doc-scanner.hf.space/summarize', // Replace with your API URL
        data: jsonEncode(<String, dynamic>{
          'text': inputText,
        }),
      );

      if (response.statusCode == 200) {
        String text = response.data['summary'];
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
      String processedTexts = await fetchOutput(newList);
      if (processedTexts.isNotEmpty) {
        // String finalText = "";
        // for (String text in processedTexts) {
        //   finalText = finalText + text;
        // }
        if (mounted) {
          setState(() {
            nlpText = processedTexts;
          });
          Navigator.pop(context);
          _displayNlpFunctionBottomSheet(context);
        }
      }
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

  Future _displayNlpFunctionBottomSheet(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return showModalBottomSheet(
      isDismissible: false,
      useSafeArea: true,
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
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 18,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Summarize the document",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                      IconButton(
                        onPressed: back,
                        icon: const Icon(
                          color: Color(0xFFF4BBFF),
                          Icons.close,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Container(
                    // width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xffE6E1D8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        nlpText,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Color(0xFF2D2A2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  MyButton(
                    height: 55,
                    width: double.infinity,
                    buttonText: "Start Summarization",
                    onTap: () {
                      getDataAndDisplayOutput();
                    },
                    buttonColor: Color(0xFFF4BBFF),
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
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _displayNlpFunctionBottomSheet(context);
                        },
                        icon: const Icon(
                          color: Color(0xFFF4BBFF),
                          Icons.manage_search_sharp,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: null,
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
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF4BBFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.documentName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Color(0xFF2D2A2E),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
