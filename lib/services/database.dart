import 'dart:io';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

Future<bool> createNewDocument(
  BuildContext context,
  String docName,
  File image,
  String uId,
) async {
  try {
    final userId = uId;
    final documentName = docName;
    final storageRef = FirebaseStorage.instance.ref();
    final imageName = "Image1";
    final uploadRef =
        storageRef.child("$userId/documentName/$documentName/$imageName");

    await uploadRef.putFile(image);
    return true;
  } catch (e) {
    mySnackBar(context, e.toString(), Colors.red);
  }
  return false;
}

Future<bool> addNewDocument(
  BuildContext context,
  String docName,
  File image,
  String uId,
) async {
  try {
    final userId = uId;
    final documentName = docName;
    final storageRef = FirebaseStorage.instance.ref();
    // final imageName = DateTime.now().microsecondsSinceEpoch;
    final ListResult result =
        await storageRef.child("$userId/documentName/$documentName").list();
    print("Result: $result");
    final int numImages = result.items.length;
    print("numImages: $numImages");

    // Create the new image name in sequence
    final helloImageName = "Image${numImages + 1}";
    print("imageName: $helloImageName");
    final uploadRef =
        storageRef.child("$userId/documentName/$documentName/$helloImageName");
    print("uploadRef: $uploadRef");

    await uploadRef.putFile(image);
    Navigator.pop(context);
    return true;
  } catch (e) {
    Navigator.pop(context);
    mySnackBar(context, e.toString(), Colors.red);
  }
  return false;
}

Future<List<dynamic>> getDocumentNames(String userId) async {
  List<dynamic> documentNameList = [];

  final folderRef = "$userId/documentName/";

  try {
    final storageRef = FirebaseStorage.instance.ref().child(folderRef);
    final ListResult result = await storageRef.listAll();
    // Iterate through each document (subfolder)
    for (final prefix in result.prefixes) {
      // Extract the document name
      String documentName = prefix.fullPath.substring(folderRef.length);
      // Add the document name and its corresponding list of values to the result list as a pair
      documentNameList.add(documentName);
    }
  } catch (e) {
    print('Error retrieving documents with values: $e');
  }

  return documentNameList;
}

Future<List<String>> getDocumentValues(String userId, String docname) async {
  List<String> documentValues = [];

  final folderRef = "$userId/documentName/$docname/";

  try {
    final storageRef = FirebaseStorage.instance.ref().child(folderRef);
    print("Storage Ref for document values: $storageRef");

    final ListResult result = await storageRef.listAll();

    // Iterate through each item (file) in the folder
    for (final item in result.items) {
      // Extract the file name
      String fileName = item.name;
      // Add the file name to the list of document values
      documentValues.add(fileName);
    }
  } catch (e) {
    print('Error retrieving document values: $e');
    // Print additional error details if available
    if (e is FirebaseException) {
      print('Firebase Storage Error Code: ${e.code}');
      print('Firebase Storage Error Message: ${e.message}');
    }
  }

  return documentValues;
}

Future<void> generateAndDownloadPDF(List<String> imagePaths) async {
  final pdf = pw.Document();

  // Download and add images to the PDF
  for (String imagePath in imagePaths) {
    final imageFile = await _downloadImageFromFirebaseStorage(imagePath);
    if (imageFile != null) {
      final image = pw.MemoryImage(imageFile.readAsBytesSync());

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Image(image);
          },
        ),
      );
    }
  }

  // Get the directory for saving the PDF file
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/images.pdf';

  // Save the PDF file
  final file = File(path);
  await file.writeAsBytes(await pdf.save());

  // Download the PDF file
  await FlutterDownloader.enqueue(
    url: 'file://$path',
    savedDir: directory.path,
    fileName: 'images.pdf',
    showNotification: true,
    openFileFromNotification: true,
  );
}

Future<File?> _downloadImageFromFirebaseStorage(String imagePath) async {
  try {
    final Reference ref = FirebaseStorage.instance.ref(imagePath);
    // final FullMetadata metadata = await ref.getMetadata();
    final imageFile =
        File('${(await getTemporaryDirectory()).path}/$imagePath');
    await ref.writeToFile(imageFile);
    return imageFile;
  } catch (e) {
    print('Error downloading image: $e');
    return null;
  }
}

// Future<void> generateAndDownloadPDF(List<String> imagePaths) async {
//   final pdf = pw.Document();

//   // Add images to the PDF
//   for (String imagePath in imagePaths) {
//     final image = pw.MemoryImage(
//       File(imagePath).readAsBytesSync(),
//     );

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Image(image);
//         },
//       ),
//     );
//   }

//   // Get the directory for saving the PDF file
//   final directory = await getExternalStorageDirectory();
//   final path = '${directory?.path}/images.pdf';

//   // Save the PDF file
//   final file = File(path);
//   await file.writeAsBytes(await pdf.save());

//   // Download the PDF file
//   await FlutterDownloader.enqueue(
//     url: 'file://$path',
//     savedDir: directory!.path,
//     fileName: 'images.pdf',
//     showNotification: true,
//     openFileFromNotification: true,
//   );
// }

Future<void> updateImageOrder(String userId, String documentName,
    List<String> newOrder, List<String> oldOrder) async {
  try {
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref();

    for (int i = 0; i < oldOrder.length; i++) {
      final newElement = newOrder[i];
      final oldElement = oldOrder[i];

      String newimageUrl = '$userId/documentName/$documentName/$newElement';
      final newImageUrlRef = storageRef.child(newimageUrl);
      final newImageData = await newImageUrlRef.getData();

      final uploadRef = storageRef
          .child("$userId/documentName/$documentName/temp$oldElement");

      // print("NewImageData: $newImageData");

      await uploadRef.putData(newImageData!);
    }
    for (int i = 0; i < oldOrder.length; i++) {
      final oldElement = oldOrder[i];
      await storageRef
          .child("$userId/documentName/$documentName/$oldElement")
          .delete();

      print("lol$i: $oldElement");
    }
    for (int i = 0; i < oldOrder.length; i++) {
      final newElement = newOrder[i];
      final oldElement = oldOrder[i];
      print("oldOrder$i: $newElement");
      print("newOrder$i: $oldElement");

      String newimageUrl = '$userId/documentName/$documentName/temp$newElement';
      final newImageUrlRef = storageRef.child(newimageUrl);
      final newImageData = await newImageUrlRef.getData();

      final uploadRef =
          storageRef.child("$userId/documentName/$documentName/$newElement");

      await uploadRef.putData(newImageData!);
    }
    for (int i = 0; i < oldOrder.length; i++) {
      final oldElement = oldOrder[i];
      await storageRef
          .child("$userId/documentName/$documentName/temp$oldElement")
          .delete();

      print("lol$i: $oldElement");
    }
  } catch (e) {
    print('Error updating image order: $e');
    throw e;
  }
}






// Future<void> updateImageOrder(
//     String userId, String documentName, List<String> newOrder) async {
//   try {
//     final storage = FirebaseStorage.instance;
//     final storageRef = storage.ref();
//     final String folderPath = '$userId/documentName/$documentName';
//     print('New order: $newOrder');

//     List<String> listDocumentValues =
//         await getDocumentValues(userId, documentName);

//     final firstelement = listDocumentValues[0];

//     String demoimageUrl = '$folderPath/$firstelement';

//     print("ListDocumentValues: $listDocumentValues");
//     print("demoimageUrl: $demoimageUrl");

//     // Retrieve download URL asynchronously
//     final demoImageUrlRef = storageRef.child(demoimageUrl);
//     final demoImageUrl = await demoImageUrlRef.getDownloadURL();

//     print("demoImageUrl: $demoImageUrl");

//     final newfirstElement = newOrder[1];
//     final newImageUrl = '$folderPath/$newfirstElement';

//     print("newfirstElement[0]: $newfirstElement");

//     // Upload new image
//     final newImageFile = await http.get(Uri.parse(newImageUrl));
//     final newImageBytes = newImageFile.bodyBytes;

//     final uploadRef = storageRef.child("$folderPath/$newfirstElement");
//     print("uploadRef: $uploadRef");

//     await uploadRef.putData(newImageBytes);
//   } catch (e) {
//     print('Error updating image order: $e');
//     throw e;
//   }
// }

// Future<void> updateImageOrder(
//     String userId, String documentName, List<String> newOrder) async {
//   try {
//     final storage = FirebaseStorage.instance;
//     final storageRef = storage.ref();
//     final String folderPath = '$userId/documentName/$documentName';
//     print('New order: $newOrder');

//     List<String> listDocumentValues =
//         await getDocumentValues(userId, documentName);

//     final firstelement = listDocumentValues[0];

//     String demoimageUrl = '$userId/documentName/$documentName/$firstelement';

//     print("ListDocumentValues: $listDocumentValues");
//     print("demoimageUrl: $demoimageUrl");

//     var hey = await FirebaseStorage.instance
//         .ref()
//         .child(demoimageUrl)
//         .getDownloadURL();

//     print("hey: $hey");

//     final newfirstElement = newOrder[1];

//     print("newfirstElement[0]: $newfirstElement");

//     File imageFile = File(hey);

//     print("ImageFile: $imageFile");

//     final uploadRef = storageRef.child("$folderPath/$newfirstElement");
//     print("uploadRef: $uploadRef");

//     await uploadRef.putFile(imageFile);
//   } catch (e) {
//     print('Error updating image order: $e');
//     throw e;
//   }
// }

// Step 1: Retrieve the list of current image filenames
// final ListResult result = await storageRef.child(folderPath).list();
// final List<String> currentFilenames =
//     result.items.map((item) => item.name).toList();
// print('Current filenames: $currentFilenames');

// Debug: Print current and new order of filenames

// final oldfirstElement = currentFilenames[0];

// final oldImageUrl = '$folderPath/$oldfirstElement';
// print("OldImageUrl: $oldImageUrl");
// final int numImages = newOrder.length;
// final TempImageName = "Image${numImages + 1}";
// final newImageUrl = '$folderPath/$newfirstElement';
// print('New image URL: $newImageUrl');

// if (!imageFile.existsSync()) {
//   print('File does not exist at path: $newImageUrl');
//   return; // or handle the error appropriately
// }

// If the file exists, proceed with uploading

// final newImageUrl = '$folderPath/$TempImageName';
// // print('Old image URL: $oldImageUrl');
// print('New image URL: $newImageUrl');
// File imageFile = File(newImageUrl);

// final uploadRef =
//     storageRef.child("$userId/documentName/$documentName/$TempImageName");
// print("uploadRef: $uploadRef");

// await uploadRef.putFile(imageFile);

// await storageRef.child(oldImageUrl).putFile(imageFile);
// print("CurrentFileName[0]: $oldfirstElement");
// Step 2: Compare current filenames with the new order
// for (final oldFilename in currentFilenames) {}

// Step 3: Copy images to temporary location with new filenames and delete old images
// for (int i = 0; i < newOrder.length; i++) {
//   // final oldFilename = currentFilenames[i];
//   final oldFilename = "Image1";
//   final newFilename = newOrder[i];
//   final oldImageUrl = '$folderPath/$oldFilename';
//   // final newImageUrl = '$folderPath/$newFilename';
//   // await storageRef.child(oldImageUrl).delete();
//   // await storageRef.child(newImageUrl).putData(oldImageData);

//   // Debug: Print old and new image URLs

//   final int numImages = newOrder.length;
//   final TempImageName = "Image${numImages + 1}";
//   final newImageUrl = '$folderPath/$TempImageName';
//   print('Old image URL: $oldImageUrl');
//   print('New image URL: $newImageUrl');

//   // Get the data of the old image

//   // if (oldImageData != null) {
//   //   // Upload the data to the new image path
//   //   await storageRef.child(newImageUrl).putData(oldImageData);
//   //   // Delete the old image if the filename has changed
//   //   if (oldFilename != newFilename) {
//   //     await storageRef.child(oldImageUrl).delete();
//   //   }
//   // }
// }
