import 'dart:async';

import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:get/get.dart';

class Resend extends StatelessWidget {
  final AuthBloc authBloc;
  final FunctionalBloc functionalBloc;

  Resend({this.authBloc, this.functionalBloc});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Resend Verification Email'),
      content: Text('Do you want to receive a new verification email?'),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              await authBloc.user.sendEmailVerification();

              Navigator.pop(context);

              functionalBloc.toggleLoading('start');

              Get.snackbar('Check your email',
                'Please check your email for further instructioon on email verification.',
                backgroundColor: Colors.green[400],
                colorText: Colors.white,
              );

              authBloc.enableDialog(false);

              functionalBloc.toggleLoading('reset');


              Timer(Duration(minutes: 30), (){
                authBloc.enableDialog(true);
              });
            },
            child: Text('Yes')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'))
      ],
    );
  }
}
