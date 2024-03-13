import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final double height;
  final double width;
  final String buttonText;
  final VoidCallback onTap;
  final Color buttonColor;

  const MyButton({
    super.key,
    required this.height,
    required this.width,
    required this.buttonText,
    required this.onTap,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2D2A2E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
