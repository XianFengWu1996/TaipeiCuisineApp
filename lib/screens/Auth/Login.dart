import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/BottomSheet.dart';
import 'package:food_ordering_app/components/Button.dart';
import 'package:food_ordering_app/components/Validation.dart';
import 'package:food_ordering_app/screens/Auth/SocialMediaLogin.dart';
import 'package:food_ordering_app/components/InputField.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/DividerWithText.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/TextWithLink.dart';
import 'package:food_ordering_app/screens/Auth/Signup.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';

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

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 10),
            child: ListView(
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            child: Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return BottomSheetContent(
                                    label: 'Reset Password',
                                    buttonText: 'Reset',
                                    controller: _resetEmailController,
                                    onPressed: () async {
                                      await authBloc.resetPasswordWithEmail(
                                          _resetEmailController.text);

                                      Navigator.pop(context);

                                      _resetEmailController.clear();

                                      if (authBloc.noticeMessage.isNotEmpty) {
                                        Get.snackbar(
                                          'Check your Email',
                                          authBloc.noticeMessage[0],
                                          backgroundColor: Colors.green[400],
                                          colorText: Colors.white,
                                        );
                                        Future.delayed(Duration(seconds: 1), () {
                                          authBloc.resetErrorMessage();
                                        });
                                      }

                                      if (authBloc.errorMessage.isNotEmpty) {
                                        Get.snackbar(
                                          'Error',
                                          authBloc.errorMessage[0],
                                          backgroundColor: Colors.red[400],
                                          colorText: Colors.white,
                                        );
                                        Future.delayed(Duration(seconds: 1), () {
                                          authBloc.resetErrorMessage();
                                        });
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      // Login with Email and Password
                      Button(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            functionalBloc.toggleLoading();

                            await authBloc.loginWithEmailAndPassword(
                                _emailController.text, _passwordController.text);

                            if (authBloc.errorMessage.isNotEmpty) {
                              Get.snackbar(
                                'Error',
                                authBloc.errorMessage[0],
                                backgroundColor: Colors.red[400],
                                colorText: Colors.white,
                              );
                              Future.delayed(Duration(seconds: 1), () {
                                authBloc.resetErrorMessage();
                                functionalBloc.toggleLoading();
                              });
                            }

                            if(authBloc.user != null){
                              if (!authBloc.user.isEmailVerified) {
                                authBloc.showDialogContent
                                    ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Resend Verification Email'),
                                        content: Text('Do you want to receive a new verification email?'),
                                        actions: <Widget>[
                                          FlatButton(
                                              onPressed: () async {
                                                await authBloc.user.sendEmailVerification();

                                                Navigator.pop(context);

                                                Get.snackbar('Check your email',
                                                  'Please check your email for further instructioon on email verification.',
                                                  backgroundColor: Colors.green[400],
                                                  colorText: Colors.white,
                                                );

                                                authBloc.enableDialog(false);
                                                functionalBloc.toggleLoading();

                                                Timer(Duration(minutes: 30), (){
                                                  authBloc.enableDialog(true);
                                                  functionalBloc.toggleLoading();
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
                    Navigator.pushNamed(context, Signup.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
