import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final bool isFilled;

  const CustomCupertinoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.fontSize = 16,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: isFilled ? (color ?? CupertinoColors.activeBlue) : null,
      borderRadius: BorderRadius.circular(borderRadius),
      padding: padding,
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: isFilled ? CupertinoColors.white : (color ?? CupertinoColors.activeBlue),
          fontSize: fontSize,
        ),
      ),
    );
  }
} 