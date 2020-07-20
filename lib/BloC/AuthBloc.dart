import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/screens/Auth/EmailResend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders.dart';
import 'package:TaipeiCuisine/screens/Home.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc with ChangeNotifier {
  bool _obscureText = false;
  List<dynamic> _errorMessage = [];
  List<dynamic> _noticeMessage = [];
  FirebaseUser _loggedInUser;
  bool _showDialogContent = true;

  FirebaseUser get user => _loggedInUser;
  bool get obscureText => _obscureText;
  List<dynamic> get errorMessage => _errorMessage;
  List<dynamic> get noticeMessage => _noticeMessage;
  bool get showDialogContent => _showDialogContent;

  // Methods for Signing in

  loginWithEmailAndPassword(String email, String password, StoreBloc storeBloc, FunctionalBloc functionalBloc, PaymentBloc paymentBloc, CartBloc cartBloc) async {
    try {
      _loggedInUser = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user;

      var admin = await Firestore.instance.collection('admin').document('details').get();

      if(_loggedInUser.uid == '${admin.data['uid']}'){
        functionalBloc.setValue('loading','reset');
        await storeBloc.saveLocalUser(_loggedInUser);
        Get.offAll(Orders(status: 'Placed',));
      } else if (_loggedInUser.isEmailVerified) {
        await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

        Get.offAll(Home());

        functionalBloc.setValue('loading','reset');
      } else {
        functionalBloc.setValue('loading','reset');
        _errorMessage.add('Please verify your email. If you have recently requested a verification email, check your inbox or spam.');
        Get.dialog(Resend());
      }
    } catch (error) {
      functionalBloc.setValue('loading','reset');
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

  loginWithFacebook(FunctionalBloc functionalBloc, PaymentBloc paymentBloc, CartBloc cartBloc) async {
    final result = await FacebookLogin().logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        try {
          final token = result.accessToken.token;
          AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: token);

          _loggedInUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

          if (_loggedInUser != null) {
            await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

            Get.offAll(Home());

            functionalBloc.setValue('loading','reset');
          }
        } catch (error) {
          functionalBloc.setValue('loading','reset');
          _errorMessage.add('An error has occur. Try again later or use a different login method.');
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        functionalBloc.setValue('loading','reset');
        _errorMessage.add('You have cancelled Facebook login.');
        break;
      case FacebookLoginStatus.error:
        functionalBloc.setValue('loading','reset');
        _errorMessage.add('An Error has occur with Facebook Login, try again later.');
        break;
    }
  }

  loginWithGoogle(FunctionalBloc functionalBloc, PaymentBloc paymentBloc, CartBloc cartBloc) async {
    try{
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken);

      _loggedInUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if(_loggedInUser != null){
        await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

        Get.offAll(Home());

        functionalBloc.setValue('loading','reset');
      }
    } catch(error){
      _errorMessage.add('An error has occur during Google login, please try again later or use a different login method.');
      functionalBloc.setValue('loading','reset');
    }
  }

  retrieveAndDistributeInfo(FunctionalBloc functionalBloc, CartBloc cartBloc, PaymentBloc paymentBloc) async {
    await functionalBloc.setValue('saveUser',_loggedInUser);
    await paymentBloc.setValue('saveUser',_loggedInUser);
    await cartBloc.setValue('saveUser',_loggedInUser);

    // Retrieve menu information
    await functionalBloc.retrieveFullDayMenu();
    await functionalBloc.retrieveLunchMenu();


    // Pass keys to necessary bloc after it's retrieved
    await functionalBloc.retrieveStoreInfo();
    await Firestore.instance.collection('users/${_loggedInUser.uid}/customer_information').document('details').get().then((value) async {
      value.data == null ? await functionalBloc.initUserInfo() : await functionalBloc.retrieveCustomerInformation();
    });
    await cartBloc.setValue('getKey', {
      'ios_key': functionalBloc.iosKey,
      'android_key': functionalBloc.androidKey
    });
    await paymentBloc.setValue('getKey', {
      'token': functionalBloc.squareToken,
      'appId': functionalBloc.squareAppId,
      'locationId': functionalBloc.squareLocationId,
    });


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


  setValue(String type, value){
    switch(type){
      case 'errMsg':
        _errorMessage = value;
        break;
      case 'ntcMsg':
        _noticeMessage = value;
        break;
      case 'showPass':
        _obscureText = value;
        break;
      case 'enableDialog':
        _showDialogContent = value;
        break;
      default:
        return;
    }
    notifyListeners();
  }


  void initializeReward() async {
    try{
      await Firestore.instance
          .collection('users/${_loggedInUser.uid}/rewards')
          .document('points')
          .setData({
        'point': 0,
        'pointDetails': [],
      }, merge: true);
    } catch(e){
      Get.snackbar('Error', 'An unexpected error has occurred, try again later.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  clearAllValueUponLogout(){
    _obscureText = false;
    _errorMessage = [];
    _noticeMessage = [];
    _loggedInUser = null;
    _showDialogContent = true;
    notifyListeners();
  }
}
