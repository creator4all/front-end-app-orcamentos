import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TextButtonLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const TextButtonLink({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(10, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppTheme.primaryColor,
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
      ),
    );
  }
}
