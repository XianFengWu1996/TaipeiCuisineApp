import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:food_ordering_app/components/Buttons/RoundIconLogin.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_ordering_app/components/FormComponents/PhoneVerification.dart';

class SocialMediaLogin extends StatefulWidget {
  @override
  _SocialMediaLoginState createState() => _SocialMediaLoginState();
}

class _SocialMediaLoginState extends State<SocialMediaLogin> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        RoundIconLogin(
          iconName: FontAwesome.facebook_f,
          iconColor: Color(0xff3b5998),
          onPressed: () async {
            final facebookLogin = FacebookLogin();
            final result = await facebookLogin.logIn(['email']);

            switch (result.status) {
              case FacebookLoginStatus.loggedIn:
                final token = result.accessToken.token;
                print('token' + token);
                AuthCredential credential =
                    FacebookAuthProvider.getCredential(accessToken: token);

                FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
                print(user);

                Navigator.pushReplacementNamed(context, Home.id);

                break;
              case FacebookLoginStatus.cancelledByUser:
                print('cancelled');
                break;
              case FacebookLoginStatus.error:
                print('error');
                break;
            }
          },
        ),
        RoundIconLogin(
          iconName: FontAwesome.google,
          iconColor: Color(0xffEA4335),
          onPressed: () async {
            final GoogleSignIn _googleSignIn = GoogleSignIn();

            final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
            final GoogleSignInAuthentication googleAuth =
                await googleUser.authentication;

            final AuthCredential credential = GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken);

            user = (await _auth.signInWithCredential(credential)).user;
            print(user);
            Navigator.pushReplacementNamed(context, Home.id);
          },
        ),
        RoundIconLogin(
          iconName: FontAwesome.phone,
          iconColor: Colors.green,
          onPressed: () {
            Navigator.pushNamed(context, PhoneVerification.id);
          },
        ),
      ],
    );
  }
}

//class PhoneVerification extends StatefulWidget {
//  @override
//  _PhoneVerificationState createState() => _PhoneVerificationState();
//}
//
//class _PhoneVerificationState extends State<PhoneVerification> {
//  String phoneNumber;
//  bool verification = false;
//  final _formKey = GlobalKey<FormState>();
//
//  @override
//  Widget build(BuildContext context) {
//    return verification
//        ?  Column(
//          children: <Widget>[
//
//          ],
//        )
//        : PhoneContent(
//          formkey: _formKey,
//          onChanged: (value){
//            phoneNumber = value;
//            },
//          onPressed: (){
//            setState(() {
//              _formKey.currentState.validate();
//              verification = true;
//              print(phoneNumber);
//            });
//          },
//        );
//  }
//}
//
//class PhoneContent extends StatelessWidget {
//  final Function onChanged;
//  final Function onPressed;
//  final GlobalKey formkey;
//
//  PhoneContent({this.onChanged, this.onPressed, this.formkey});
//
//  @override
//  Widget build(BuildContext context) {
//
//    return Column(
//      children: <Widget>[
//        Form(
//          key: formkey,
//          child: TextFormField(
//
//          ),
//        ),
//
//      ],
//    );
//  }
//}
//
