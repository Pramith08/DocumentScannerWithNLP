import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Color buttonColor;
  final double buttonHeight;
  final double buttonWidth;
  const MyIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.buttonColor,
    required this.buttonHeight,
    required this.buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      width: buttonWidth,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: Colors.black,
          width: 2.5,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}
