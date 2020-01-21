import 'package:flutter/material.dart';

class TextWithLink extends StatelessWidget {
  final String textTitle;
  final String linkTitle;
  final Function onPressed;

  TextWithLink({@required this.textTitle, @required this.linkTitle, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(textTitle),
        FlatButton(
          child: Text(linkTitle,
              style: TextStyle(
                color: Colors.blue,
              )),
          onPressed: onPressed,
        ),
      ],
    );
  }
}