import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/Buttons/RoundIconLogin.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SocialMediaLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RoundIconLogin(
          iconName: FontAwesome.facebook_f,
          iconColor: Color(0xff3b5998),
          onPressed: () async {
            await authBloc.loginWithFacebook(functionalBloc);

            if(authBloc.errorMessage.isNotEmpty){
              Get.snackbar('Warning',
                authBloc.errorMessage[0],
                backgroundColor: Colors.red[400],
                colorText: Colors.white,
              );
              Future.delayed(Duration(seconds: 1), authBloc.resetErrorMessage());
            }
          },
        ),
        RoundIconLogin(
          iconName: FontAwesome.google,
          iconColor: Color(0xffEA4335),
          onPressed: () async {
            await authBloc.loginWithGoogle();

            if(authBloc.errorMessage.isNotEmpty){
              Get.snackbar('Warning',
                authBloc.errorMessage[0],
                backgroundColor: Colors.red[400],
                colorText: Colors.white,
              );
              Future.delayed(Duration(seconds: 2), authBloc.resetErrorMessage());
            }
          },
        ),

      ],
    );
  }
}
