import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/screens/Auth/EmailResend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders/Orders.dart';
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
      var _maintenance = admin.data['maintenance']['ongoing'];
      var _userAllowed = admin.data['maintenance']['userAllowed'];


      if(_loggedInUser.uid == '${admin.data['uid']}'){
        functionalBloc.setValue('loading','reset');
        await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);
        await storeBloc.saveLocalUser(_loggedInUser);
        Get.offAll(Orders(status: 'Placed',));
      } else if (_loggedInUser.isEmailVerified) {
        if(_maintenance){
          if(_userAllowed.contains(_loggedInUser.uid)){
            await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

            Get.offAll(Home());

            functionalBloc.setValue('loading','reset');
          } else {
            functionalBloc.setValue('loading', 'reset');
            _loggedInUser = null;
            Get.snackbar('${functionalBloc.loginLanguage == 'english' ? 'Maintenance' : '系统维修中'}',
                '${functionalBloc.loginLanguage == 'english' ? 'The app is under maintenance, please try again later.': '我们正在进行维修，请稍后再试'}');
          }

        } else {
          await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

          Get.offAll(Home());

          functionalBloc.setValue('loading','reset');
        }
      } else {
        functionalBloc.setValue('loading','reset');
        _errorMessage.add('${functionalBloc.loginLanguage == 'english'
            ? 'Please verify your email. If you have recently requested a verification email, check your inbox or spam.'
            : '请查阅您的邮箱。如果您最近有申请发送验证邮件，请查看邮箱跟垃圾箱里的邮件。'}');
        Get.dialog(Resend());
      }
    } catch (error) {
      functionalBloc.setValue('loading','reset');
      switch (error.code) {
        case 'ERROR_WRONG_PASSWORD':
          _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'Incorrect password, try again with a different password.': '密码错误。请重新输入密码。'}');
          break;
        case 'ERROR_USER_NOT_FOUND':
          _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'User with the email is not found.': '用戶不存在'}');
          break;
        default:
          _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'Some error has occurred, try again later.': '出现错误，请稍后再试。'}');
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

          var admin = await Firestore.instance.collection('admin').document('details').get();
          var _maintenance = admin.data['maintenance']['ongoing'];

          if(!_maintenance){
            if (_loggedInUser != null) {
              await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

              Get.offAll(Home());

              functionalBloc.setValue('loading','reset');
            }
          } else {
            functionalBloc.setValue('loading', 'reset');
            _loggedInUser = null;
            Get.snackbar('${functionalBloc.loginLanguage == 'english' ? 'Maintenance' : '系统维修中'}',
                '${functionalBloc.loginLanguage == 'english' ? 'The app is under maintenance, please try again later.': '我们正在进行维修，请稍后再试'}');          }

        } catch (error) {
          functionalBloc.setValue('loading','reset');
          _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'An error has occur. Try again later.': '出现错误，请稍后再试。'}');
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        functionalBloc.setValue('loading','reset');
        _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'You have cancelled Facebook login.': '您取消了Facebook登陆。'}');
        break;
      case FacebookLoginStatus.error:
        functionalBloc.setValue('loading','reset');
        _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'An Error has occur with Facebook Login, try again later.': 'Facebook登陆出现异常。请稍后再试。'}');
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

      var admin = await Firestore.instance.collection('admin').document('details').get();
      var _maintenance = admin.data['maintenance']['ongoing'];

      if(!_maintenance){
        if(_loggedInUser != null){
          await retrieveAndDistributeInfo(functionalBloc, cartBloc, paymentBloc);

          Get.offAll(Home());

          functionalBloc.setValue('loading','reset');
        }
      } else {
        functionalBloc.setValue('loading', 'reset');
        _loggedInUser = null;
        Get.snackbar('${functionalBloc.loginLanguage == 'english' ? 'Maintenance' : '系统维修中'}',
            '${functionalBloc.loginLanguage == 'english' ? 'The app is under maintenance, please try again later.': '我们正在进行维修，请稍后再试'}');      }


    } catch(error){
      _errorMessage.add('${functionalBloc.loginLanguage == 'english' ? 'An error has occur during Google login, please try again later or use a different login method.': 'Google登陆出现异常。请稍后再试。'}');
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
      'customer_endpoint': functionalBloc.customerEndPoint,
      'payment_endpoint': functionalBloc.paymentEndPoint,
    });


  }

  resetPasswordWithEmail(String email, FunctionalBloc functionalBloc) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _noticeMessage.add('${functionalBloc.loginLanguage == 'english'
            ? 'Please check your email for further instructioon on password reset.'
            : '查看邮箱里的密码重置邮件。'}');
    } catch (error) {
      if (error.code == 'ERROR_USER_NOT_FOUND') {
        _errorMessage.add('${functionalBloc.loginLanguage == 'english' ?'User not found, check your email and try again' :'用户不存在。'}');
      }
    }
    return;
  }

  signUpWithEmailAndPassword(String email, String password, FunctionalBloc functionalBloc) async {
    try {
      (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password))
          .user
          .sendEmailVerification();
      _noticeMessage.add('${functionalBloc.loginLanguage == 'english' ? 'Please check your inbox or spam for a verification email. Follow step in the email to be verified' : '请查看邮箱里的验证邮件来验证你的账号。'}');

    } catch (error) {
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        _errorMessage.add('${functionalBloc.loginLanguage =='english' ? 'Email is already registered.': '邮件已被注册。'}');
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

  clearAllValueUponLogout(){
    _obscureText = false;
    _errorMessage = [];
    _noticeMessage = [];
    _loggedInUser = null;
    _showDialogContent = true;
    notifyListeners();
  }
}
