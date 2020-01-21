import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/components/AccountComponents/AccountItem.dart';
import 'package:food_ordering_app/components/Buttons/RectangularLogin.dart';
import 'package:food_ordering_app/screens/Auth/Login.dart';

class AccountContent extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AccountItems(
            title: 'Account', icon: Icons.account_box, onPressed: () {}),
        AccountItems(
            title: 'Information', icon: Icons.home, onPressed: () {}),
        AccountItems(
            title: 'History', icon: Icons.history, onPressed: () {}),
        AccountItems(
            title: 'Deal', icon: Icons.attach_money, onPressed: () {}),
        RectangularLogin(
          onPressed: () {
            _auth.signOut();
            Navigator.pushReplacementNamed(context, Login.id);
          },
          title: 'Log Out',
          color: Colors.red[400],
        )
      ],
    );
  }
}


