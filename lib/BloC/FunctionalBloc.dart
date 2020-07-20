import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/screens/Auth/Login.dart';
import 'package:get/get.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class FunctionalBloc with ChangeNotifier {
  //Get user information from firebase once logged in
  FirebaseUser _user;

  FirebaseUser get user => _user;

  //Home Page
  int _homePageIndex = 0;
  int get homePageIndex => _homePageIndex;

  // =============================
  //            Menu
  // =============================

  // Get Menu Data from Database
  List<DocumentSnapshot> _fullDayMenu = [];
  List<DocumentSnapshot> _lunchMenu = [];
  String _menuChoice = 'fullday';

  List<DocumentSnapshot> get fullDayMenu => _fullDayMenu;
  List<DocumentSnapshot> get lunchMenu => _lunchMenu;
  String get menuChoice => _menuChoice;

  retrieveFullDayMenu() async {
    try {
      await Firestore.instance
          .collection('menu/fullday/details')
          .getDocuments()
          .then((v) {
        _fullDayMenu = v.documents;
      });
    } catch (e) {
      setValue('loading', 'reset');
      Get.snackbar('Error', 'Failed to retrieve full day menu..', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  retrieveLunchMenu() async {
    try {
      await Firestore.instance.collection('menu/lunch/details').getDocuments().then((v) {
        _lunchMenu = v.documents;
      });
    } catch (e) {
      setValue('loading', 'reset');
      Get.snackbar('Error', 'Failed to retrieve lunch menu', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // =============================
  //     Store Information
  // =============================

  // Handle keys for various purpose
  String _squareAppId = '';
  String _squareToken = '';
  String _squareLocationId = '';
  String _googleAndroidKey = '';
  String _googleIosKey = '';
  String _twilio_sid = '';
  String _twilio_token = '';
  String _twilio_phone = '';

  // Handle store and lunch hours
  int _storeOpen = 0;
  int _storeClose = 0;
  int _lunchStart = 0;
  int _lunchEnds = 0;

  // Handle Reward Percentage
  int _cashReward = 0;
  int _cardReward = 0;

  String get squareToken => _squareToken;
  String get squareAppId => _squareAppId;
  String get squareLocationId => _squareLocationId;
  String get androidKey => _googleAndroidKey;
  String get iosKey => _googleIosKey;
  int get storeOpen => _storeOpen;
  int get storeClose => _storeClose;
  int get lunchStart => _lunchStart;
  int get lunchEnds => _lunchEnds;
  int get cashReward => _cashReward;
  int get cardReward => _cardReward;

  retrieveStoreInfo() async {
    try {
      await Firestore.instance
          .collection('info')
          .document('details')
          .get()
          .then((value) {
        var hours = value.data['hours'];
        var key = value.data['apiKey'];
        var reward = value.data['reward_percentage'];

        // store hours
        _lunchStart = hours['_lunchStart'];
        _lunchEnds = hours['_lunchEnds'];
        _storeOpen = hours['_storeOpen'];
        _storeClose = hours['_storeClose'];
        // keys
        _googleAndroidKey = key['_google_android_key'];
        _googleIosKey = key['_google_ios_key'];
        _squareToken = key['_square_access_token'];
        _squareAppId = key['_square_application_id'];
        _squareLocationId = key['_square_location_id'];
        _twilio_sid = key['_twilio_sid'];
        _twilio_token = key['_twilio_token'];
        _twilio_phone = key['_twilio_number'];
        // reward percentage
        _cashReward = reward['cash_reward'];
        _cardReward = reward['card_reward'];
      });
    } catch (e) {
      setValue('loading', 'reset');
      Get.snackbar('Error', 'Failed to retrieve store information', backgroundColor: Colors.red, colorText: Colors.white);
    }
    notifyListeners();
  }

  // =============================
  //     Customer Information
  // =============================

  // Delivery Related
  String _deliveryAddress = '';
  String _deliveryStreet = '';
  String _deliveryCity = '';
  String _deliveryApt = '';
  String _deliveryBusiness = '';
  String _deliveryZipCode = '';
  int _deliveryFee = 0;

  // Billing Related
  String _billingFirstName = '';
  String _billingLastName = '';
  String _billingPhone = '';
  String _billingStreet = '';
  String _billingCity = '';
  String _billingZip = '';
  String _billingCofId = '';
  String _billingCustomerId = '';
  String _billingBrand = '';
  String _billingLastFourDigit = '';

  // Customer Information Related
  String _customerFirstName = '';
  String _customerLastName = '';
  String _customerPhoneNumber = '';
  List _verifiedNumbers = [];
  List get verifiedNumbers => _verifiedNumbers;

  // Language Choice related
  String _selectedLanguage = '';
  String _languageChoiceValue = '';

  String get deliveryAddress => _deliveryAddress;
  String get deliveryStreet => _deliveryStreet;
  String get deliveryCity => _deliveryCity;
  int get deliveryFee => _deliveryFee;
  String get deliveryApt => _deliveryApt;
  String get deliveryBusiness => _deliveryBusiness;
  String get deliveryZipCode => _deliveryZipCode;
  String get billingFirstName => _billingFirstName;
  String get billingLastName => _billingLastName;
  String get billingPhone => _billingPhone;
  String get billingStreet => _billingStreet;
  String get billingCity => _billingCity;
  String get billingZip => _billingZip;
  String get billingCofId => _billingCofId;
  String get billingCustomerId => _billingCustomerId;
  String get billingBrand => _billingBrand;
  String get billingLastFourDigit => _billingLastFourDigit;
  String get customerFirstName => _customerFirstName;
  String get customerLastName => _customerLastName;
  String get customerPhoneNumber => _customerPhoneNumber;
  String get selectedLanguage => _selectedLanguage;
  String get languageChoiceValue => _languageChoiceValue;

  retrieveCustomerInformation() async {
    try {
      await Firestore.instance
          .collection('users/${_user.uid}/customer_information')
          .document('details')
          .get()
          .then((value) async {

        var address = value.data['address'];
        var billing = value.data['billing'];
        var customer = value.data['customer'];
        var language = value.data['language'];

        // Handle customer selected language
        _selectedLanguage = language['language'];
        _languageChoiceValue = language['language'];

        // Handle user address information
        _deliveryStreet = address['street'];
        _deliveryCity = address['city'];
        _deliveryZipCode = address['zipcode'];
        _deliveryApt = address['apt'];
        _deliveryBusiness = address['business'];
        _deliveryFee = address['fee'].toInt();

        // Handle user billing information
        _billingFirstName = billing['firstName'];
        _billingLastName = billing['lastName'];
        _billingPhone = billing['phone'];
        _billingStreet = billing['street'];
        _billingCity = billing['city'];
        _billingZip = billing['zip'];
        _billingCofId = billing['cofId'];
        _billingCustomerId = billing['customerId'];
        _billingBrand = billing['brand'];
        _billingLastFourDigit = billing['lastFourDigit'];

        // Handle customer information
        _customerFirstName = customer['firstName'];
        _customerLastName = customer['lastName'];
        _customerPhoneNumber = customer['phone'];
        _verifiedNumbers = customer['verifiedNumbers'];
        }

      );
      if (_deliveryStreet == '' &&
          _deliveryCity == '' &&
          _deliveryZipCode == '') {
        _deliveryAddress = '';
      } else {
        _deliveryAddress =
            '$_deliveryStreet \n$_deliveryCity $_deliveryZipCode '
            '${deliveryApt != '' ? 'Apt: $_deliveryApt' : ''}';

      }
    } catch (e) {
      setValue('loading', 'reset');
      Get.snackbar('Error', 'Failed to retrieve address information...',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    notifyListeners();
  }

  initUserInfo() async {
    try {
      await Firestore.instance
          .collection('users/${_user.uid}/customer_information')
          .document('details')
          .setData({
        'address': {
          'street': '',
          'city': '',
          'zipcode': '',
          'apt': '',
          'business': '',
          'fee': 0
        },
        'billing': {
          "firstName": '',
          "lastName": '',
          "phone": '',
          "street": '',
          "city": '',
          "zip": '',
          "customerId": '',
          "cofId": '',
          "brand": '',
          "lastFourDigit": '',
        },
        'customer': {
          'firstName': '',
          'lastName': '',
          'phone': '',
          'verifiedNumbers': []
        },
        'language': {'language': 'english'},
      }, merge: true);
      await retrieveCustomerInformation();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize user information...',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  bool _requireVerification = false;
  bool _showPinField = false;
  bool _countFinished = true;
  bool _allowResend = false;
  String _smsCode = '';
  bool _successful = false;

  bool get requireVerification => _requireVerification;
  bool get showPinField => _showPinField;
  bool get countFinished => _countFinished;
  bool get allowResend => _allowResend;
  String get smsCode => _smsCode;
  bool get successful => _successful;

  TwilioFlutter twilioFlutter;
  // SMS Verification
  initializeVerification(String phone) async{
    await generateOTP();
    _countFinished = false;
    _showPinField = true;



    twilioFlutter = TwilioFlutter(
        accountSid : _twilio_sid, // replace *** with Account SID
        authToken : _twilio_token,  // replace xxx with Auth Token
        twilioNumber : '+1$_twilio_phone'  // replace .... with Twilio Number
    );

    twilioFlutter.sendSMS(
        toNumber : '+1$phone',
        messageBody : '${selectedLanguage == 'english' ? 'Your Verification Code is: $_smsCode ' : '您的验证码是： $_smsCode'}');

    notifyListeners();
  }

  generateOTP(){
    // generate an opt from 0100 - 9999
    int randomNumber = Random().nextInt(9899) + 100;
    _smsCode = randomNumber < 1000 ? '0$randomNumber' : randomNumber.toString();
    print(_smsCode);
  }

  resendCode(phone){
    _countFinished = false;
    _allowResend = false;
      twilioFlutter = TwilioFlutter(
        accountSid : _twilio_sid, // replace *** with Account SID
        authToken : _twilio_token,  // replace xxx with Auth Token
        twilioNumber : '+1$_twilio_phone'  // replace .... with Twilio Number
    );

    twilioFlutter.sendSMS(
        toNumber : '+1$phone',
        messageBody : '${selectedLanguage == 'english' ? 'Your Verification Code is: $_smsCode ' : '您的验证码是： $_smsCode'}');
  notifyListeners();
  }

  // Handle loading
  bool _loading = false;
  bool get loading => _loading;

  // Handle language update
  updateChoiceInDB() async {
    try {
      await Firestore.instance
          .collection('users/${_user.uid}/customer_information')
          .document('details')
          .setData({
        'language': {
          'language': _languageChoiceValue,
        }
      }, merge: true);
      _selectedLanguage = _languageChoiceValue;
      setValue('loading', 'reset');
      Get.back();
    } catch (error) {
      setValue('loading', 'reset');
      Get.snackbar('Error', 'An error has occur please try again later',
          colorText: Colors.white, backgroundColor: Colors.red[400]);
    }
  }

  // Handle Changing Password
  changePassword({password, AuthBloc auth, PaymentBloc payment, CartBloc cart}) async {
    try {
      await FirebaseAuth.instance.currentUser().then((value) async {
        await value.updatePassword(password);
        Get.defaultDialog(
            title: 'Successfully change',
            content: Text('Returning to login page'),
            confirm: RaisedButton(
              onPressed: () async {
                await logout(
                  authLogout: auth.clearAllValueUponLogout(),
                  cartLogout: cart.clearValueUponLogout(),
                  paymentLogout: payment.clearAllValueUponLogout(),
                );
                Get.offAll(Login());
              },
              child: Text('Okay'),
            ));
      });
    } catch (e) {
      if (e.code == 'ERROR_REQUIRES_RECENT_LOGIN') {
        setValue('loading', 'reset');
        Get.snackbar('Require recent login', 'Password change require recent login, please logout and sign back in', colorText: Colors.white, backgroundColor: Colors.red[400]);
      } else {
        setValue('loading', 'reset');
        Get.snackbar('Error', 'An error has occur please try again later', colorText: Colors.white, backgroundColor: Colors.red[400]);
      }
    }
  }

  clearAllValueUponLogout() {
    _user = null;
    _homePageIndex = 0;
    _loading = false;
    _menuChoice = 'fullday';
    _fullDayMenu = [];
    _lunchMenu = [];
    _storeOpen = 0;
    _storeClose = 0;
    _lunchStart = 0;
    _lunchEnds = 0;
    _cashReward = 0;
    _cardReward = 0;
    _squareAppId = '';
    _squareToken = '';
    _squareLocationId = '';
    _googleAndroidKey = '';
    _googleIosKey = '';
    _twilio_phone = '';
    _twilio_token = '';
    _twilio_sid = '';
    _smsCode = '';
     _requireVerification = false;
    _showPinField = false;
    _countFinished = true;
    _allowResend = false;
    _successful = false;
    _deliveryAddress = '';
    _deliveryStreet = '';
    _deliveryCity = '';
    _deliveryApt = '';
    _deliveryBusiness = '';
    _deliveryZipCode = '';
    _deliveryFee = 0;
    _billingFirstName = '';
    _billingLastName = '';
    _billingPhone = '';
    _billingStreet = '';
    _billingCity = '';
    _billingZip = '';
    _billingCofId = '';
    _billingCustomerId = '';
    _billingBrand = '';
    _billingLastFourDigit = '';
    _customerFirstName = '';
    _customerLastName = '';
    _customerPhoneNumber = '';
    _verifiedNumbers = [];
    _selectedLanguage = '';
    _languageChoiceValue = '';
    notifyListeners();
  }

  //logout
  logout({authLogout, paymentLogout, cartLogout}) async {
    await FirebaseAuth.instance.signOut();
    //clear value from BLOCs
    await clearAllValueUponLogout();
    await authLogout;
    await paymentLogout;
    await cartLogout;
  }

  //set value
  setValue(type, value) {
    switch (type) {
      case 'language':
        _languageChoiceValue = value;
        break;
      case 'loading':
        value == 'start' ? _loading = true : _loading = false;
        break;
      case 'menuChoice':
        _menuChoice = value;
        break;
      case 'changeTab':
        _homePageIndex = value;
        break;
      case 'saveUser':
        _user = value;
        break;
      case 'customerInfo':
        _customerFirstName = value['firstName'];
        _customerLastName = value['lastName'];
        _customerPhoneNumber = value['phone'];
        if(!_verifiedNumbers.contains(value['phone'])){
          _verifiedNumbers.add(value['phone']);
        }
        break;
      case 'customerId':
        _billingCustomerId = value;
        break;
      case 'card_info':
        _billingCofId = value['cofId'];
        _billingBrand = value['brand'];
        _billingLastFourDigit = value['lastFourDigit'];
        break;
      case 'billing':
        _billingFirstName = value['firstName'];
        _billingLastName = value['lastName'];
        _billingPhone = value['phone'];
        _billingStreet = value['street'];
        _billingCity = value['city'];
        _billingZip = value['zip'];
        break;
      case 'getAddress':
        _deliveryStreet = value['street'];
        _deliveryCity = value['city'];
        _deliveryZipCode = value['zipcode'];
        _deliveryApt = value['apt'];
        _deliveryBusiness = value['business'];
        _deliveryFee = value['deliveryFee'];
        _deliveryAddress = value['address'];
        break;
      case 'checkPhoneNumber':
        if(_customerPhoneNumber == value){
          return true;
        } else {
          return false;
        }
        break;
      case 'verification':
        _requireVerification = value;
        break;
      case 'showPinField':
        _showPinField = value;
        break;
      case 'countFinished':
        _countFinished = value;
        break;
      case 'allowResend':
        _allowResend= value;
        break;
      case 'successful':
        _successful = value;
        break;
      case 'resetSMS':
        _requireVerification = false;
        _showPinField = false;
        _countFinished = true;
        _allowResend = false;
        _successful = false;
        _smsCode = '';
        break;
      default:
        break;
    }
    notifyListeners();
  }
}
