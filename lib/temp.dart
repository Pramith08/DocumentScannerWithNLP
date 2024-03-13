// // Future<List<dynamic>> getDocumentNames(String userId) async {
// //   List<dynamic> documentNameList = [];

// //   final folderRef = "$userId/documentName/";

// //   try {
// //     final storageRef = FirebaseStorage.instance.ref().child(folderRef);

// //     final ListResult result = await storageRef.listAll();

// //     // Iterate through each document (subfolder)
// //     for (final prefix in result.prefixes) {
// //       // Extract the document name
// //       String documentName = prefix.fullPath.substring(folderRef.length);

// //       // Fetch the list of values (files or subfolders) under the document
// //       // final ListResult documentResult = await prefix.list();
// //       // List<String> valuesUnderDocument = [];

// //       // // Extract the names of values under the document
// //       // documentResult.items.forEach((item) {
// //       //   valuesUnderDocument.add(item.name);
// //       // });

// //       // Add the document name and its corresponding list of values to the result list as a pair
// //       documentNameList.add(documentName);
// //     }
// //   } catch (e) {
// //     print('Error retrieving documents with values: $e');
// //   }

// //   return documentNameList;
// // }

// // Future<List<List<dynamic>>> getDocumentsWithValues(String userId) async {
// //   List<List<dynamic>> documentsWithValues = [];

// //   final folderRef = "$userId/documentName/";

// //   try {
// //     final storageRef = FirebaseStorage.instance.ref().child(folderRef);

// //     final ListResult result = await storageRef.listAll();

// //     // Iterate through each document (subfolder)
// //     for (final prefix in result.prefixes) {
// //       // Extract the document name
// //       String documentName = prefix.fullPath.substring(folderRef.length + 1);

// //       // Fetch the list of values (files or subfolders) under the document
// //       final ListResult documentResult = await prefix.list();
// //       List<String> valuesUnderDocument = [];

// //       // Extract the names of values under the document
// //       documentResult.items.forEach((item) {
// //         valuesUnderDocument.add(item.name);
// //       });

// //       // Add the document name and its corresponding list of values to the result list
// //       documentsWithValues.add([documentName, valuesUnderDocument]);
// //     }
// //   } catch (e) {
// //     print('Error retrieving documents with values: $e');
// //   }

// //   return documentsWithValues;
// // }

// // Future<List<String>> getSubfoldersList(String userId) async {
// //   List<String> subfolderNames = [];
// //   final folderRef = "$userId/documentName/";
// //   try {
// //     final storageRef = FirebaseStorage.instance.ref().child(folderRef);

// //     final ListResult result = await storageRef.listAll();

// //     // Extract subfolder names
// //     result.prefixes.forEach((prefix) {
// //       // Remove the parent folder reference from the prefix full path
// //       String subfolderName =
// //           prefix.fullPath.substring(folderRef.length + 1 - 1);
// //       subfolderNames.add(subfolderName);
// //     });
// //   } catch (e) {
// //     print('Error retrieving subfolders: $e');
// //   }

// //   return subfolderNames;
// // }

// // Future<Image?> _downloadImage(String imagePath) async {
//   //   try {
//   //     // Create a reference to the image in Firebase Storage
//   //     Reference imageRef = FirebaseStorage.instance.ref().child(imagePath);

//   //     // Get the image URL
//   //     String imageURL = await imageRef.getDownloadURL();

//   //     // Create an Image widget with the downloaded image
//   //     return Image.network(imageURL);
//   //   } catch (e) {
//   //     mySnackBar(
//   //       context,
//   //       e.toString(),
//   //       Colors.red,
//   //     );
//   //   }
//   //   return null;
//   // }

void onSaveChanges() async {
  // final userId = widget.uId;
  // final docName = widget.documentName;

  // final storageRef = FirebaseStorage.instance.ref();
  // print("storageRef: $storageRef");
  // final folderRef = "$userId/documentName/$docName/";
  // print("folderRef: $folderRef");

  // List<String> documentValues = [];

  // documentValues = await getDocumentValues(userId, docName);
  // print("Document Values: $documentValues");

  // for (final item in documentValues) {
  //   // print("Item: $item");
  //   final String name = item;
  //   final oldImageRef = storageRef.child("$folderRef$name");
  //   print("oldImageRef: $oldImageRef");
  //   // await oldImageRef.delete();
  // }

  // for (final lol in _editedImages) {
  //   final String ImageName = lol;

  //   final uId = widget.uId;
  //   final documentName = widget.documentName;
  //   String imageUrl = '$uId/documentName/$documentName/$ImageName';
  //   print("imageUrl: $imageUrl");
  // }

  // print("********-------- DONE -------********");
}


//   ReorderableGridView(
//                   onReorder: (int oldIndex, int newIndex) {
//                     setState(() {
//                       if (newIndex > oldIndex) {
//                         newIndex -= 1;
//                       }
//                     });
//                   },
//                   gridDelegate: gridDelegate,
//                   childrenDelegate: childrenDelegate,
//                 ),




// Future<void> updateImageOrder(String userId, String documentName, List<String> newOrder) async {
//   try {
//     final storage = FirebaseStorage.instance;
//     final storageRef = storage.ref();
//     final String oldFolder = '$userId/documentName/$documentName';
//     final String newFolder = '$userId/documentName/${documentName}_temp';

//     // Create a new folder with the updated image order
//     await storageRef.child(newFolder).putData(Uint8List(0)); // create an empty file to create the folder

//     // Move images to the new folder
//     for (int i = 0; i < newOrder.length; i++) {
//       final String oldImageUrl = '$oldFolder/${newOrder[i]}';
//       final String newImageUrl = '$newFolder/${newOrder[i]}';
//       await storageRef.child(oldImageUrl).copy(storageRef.child(newImageUrl));
//     }

//     // Delete the old folder
//     await storageRef.child(oldFolder).delete();
    
//     // Rename the new folder to the original document name
//     await storageRef.child(newFolder).rename('$userId/documentName/$documentName');
//   } catch (e) {
//     print('Error updating image order: $e');
//     throw e;
//   }
// }


// Future<void> updateImageOrder(String userId, String documentName, List<String> newOrder) async {
//   try {
//     final storage = FirebaseStorage.instance;
//     final storageRef = storage.ref();
//     final List<String> imageUrls = [];

//     // Build the list of image URLs
//     for (final imageName in newOrder) {
//       final imageUrl = '$userId/documentName/$documentName/$imageName';
//       imageUrls.add(imageUrl);
//     }

//     // Rename each image to reflect the new order
//     for (int i = 0; i < imageUrls.length; i++) {
//       final oldImageUrl = imageUrls[i];
//       final newImageUrl = '$userId/documentName/$documentName/Image$i.jpg'; // Adjust file extension as needed
//       await storageRef.child(oldImageUrl).rename(newImageUrl);
//     }
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
//     final List<String> imageUrls = [];

//     // Build the list of image URLs
//     for (final imageName in newOrder) {
//       final imageUrl = '$userId/documentName/$documentName/$imageName';
//       imageUrls.add(imageUrl);
//     }

//     // Update metadata for each image to reflect the new order
//     for (final imageUrl in imageUrls) {
//       final ref = storageRef.child(imageUrl);
//       final metadata = SettableMetadata(
//           customMetadata: {'order': '${imageUrls.indexOf(imageUrl)}'});
//       await ref.updateMetadata(metadata);
//     }
//   } catch (e) {
//     print('Error updating image order: $e');
//     throw e;
//   }
// }


// Future<void> updateImageOrder(String userId, String documentName, List<String> newOrder) async {
//   try {
//     final storageRef = FirebaseStorage.instance.ref();
//     final List<String> oldImageUrls = [];
//     final List<String> newImageUrls = [];
    
//     // Rename existing images with temporary names
//     for (final imageName in newOrder) {
//       final oldImageUrl = '$userId/documentName/$documentName/$imageName';
//       final newImageUrl = '$userId/documentName/$documentName/${imageName}_temp';
//       oldImageUrls.add(oldImageUrl);
//       newImageUrls.add(newImageUrl);
//       await storageRef.child(oldImageUrl).rename(newImageUrl);
//     }
    
//     // Rename temporary images with original names
//     for (int i = 0; i < newOrder.length; i++) {
//       final oldImageUrl = newImageUrls[i];
//       final newImageUrl = '$userId/documentName/$documentName/${newOrder[i]}';
//       await storageRef.child(oldImageUrl).rename(newImageUrl);
//     }
//   } catch (e) {
//     print('Error updating image order: $e');
//     throw e;
//   }
// }


// Future<void> updateImageOrder(
//     String userId, String documentName, List<String> newOrder) async {
//   try {
//     final storageRef = FirebaseStorage.instance.ref();
//     final List<String> imageUrls = [];
//     for (final imageName in newOrder) {
//       final imageUrl = '$userId/documentName/$documentName/$imageName';
//       imageUrls.add(imageUrl);
//     }
//     // Delete existing images and re-upload them in the new order
//     for (final imageUrl in imageUrls) {
//       final oldRef = storageRef.child(imageUrl);
//       final newRef = storageRef.child(imageUrl);
//       final imageData = await oldRef.getData();
//       await newRef.putData(imageData!); // Make sure imageData is not null
//       await oldRef.delete();
//     }
//   } catch (e) {
//     print('Error updating image order: $e');
//     throw e;
//   }
// }
