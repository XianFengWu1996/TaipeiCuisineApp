import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/components/Buttons/RectangularLogin.dart';
import 'package:food_ordering_app/screens/auth/EmailPassword/Validation.dart';
import 'package:food_ordering_app/screens/Auth//OtherSigninMethods/SocialMediaLogin.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/DividerWithText.dart';
import 'package:food_ordering_app/screens/auth/EmailPassword/TextFieldInput.dart';
import 'package:food_ordering_app/components/FormComponents/StylingComponents/TextWithLink.dart';
import 'package:food_ordering_app/screens/Auth/Signup.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Login extends StatefulWidget {
  static const id = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //initializing instance of objects
  FirebaseAuth _auth = FirebaseAuth.instance;

  //initializing necessary variables
  String email;
  String password;
  String resetEmail;

  List<String> errorMessage = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

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
                        height: 10.0,
                      ),
                      TextFieldInput(
                        onChanged: (value) {
                          password = value;
                        },
                        labelText: "Enter password",
                        isEmail: false,
                        validator: Validation.passwordValidation,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            child: Text('Reset Password',
                                style: TextStyle(
                                  color: Colors.blue,
                                )),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Reset Password'),
                                          TextFormField(
                                            textAlign: TextAlign.center,
                                            onChanged: (value) {
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
                                            child: Text(
                                              'Reset',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            color: Colors.red[400],
                                            onPressed: () async {
                                              await _auth
                                                  .sendPasswordResetEmail(
                                                      email: resetEmail);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            },
                          ),
                        ],
                      ),
                      RectangularLogin(
                        title: 'Login',
                        color: Colors.red[400],
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            try {
                              FirebaseUser user =
                                  (await _auth.signInWithEmailAndPassword(
                                          email: email, password: password))
                                      .user;
                              if (user.isEmailVerified) {
                                Navigator.pushReplacementNamed(
                                    context, Home.id);
                              } else {
                                setState(() {
                                  errorMessage
                                      .add('The email has not been verified');
                                });
                              }
                            } catch (error) {
                              setState(() {
                                switch (error.code) {
                                  case 'ERROR_WRONG_PASSWORD':
                                    errorMessage.add(
                                        'Wrong password or invalid signin method');
                                    break;
                                  case 'ERROR_USER_NOT_FOUND':
                                    errorMessage.add(
                                        'User with the email is not found');
                                    break;
                                  default:
                                    errorMessage.add(
                                        'Some error has occurred, try again later.');
                                }
                              });
                            }
                          }
                          if (errorMessage.isNotEmpty) {
                            Flushbar(
                              title: "Something went wrong...",
                              message: errorMessage[0],
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.red[400],
                              flushbarStyle: FlushbarStyle.GROUNDED,
                              flushbarPosition: FlushbarPosition.TOP,
                            )..show(context);
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                errorMessage = [];
                              });
                            });
                          }
                        },
                      ),
                    ],
                  )),
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
