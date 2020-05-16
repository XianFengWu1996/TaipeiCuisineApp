import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Home.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc with ChangeNotifier {
  bool _obscureText = false;
  List<String> _errorMessage = [];
  List<String> _noticeMessage = [];
  FirebaseUser _loggedInUser;

  FirebaseUser get user => _loggedInUser;
  bool get obscureText => _obscureText;
  List<String> get errorMessage => _errorMessage;
  List<String> get noticeMessage => _noticeMessage;

  // Methods for Signing in

  loginWithEmailAndPassword(String email, String password) async {
    try {
      _loggedInUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user;

      if (_loggedInUser.isEmailVerified) {
        Get.to(Home());
      } else {
        _errorMessage.add(
            'Please verify your email. If you have recently requested a verification email, check your inbox or spam.');
      }
    } catch (error) {
      switch (error.code) {
        case 'ERROR_WRONG_PASSWORD':
          _errorMessage.add('Incorrect password, try again with a different password.');
          break;
        case 'ERROR_USER_NOT_FOUND':
          _errorMessage.add('User with the email is not found.');
          break;
        default:
          _errorMessage.add('Some error has occurred, try again later.');
      }
    }
    return;
  }

  resetPasswordWithEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _noticeMessage.add('Please check your email for further instructioon on password reset.');
    } catch (error) {
      if (error.code == 'ERROR_USER_NOT_FOUND') {
        _errorMessage.add('User not found, check your email and try again');
      }
    }
    return;
  }

  signUpWithEmailAndPassword(String email, String password) async {
    try {
      (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password))
          .user
          .sendEmailVerification();
      _noticeMessage.add('Please check your inbox or spam for a verification email. Follow step in the email to be verified');

    } catch (error) {
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        _errorMessage.add('Email is already registered.');
      }
    }
    return;
  }

  loginWithFacebook(FunctionalBloc bloc) async {
    final result = await FacebookLogin().logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          final token = result.accessToken.token;
          AuthCredential credential =
              FacebookAuthProvider.getCredential(accessToken: token);

          _loggedInUser =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;

          if (_loggedInUser != null) {
            Get.to(Home());
          }
        } catch (error) {
          _errorMessage.add('An error has occur. Try again later or use a different login method.');
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        _errorMessage.add('You have cancelled Facebook login.');
        break;
      case FacebookLoginStatus.error:
        _errorMessage.add('An Error has occur with Facebook Login, try again later.');
        break;
    }
  }

  loginWithGoogle() async {
    try{
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken);

      _loggedInUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if(_loggedInUser != null){
        Get.to(Home());
      }
    } catch(error){
      _errorMessage.add('An error has occur during Google login, please try again later or use a different login method.');
    }
  }

  resetErrorMessage() {
    _errorMessage = [];
    notifyListeners();
  }

  resetNoticeMessage() {
    _noticeMessage = [];
    notifyListeners();
  }

  void showPassword(value) {
    _obscureText = value;
    notifyListeners();
  }

  void saveUser(user) {
    _loggedInUser = user;
    return;
  }

  void removeUser() {
    _loggedInUser = null;
    return;
  }

  bool _showDialogContent = true;
  bool get showDialogContent => _showDialogContent;

  enableDialog(bool show) {
    _showDialogContent = show;
    notifyListeners();
  }

  void initializeReward() async {
    await Firestore.instance
        .collection('users/${_loggedInUser.uid}/rewards')
        .document('points')
        .setData({
      'point': 0,
      'pointDetails': [],
    }, merge: true);
  }
}
