import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/screens/Auth/Login/Login.dart';
import 'package:get/get.dart';

class FunctionalBloc with ChangeNotifier{

  //Get user information from firebase once logged in
  FirebaseUser _user;

  saveLocalUser(FirebaseUser user){
    _user = user;
    notifyListeners();
  }

  //Home Page
  int _homePageIndex = 0;

  int get homePageIndex => _homePageIndex;

  void changeTab(index){
    _homePageIndex = index;
    notifyListeners();
  }

  List<DocumentSnapshot> _fullDayMenu = [];
  List<DocumentSnapshot> get fullDayMenu => _fullDayMenu;

  List<DocumentSnapshot> _lunchMenu = [];
  List<DocumentSnapshot> get lunchMenu => _lunchMenu;

  String _menuChoice = 'fullday';
  String get menuChoice => _menuChoice;

  switchMenuChoice(String choice){
    _menuChoice = choice;
    notifyListeners();
  }

  // Get Menu Data from Database
  retrieveFullDayMenu() async {
   try{
     await Firestore.instance.collection('menu/fullday/details').getDocuments().then((v){
       _fullDayMenu = v.documents;
     });
   } catch(e){
     Get.snackbar('Error', 'Failed to retrieve full day menu..', backgroundColor: Colors.red, colorText: Colors.white);
   }
  }

  retrieveLunchMenu() async {
    try{
      await Firestore.instance.collection('menu/lunch/details').getDocuments().then((v){
        _lunchMenu = v.documents;
      });
    } catch(e){
      Get.snackbar('Error', 'Failed to retrieve lunch menu', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Address

  String _street = '';
  String _city = '';
  String _zipCode = '';
  String _business = '';
  String _apt = '';

  String get street => _street;
  String get city => _city;
  String get zipCode => _zipCode;
  String get business => _business;
  String get apt => _apt;


  retrieveAddress() async {
      try{
        await Firestore.instance.collection('users/${_user.uid}/address')
            .document('details').get()
            .then((value){

          var data = value.data;
          if(data != null){
            _street = data['street'];
            _city = data['city'];
            _zipCode = data['zipcode'];
            _business = data['business'];
            _apt = data['apt'];
          }
        });
      }catch(e){
        Get.snackbar('Error', 'Failed to retrieve address information...', backgroundColor: Colors.red, colorText: Colors.white);
      }

  }

  saveAddress(changeStreet, changeCity, changeZipCode, changeApt, changeBusiness) async {
    if (_street != changeStreet || _city != changeCity || _zipCode != changeZipCode||
        _apt!= changeApt || _business != changeBusiness
    )
      try{
        await Firestore.instance.collection('users/${_user.uid}/address').document(
            'details').setData(
          {
            'street': changeStreet ,
            'city': changeCity,
            'zipcode':changeZipCode,
            'apt': changeApt,
            'business': changeBusiness,
          },
          merge: true,
        );
      }catch(e){
        Get.snackbar('Error', 'Failed to save address...', backgroundColor: Colors.red, colorText: Colors.white);
      }

  }

  // Loader
  bool _loading = false;
  bool get loading => _loading;

  toggleLoading(String type){
    if(type == 'start') {
      _loading = true;
    } else{
      _loading = false;
    }
    notifyListeners();
  }

//======================================
// Setting
//======================================

// Switch Language
  String _selectedValue = '';

  String get selectedValue => _selectedValue;

  void changeSelectedValue(String value){
    _selectedValue = value;
    notifyListeners();
  }

  updateChoiceInDB() async {
    try{
      await Firestore.instance.collection('users/${_user.uid}/language').document('detail').setData({
        'language': _selectedValue
      });
      toggleLoading('reset');
      Get.back();
    } catch(error){
      toggleLoading('reset');
      Get.snackbar('Error', 'An error has occur please try again later', colorText: Colors.white, backgroundColor: Colors.red[400]);
    }
  }

  getLanguageChoice() async{
    try{
      await Firestore.instance.collection('users/${_user.uid}/language').document('detail').get().then((val){
        if(val.exists){
          _selectedValue = val.data['language'];
        } else {
          _selectedValue = 'english';
        }
      });
      toggleLoading('reset');
    } catch(error){
      toggleLoading('reset');
      Get.snackbar('Error', 'An error has occur please try again later', colorText: Colors.white, backgroundColor: Colors.red[400]);
    }
  }


  // Change Email
  changePassword({password, auth, payment, cart}) async {
    try{
      await FirebaseAuth.instance.currentUser().then((value) async {
        await value.updatePassword(password);
        Get.defaultDialog(
            title: 'Successfully change',
            content: Text('Returning to login page'),
            confirm: RaisedButton(onPressed: ()async{
              await logout(cartBloc: cart, paymentBloc: payment, authBloc: auth);
              Get.offAll(Login());
            }, child: Text('Okay'),)
        );
      });
    }catch(e){
      if(e.code == 'ERROR_REQUIRES_RECENT_LOGIN'){
        Get.snackbar('Require recent login', 'Password change require recent login, please logout and sign back in', colorText: Colors.white, backgroundColor: Colors.red[400]);
      } else {
        Get.snackbar('Error', 'An error has occur please try again later', colorText: Colors.white, backgroundColor: Colors.red[400]);
      }
    }
  }

  void clearAllValueUponLogout(){
    _user = null;
    _homePageIndex = 0;
    _loading = false;
    _selectedValue = '';
    _street = '';
    _city = '';
    _zipCode = '';
    _business = '';
    _apt = '';
    _menuChoice = 'fullday';
    _fullDayMenu = [];
    _lunchMenu = [];
    notifyListeners();
  }

  //logout
  logout({AuthBloc authBloc, PaymentBloc paymentBloc, CartBloc cartBloc})async{
    await FirebaseAuth.instance.signOut();
    //clear value from BLOCs
    clearAllValueUponLogout();
    authBloc.clearAllValueUponLogout();
    paymentBloc.clearAllValueUponLogout();
    cartBloc.clearValueUponLogout();
  }
}
