import 'package:flutter/material.dart';

class MyListDocumentView extends StatelessWidget {
  final String? title;
  // final String? subTitle;
  const MyListDocumentView({
    super.key,
    required this.title,
    // required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF4BBFF),
          borderRadius: BorderRadius.circular(8),
        ),
        width: double.infinity,
        child: Center(
          child: ListTile(
            title: Text(
              title ?? "",
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Color(0xFF2D2A2E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            // subtitle: Text(
            //   subTitle ?? "",
            //   textAlign: TextAlign.justify,
            //   style: TextStyle(
            //     fontSize: 15,
            //     fontWeight: FontWeight.w400,
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
}
