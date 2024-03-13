import 'package:flutter/material.dart';

class MyPdfView extends StatelessWidget {
  final String? imageUrl;
  // final String? subTitle;
  const MyPdfView({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.network(
            imageUrl!,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Error Loading Image',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ); // Displayed when error loading image
            },
          ),
        ),
      ),
    );
  }
}
