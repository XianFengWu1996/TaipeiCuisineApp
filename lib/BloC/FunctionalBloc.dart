import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FunctionalBloc with ChangeNotifier{
  //Home Page
  int _homePageIndex = 0;

  int get homePageIndex => _homePageIndex;

  void changeTab(index){
    _homePageIndex = index;
    notifyListeners();
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


  retrieveAddress(uid) async {
      await Firestore.instance.collection('users/$uid/address')
        .document('details').get()
        .then((value){
          var data = value.data;

          _street = data['street'];
          _city = data['city'];
          _zipCode = data['zipcode'];
          _business = data['business'];
          _apt = data['apt'];
        });
      return;
  }

  // Loader
  bool _loading = false;
  bool get loading => _loading;

  toggleLoading(){
    _loading = !_loading;
    notifyListeners();
  }
}