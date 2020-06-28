import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/components/Button.dart';
import 'package:TaipeiCuisine/components/Validation.dart';
import 'package:TaipeiCuisine/screens/Auth/Login/EmailResend.dart';
import 'package:TaipeiCuisine/screens/Auth/Login/Reset.dart';
import 'package:TaipeiCuisine/screens/Auth/SocialMediaLogin.dart';
import 'package:TaipeiCuisine/components/InputField.dart';
import 'package:TaipeiCuisine/components/FormComponents/StylingComponents/DividerWithText.dart';
import 'package:TaipeiCuisine/components/FormComponents/StylingComponents/TextWithLink.dart';
import 'package:TaipeiCuisine/screens/Auth/Signup.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';

class Login extends StatefulWidget {
  static const id = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _resetEmailController = TextEditingController();

  bool showDialogContent = true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    child: Image.asset('images/blacklogo.png'),
                    height: 180.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Input(
                          label: 'Enter Email',
                          controller: _emailController,
                          validate: Validation.emailValidation,
                        ),
                        Input(
                          label: 'Enter Password',
                          controller: _passwordController,
                          obscureText: !authBloc.obscureText,
                          validate: Validation.passwordValidation,
                          textCap: TextCapitalization.none,
                          icon: IconButton(
                              icon: Icon(!authBloc.obscureText
                                  ? FontAwesome.lock
                                  : FontAwesome.unlock),
                              onPressed: () {
                                authBloc.showPassword(!authBloc.obscureText);
                              }),
                        ),

                        ResetPass(resetEmailController: _resetEmailController, authBloc: authBloc,),
                        // Login with Email and Password
                        Button(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              functionalBloc.toggleLoading('start');

                              await authBloc.loginWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                  storeBloc,
                                  functionalBloc,
                                  paymentBloc,
                                  cartBloc
                              );

                              if (authBloc.errorMessage.isNotEmpty) {
                                Get.snackbar(
                                  'Error',
                                  authBloc.errorMessage[0],
                                  backgroundColor: Colors.red[400],
                                  colorText: Colors.white,
                                );
                                Future.delayed(Duration(seconds: 1), () {
                                  authBloc.resetErrorMessage();
                                  functionalBloc.toggleLoading('reset');
                                });
                              }

                              if(authBloc.user != null){
                                if (!authBloc.user.isEmailVerified) {
                                  authBloc.showDialogContent
                                      ? showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Resend();
                                      })
                                      : Container();
                                }
                              }
                            }
                          },
                          title: 'Login',
                          color: Colors.red[400],
                          textColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textSize: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DividerWithText(),
                  SocialMediaLogin(),
                  TextWithLink(
                    textTitle: 'Don\'t have an account?',
                    linkTitle: 'Sign up here',
                    onPressed: () {
                      Get.to(Signup());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
