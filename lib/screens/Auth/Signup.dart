import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/components/Buttons/RectangularLogin.dart';
import 'package:food_ordering_app/screens/Auth/EmailPassword/Validation.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/DividerWithText.dart';
import 'package:food_ordering_app/screens/Auth/EmailPassword/TextFieldInput.dart';
import 'package:food_ordering_app/screens/Auth/OtherSigninMethods/SocialMediaLogin.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/TextWithLink.dart';
import 'package:food_ordering_app/screens/Auth/Login.dart';

class Signup extends StatefulWidget {
  static const id = 'signup_screen';

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool showPassword = false;

  final _auth = FirebaseAuth.instance;

  String email;
  String password;
  String passwordConfirmation;
  bool match;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SafeArea(
        //TODO add error handling for sign up
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Image.asset('images/blacklogo.png'),
                  height: 180,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFieldInput(
                      onChanged: (value) {
                        email = value;
                      },
                      labelText: 'Enter email',
                      isEmail: true,
                      validator: Validation.emailValidation,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFieldInput(
                      onChanged: (value) {
                        password = value;
                      },
                      labelText: "Enter password",
                      isEmail: false,
                      validator: Validation.passwordValidation,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFieldInput(
                      onChanged: (value) {
                        passwordConfirmation = value;
                      },
                      labelText: "Confirm password",
                      isEmail: false,
                      validator: Validation.passwordValidation,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RectangularLogin(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          if (password == passwordConfirmation) {
                            try {
                              (await _auth.createUserWithEmailAndPassword(
                                      email: email, password: password)).user.sendEmailVerification();

                              Navigator.pushNamed(context, Login.id);
                            } catch (e) {
                              print(e);
                            }
                          } else {
                              Flushbar(
                              title: "Something went wrong...",
                              message: 'Password does not match',
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.red[400],
                              flushbarStyle: FlushbarStyle.GROUNDED,
                              flushbarPosition: FlushbarPosition.TOP,
                              )..show(context);
                          }
                        }
                      },
                      color: Colors.red[400],
                      title: 'Sign Up',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              DividerWithText(),
              SizedBox(
                height: 10,
              ),
              SocialMediaLogin(),
              SizedBox(
                height: 10,
              ),
              TextWithLink(
                textTitle: 'Already have an account?',
                linkTitle: 'Sign in here',
                onPressed: () {
                  Navigator.pushNamed(context, Login.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
