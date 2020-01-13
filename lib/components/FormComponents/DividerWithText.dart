import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String textTitle;
  final Color color;
  final double height;

  DividerWithText({ this.textTitle = 'OR', this.color = Colors.black, this.height = 30.0});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 20.0),
            child: Divider(
              height: height,
              color: color,
            ),
          )),
      Text(textTitle),
      Expanded(
        child: Container(
          margin: EdgeInsets.only(left: 20.0, right: 10.0),
          child: Divider(
            height: height,
            color: color,
          ),
        ),
      ),
    ]);
  }
}
