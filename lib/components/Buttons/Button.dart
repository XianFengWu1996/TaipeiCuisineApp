import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final Function onPressed;
  final Color color;
  final Color textColor;
  final double topPadding;
  final double bottomPadding;
  final String title;
  final double textSize;

  Button({this.color,
    @required this.onPressed,
    this.textColor = Colors.white,
    this.topPadding = 10,
    this.bottomPadding = 10,
    this.title,
    this.textSize = 19});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('$title', style: TextStyle(color: textColor, fontSize: textSize),),
      onPressed: onPressed,
      color: color,
      disabledColor: Colors.red.shade100,
      padding: EdgeInsets.only(top: topPadding , bottom: bottomPadding, left: 10, right: 10),
    );
  }
}
