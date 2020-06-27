import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/Model/CartItem.dart';
import 'package:food_ordering_app/Model/Product.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CartBloc with ChangeNotifier {

  //Get user information from firebase once logged in
  FirebaseUser _user;

  saveLocalUser(FirebaseUser user){
    _user = user;
    notifyListeners();
  }

  List<CartItem> _items = [];

  int _cartItemTotal = 0;

  int _lunchCount = 0;

  int get cartItemTotal => _cartItemTotal;

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items);

  // ----------------------------------------------------------------
  //Cart Functionality
  // ----------------------------------------------------------------

  void addToCart(Product product,[int count = 1]) {

    if(product.lunch != null && product.lunch){
      _lunchCount++;
    }

    for (CartItem item in _items) {
      if (product.foodId == item.product.foodId) {
        _cartItemTotal += 1;
        calculateTotal('add', product.price);
        item.count += 1;
        notifyListeners();
        return;
      }
    }

    _items.add(CartItem(product: product, count: count));
    calculateTotal('add', product.price);
    _cartItemTotal += 1;

    notifyListeners();
  }

  void deleteItem(foodId, count, price) {
    _items.removeWhere((item) => item.product.foodId == foodId);
    calculateTotal('subtract', price, count);
    _cartItemTotal -= count;

    notifyListeners();
  }

  void updateQuantity(action, foodId) {
    for (CartItem item in _items) {
      if (item.product.foodId == foodId) {
        if (action == 'add') {
          if(item.product.lunch != null && item.product.lunch){
            _lunchCount++;
          }
          item.count += 1;
          calculateTotal('add', item.product.price);
          _cartItemTotal += 1;
        }

        if (action == 'remove') {
          if(item.product.lunch != null && item.product.lunch){
            _lunchCount--;

          }
          if (item.count > 1) {
            item.count -= 1;
            _cartItemTotal -= 1;
            calculateTotal('subtract', item.product.price);
          } else {
            deleteItem(foodId, 1, item.product.price);
            return;
          }
        }
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items = [];
    _cartItemTotal = 0;
    _subtotal = 0;
    _tax = 0;
    _tip = 0;
    _total = 0;
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // Calculate Totals
  // ----------------------------------------------------------------

  double _subtotal = 0;
  double _tax = 0;
  double _tip = 0;
  double _total = 0;
  double _tipPercent = 0;
  bool _isCustomTip = false;
  double _customTip = 0;
  double _deliveryFee = 0;
  int _rewardPoint = 0;
  double _lunchDiscount = 0.00;
  double _calcSubtotal = 0.00;



  double get subtotal => _subtotal > 0 ? _subtotal : 0;

  double get calcSubtotal => _calcSubtotal;

  double get tax => _tax > 0 ? _tax : 0;

  double get tip => _tip;

  double get total => _total > 0 ? _total : 0;

  double get tipPercent => _tipPercent;

  double get customTip => _customTip;

  double get deliveryFee => _deliveryFee;

  int get rewardPoint => _rewardPoint;

  double get lunchDiscount => _lunchDiscount;


  void isCustomTip(bool isCustom, String tip) {
    _isCustomTip = isCustom;
    _customTip = double.parse(tip);
    calculateTotal('add', 0);

    notifyListeners();
  }

  void calculateTotal(action, price, [count = 1]) {
    action == 'add' ? _subtotal += ((price * count)) : _subtotal -= (price * count);
    _calcSubtotal = (_subtotal - (_rewardPoint != 0 ? (_rewardPoint/100) : 0.00) - _lunchDiscount);
    _tax = (_calcSubtotal * 0.07);
    _tip = !_isCustomTip ? ((_calcSubtotal + _tax) * _tipPercent) : _customTip;
    _total = ((_calcSubtotal + _tax + _tip + (_isDelivery ? deliveryFee : 0.00)));
  }

  void resetTipPercent() {
    _tipPercent = 0.0;
    _customTip = 0.0;
    _isCustomTip = false;

    calculateTotal('add', 0);
    notifyListeners();
  }

  void getTipPercent(double percent) {
    _tipPercent = percent;
    calculateTotal('add', 0);

    notifyListeners();
  }

  void useRewardPoint(int point){
    _rewardPoint = point;
    calculateTotal('add', 0);

    notifyListeners();
  }

  void calculateLunchDiscount(){
    if(TimeOfDay.now().hour * 60 + TimeOfDay.now().minute >= 660 && TimeOfDay.now().hour * 60 + TimeOfDay.now().minute <= 990){
      if(_lunchCount < 3){
        _lunchDiscount = 0;
      }

      if(_lunchCount % 3 == 0){
        _lunchDiscount = (_lunchCount / 3) * 3.9;
        calculateTotal('add', 0);
      }
    } else {
      _lunchDiscount = 0;
      calculateTotal('add', 0);
    }

    notifyListeners();
  }

  // ----------------------------------------------------------------
  // Choose pickup or delivery
  // ----------------------------------------------------------------

  bool _isDelivery = false;
  String _choice = '';

  String get choice => _choice;
  bool get isDelivery => _isDelivery;

  void checkChoice(choice){
    choice == 'delivery' ? _isDelivery = true : _isDelivery = false;
    calculateTotal('add', 0);
    notifyListeners();
  }


  // ----------------------------------------------------------------
  // Address and Delivery Functionality
  // ----------------------------------------------------------------

  String _address = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  String _apt = '';
  String _businessName = '';
  int _distance = 0;

  String get address => _address;
  String get street => _street;
  String get city => _city;
  String get zipCode => _zipCode;
  String get apt => _apt;
  String get businessName => _businessName;
  int get distance => _distance;


  getAddress() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection(
        'users/${_user.uid}/address').getDocuments();

    if (querySnapshot.documents.length > 0) {
      querySnapshot.documents.forEach((f) {
        _street = f.data['street'];
        _city = f.data['city'];
        _zipCode = f.data['zipcode'];
        _apt = f.data['apt'];
        _businessName = f.data['business'];
        _deliveryFee = f.data['deliveryFee'];
        _address = '$_street, \n$_city, $zipCode ${apt != '' ? 'Apt ': ''}$apt';
      });
    } else {
      _address = '';
    }

    notifyListeners();
  }

  saveAddress(changeStreet, changeCity, changeZipCode, changeApt, changeBusiness) async {
    if (_street != changeStreet || _city != changeCity || _zipCode != changeZipCode|| _apt!= changeApt || _businessName != changeBusiness) {

      // it will return the value of lat and long
      // geolocation[0] = lat,
      // geolocation[1] = long
      // geolocation[2] = street number
      // geolocation[3] = street name
      // geolocation[4] = city
      // geolocation[5] = zipcode
      var geolocation = await geoCoding(changeStreet, changeCity);

      var calcDistance = await calculateDistance(geolocation[0], geolocation[1]);

      await calculateDeliveryFee(calcDistance);

      if(_deliveryFee != 0.0){
        await Firestore.instance.collection('users/${_user.uid}/address').document(
            'details').setData(
          {
            'street': '${geolocation[2]} ' + '${geolocation[3]}' ,
            'city': geolocation[4],
            'zipcode':geolocation[5],
            'apt': changeApt,
            'business': changeBusiness,
            'deliveryFee': _deliveryFee,
          },
          merge: true,
        );
      }

      getAddress();
    }

  }

  calculateDeliveryFee(int dis){
    double mile = (dis / 1609.34);
    if(mile < 2.1){
      _deliveryFee = 2.0;
    } else if(mile >= 2.1 && mile <= 6.0){
      _deliveryFee = mile.ceilToDouble();
    } else {
      _deliveryFee = 0.0;
      Get.snackbar('Unable to deliver to this address', 'Please double check address, we are only able to deliver within 6 miles', backgroundColor: Colors.orange[300], colorText: Colors.white);
    }
    calculateTotal('add', 0);
    notifyListeners();
  }

  Future<dynamic> geoCoding(street, city) async {
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?'
        'address=$street,+$city,+MA&key=$_googleIos';

    var result = await http.get(url);
    print(result.body);
    var data = jsonDecode(result.body)['results'][0];


    var lat, long, streetNumber, streetName, cityName, zipCode;

    if(data['address_components'].last['types'][0] == 'postal_code_suffix'){
      data['address_components'].removeLast();

      lat = data['geometry']['location']['lat'];
      long = data['geometry']['location']['lng'];
      streetNumber =data['address_components'][0]['long_name'];
      streetName =data['address_components'][1]['long_name'];
      cityName = data['address_components'][2]['long_name'];
      zipCode = data['address_components'].last['long_name'];
    }

    return [lat, long, streetNumber, streetName, cityName, zipCode];
  }

  Future<dynamic> calculateDistance(lat, long) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial'
        '&origins=42.274220,-71.024369'
        '&destinations=$lat, $long'
        '&key=$_googleIos';
    var result = await http.get(url);
    var data = jsonDecode(result.body);

    return data['rows'][0]['elements'][0]['distance']['value'];
  }

  String _googleIos = '';
  String _googleAndroid = '';

  String get googleIos => _googleIos;
  String get googleAndroid => _googleAndroid;

  // retrieve keys
  retrieveKeys()async{
    try{
      var result = await Firestore.instance.collection('apikey').document('details').get();
      _googleIos = result.data['google_ios_key'];
      _googleAndroid = result.data['google_android_key'];
    } catch(e){
      Get.snackbar('Error', 'An unexpected error has occurred, please try again later.');
    }
  }

  // clear all the values in this provider
  void clearValueUponCheckout(){
    _items = [];
    _cartItemTotal = 0;
    _subtotal = 0;
    _tax = 0;
    _tip = 0;
    _total = 0;
    _tipPercent = 0;
    _lunchCount = 0;
    _isCustomTip = false;
    _customTip = 0;
    _isDelivery = false;
    _choice = '';
    _rewardPoint = 0;
    notifyListeners();
  }

  void clearValueUponLogout(){
    _user = null;
    _address = '';
    _street = '';
    _city = '';
    _zipCode = '';
    _apt = '';
    _businessName = '';
    _distance = 0;
    _isDelivery = false;
    _subtotal = 0;
    _tax = 0;
    _tip = 0;
    _total = 0;
    _calcSubtotal = 0;
    _lunchDiscount = 0;
    _googleIos = '';
    _googleAndroid = '';
    _lunchCount = 0;
    _tipPercent = 0;
    _isCustomTip = false;
    _customTip = 0;
    _deliveryFee = 0;
    _cartItemTotal = 0;
    _items = [];
    _choice = '';
    _rewardPoint = 0;
    notifyListeners();
  }
}