import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final Function onPressed;
  final Color color;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final String title;
  final double textSize;

  Button({this.color, @required this.onPressed,this.textColor, this.padding, this.title, this.textSize});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('$title', style: TextStyle(color: textColor, fontSize: textSize),),
      onPressed: onPressed,
      color: color,
      padding: padding,
    );
  }
}
