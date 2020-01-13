import 'package:flutter/material.dart';

class ShowToggle extends StatelessWidget {
  final bool showText;
  final Function onChanged;

  ShowToggle({@required this.showText, @required this.onChanged, });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('Show'),
        Switch(
          value: showText,
          onChanged: onChanged,
        )],
    );
  }
}