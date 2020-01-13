import 'package:flutter/material.dart';

class RoundIconLogin extends StatelessWidget {
  final Color iconColor;
  final IconData iconName;
  final Function onPressed;

  RoundIconLogin({this.iconColor, this.iconName, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: CircleAvatar(
        backgroundColor: iconColor,
        radius: 35.0,
        child: Icon(
          iconName,
          size: 30,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
