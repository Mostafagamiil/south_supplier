import 'package:flutter/material.dart';

// ignore: camel_case_types
class customText extends StatelessWidget {
  final String text;
  final Alignment alignment;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const customText( {
    
    super.key,
    this.text = '',
    this.fontSize = 18,
    this.color = Colors.black,
    this.alignment = Alignment.topRight,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Lalezar',
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
