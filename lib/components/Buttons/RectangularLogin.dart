import 'package:flutter/material.dart';

class RectangularLogin extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;

  RectangularLogin({this.title, this.color, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 25.0,
          color: Colors.white,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      color: color,
      onPressed: onPressed,
    );
  }
}