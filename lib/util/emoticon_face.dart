import 'package:flutter/material.dart';

class EmoticonFace extends StatelessWidget{
  final String emoticonface;
  final Color? color;
  const EmoticonFace({Key? key, required this.emoticonface, required this.color }): super(key:key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:BoxDecoration(
          color: color!,
          borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(16),
      child: Text(
          emoticonface,
          style: TextStyle(
            fontSize: 28,
      ),
      )
    );
  }
}