import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/components/Buttons/RectangularLogin.dart';
import 'package:food_ordering_app/components/FormComponents/DividerWithText.dart';
import 'package:food_ordering_app/components/FormComponents/EmailInputField.dart';
import 'package:food_ordering_app/components/FormComponents/PasswordInputField.dart';
import 'package:food_ordering_app/components/FormComponents/ShowToggle.dart';
import 'package:food_ordering_app/components/FormComponents/SocialMediaLogin.dart';
import 'package:food_ordering_app/components/FormComponents/TextWithLink.dart';
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

  @override
  Widget build(BuildContext context) {
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
              Column(
                children: <Widget>[],
              ),
              EmailInput(
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              PasswordInput(
                showPassword: showPassword,
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              PasswordInput(
                showPassword: showPassword,
                onChanged: (value){
                  passwordConfirmation = value;
                },
                labelText: "Confirm your Password",
              ),
              ShowToggle(
                  showText: showPassword,
                  onChanged: (value) {
                    setState(() {
                      showPassword = value;
                    });
                  }),
              RectangularLogin(
                onPressed: () async {
                  if(password == passwordConfirmation){
                    try{
                      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

                      await result.user.sendEmailVerification();
                      Navigator.pushNamed(context, Login.id);
                    }catch(e){
                      print(e);
                    }
                  } else {
                    print('The password does not match');
                  }
                },
                color: Colors.red[400],
                title: 'Sign Up',
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
