import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:food_ordering_app/components/Buttons/RoundIconLogin.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_ordering_app/screens/Auth/OtherSigninMethods/PhoneVerification.dart';

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
               try{
                 final token = result.accessToken.token;
                 AuthCredential credential =
                 FacebookAuthProvider.getCredential(accessToken: token);

                 FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

                 if(user != null){
                   Navigator.pushReplacementNamed(context, Home.id);
                 }

               } catch(e){
                 print(e);
               }
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