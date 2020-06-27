import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:provider/provider.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: Column(
        children: <Widget>[
          Text('Display Name: ${authBloc.user.displayName}'),
          Text('Email: ${authBloc.user.email}'),

        ],
      ),
    );
  }
}
