import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/components/Buttons/RectangularLogin.dart';
import 'package:food_ordering_app/components/FormComponents//SocialMediaLogin.dart';
import 'package:food_ordering_app/components/FormComponents//EmailInputField.dart';
import 'package:food_ordering_app/components/FormComponents//PasswordInputField.dart';
import 'package:food_ordering_app/components/FormComponents/DividerWithText.dart';
import 'package:food_ordering_app/components/FormComponents/ShowToggle.dart';
import 'package:food_ordering_app/components/FormComponents/TextWithLink.dart';
import 'package:food_ordering_app/screens/Auth/Signup.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';

class Login extends StatefulWidget {
  static const id = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isSwitch = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  String email;
  String password;
  String resetEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        //TODO add error handling for login
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Image.asset('images/blacklogo.png'),
                  height: 180.0,
                ),
              ),
              EmailInput(
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              PasswordInput(
                showPassword: isSwitch,
                onChanged: (value){
                  password = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ShowToggle(showText: isSwitch,
                    onChanged: (value) {
                      setState(() {
                        isSwitch = value;
                      });
                  }),
                  FlatButton(
                    child: Text('Reset Password',
                        style: TextStyle(
                          color: Colors.blue,
                        )),
                    onPressed: ()  {
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Reset Password'),
                                TextFormField(
                                  textAlign: TextAlign.center,
                                  onChanged: (value){
                                    resetEmail = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Enter your email',
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                FlatButton(
                                  child: Text('Reset',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),),
                                  color: Colors.red[400],
                                  onPressed: () async {
                                    await _auth.sendPasswordResetEmail(email: resetEmail);
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          );
                        }
                      );
                    },
                  ),
                ],
              ),
              RectangularLogin(
                title: 'Login',
                color: Colors.red[400],
                onPressed: () async {
//
                  FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;

                  if(user.isEmailVerified){
                    Navigator.pushReplacementNamed(context, Home.id);
                  } else {
                    print('Email is not verified');
                  }
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              DividerWithText(
                // the default value are
                // 30 for height,
                // OR for textTitle
                // black for color
              ),
              SizedBox(
                height: 10.0,
              ),
              SocialMediaLogin(
                //contain login method for facebook, google and wechat
              ),
              SizedBox(
                height: 10.0,
              ),
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
    );
  }
}





