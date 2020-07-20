import 'package:flutter/material.dart';

class RoundRectangularButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;
  final double vertical;
  final double horizontal;

  RoundRectangularButton({this.title, this.color, @required this.onPressed, this.vertical=15.0, this.horizontal=20.0});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(title,
        style: TextStyle(
          fontSize: 25.0,
          color: Colors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(color: Colors.red)
      ),
      elevation: 5,
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      color: color,
      onPressed: onPressed,
    );
  }
}