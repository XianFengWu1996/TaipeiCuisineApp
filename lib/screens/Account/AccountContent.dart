import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/components/AccountComponents/AccountItem.dart';
import 'package:food_ordering_app/components/Buttons/Rectangular.dart';
import 'package:food_ordering_app/screens/Auth/Login.dart';
import 'package:provider/provider.dart';

class AccountContent extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var authBloc = Provider.of<AuthBloc>(context);
    var cartBloc = Provider.of<CartBloc>(context);
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
        Text('${authBloc.user.email}'),
        RectangularLogin(
          onPressed: () {
            _auth.signOut();
            Navigator.pushReplacementNamed(context, Login.id);
            authBloc.removeUser();
            cartBloc.clearValueUponLogout();
          },
          title: 'Log Out',
          color: Colors.red[400],
        )
      ],
    );
  }
}


