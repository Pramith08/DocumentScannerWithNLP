
// FutureBuilder(
//                       future: FirebaseStorage.instance
//                           .ref()
//                           .child(imageUrl)
//                           .getDownloadURL(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: SizedBox(
//                               height: 100,
//                               width: 100,
//                               child: CircularProgressIndicator(
//                                 color: Color(0xFFF4BBFF),
//                               ),
//                             ),
//                           ); // Display loading indicator while image is loading
//                         }
//                         String imageUrl = snapshot.data.toString();
//                         return MyPdfView(
//                           imageUrl: imageUrl,
//                         );
//                       },
//                     );