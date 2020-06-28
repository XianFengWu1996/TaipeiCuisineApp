import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/components/Buttons/RoundIconLogin.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SocialMediaLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    CartBloc cartBloc = Provider.of<CartBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RoundIconLogin(
          iconName: FontAwesome.facebook_f,
          iconColor: Color(0xff3b5998),
          onPressed: () async {
            functionalBloc.toggleLoading('start');

            await authBloc.loginWithFacebook(functionalBloc, paymentBloc,cartBloc);

            functionalBloc.toggleLoading('reset');

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
            functionalBloc.toggleLoading('start');
            await authBloc.loginWithGoogle(functionalBloc, paymentBloc, cartBloc);
            functionalBloc.toggleLoading('reset');

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
