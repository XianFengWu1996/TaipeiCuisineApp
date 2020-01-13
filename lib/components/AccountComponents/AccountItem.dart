import 'package:flutter/material.dart';

class AccountItems extends StatelessWidget {
  final Function onPressed;
  final String title;
  final IconData icon;

  AccountItems(
      {@required this.title, @required this.icon, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      title,
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ),
        Divider(
          height: 10,
          thickness: 1.0,
        ),
      ],
    );
  }
}