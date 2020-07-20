import 'dart:async';

import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Resend extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return AlertDialog(
      title: Text('Resend Verification Email'),
      content: Text('Do you want to receive a new verification email?'),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {

              try{
                await authBloc.user.sendEmailVerification();

                Get.close(1);

                functionalBloc.setValue('loading','start');

                Get.snackbar('Check your email',
                  'Please check your email for further instruction on email verification.',
                  backgroundColor: Colors.green[400],
                  colorText: Colors.white,
                );

                functionalBloc.setValue('loading','reset');

              } catch(e){
                Get.snackbar('Request can only be made once every 30 minutes', '', colorText: Colors.white, backgroundColor: Colors.red[400]);
                authBloc.setValue('enableDialog',false);
                Timer(Duration(minutes: 30), (){
                  authBloc.setValue('enableDialog',true);
                });
                functionalBloc.setValue('loading','reset');
              }

            },
            child: Text('Yes')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
              functionalBloc.setValue('loading','reset');
            },
            child: Text('Cancel'))
      ],
    );
  }
}
