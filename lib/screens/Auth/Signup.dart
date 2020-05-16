import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/Button.dart';
import 'package:food_ordering_app/components/InputField.dart';
import 'package:food_ordering_app/components/Validation.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/DividerWithText.dart';
import 'package:food_ordering_app/screens/Auth/SocialMediaLogin.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/TextWithLink.dart';
import 'package:food_ordering_app/screens/Auth/Login.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  static const id = 'signup_screen';

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                      Input(
                        label: 'Confirm Password',
                        controller: _confirmController,
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

                      // Login with Email and Password
                      Button(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if(_passwordController.text == _confirmController.text){
                              // loading here will be true
                              functionalBloc.toggleLoading();
                              await authBloc.signUpWithEmailAndPassword(_emailController.text, _passwordController.text);
                            }

                            if(authBloc.errorMessage.isNotEmpty){
                              Get.snackbar('Warning',
                                authBloc.errorMessage[0],
                                backgroundColor: Colors.red[400],
                                colorText: Colors.white,
                              );
                              Future.delayed(Duration(seconds: 1), () {
                                authBloc.resetErrorMessage();
                                // when the error shows we stop the loading
                                functionalBloc.toggleLoading();
                              });
                            } else {
                              // when the sign up is successful, we stop loading
                              functionalBloc.toggleLoading();
                              Get.to(Login());

                              Get.snackbar('Notice',
                                  authBloc.noticeMessage[0],
                                backgroundColor: Colors.green[400],
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                        title: 'Sign Up',
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
                  textTitle: 'Already have an account? ',
                  linkTitle: 'Sign in here',
                  onPressed: () {
                    Navigator.pushNamed(context, Login.id);
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
