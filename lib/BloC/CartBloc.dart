import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/Model/CartItem.dart';
import 'package:food_ordering_app/Model/Product.dart';
import 'package:http/http.dart' as http;

class CartBloc with ChangeNotifier {

  List<CartItem> _items = [];

  int _cartItemTotal = 0;

  int get cartItemTotal => _cartItemTotal;

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items);

  // ----------------------------------------------------------------
  //Cart Functionality
  // ----------------------------------------------------------------

  void addToCart(Product product, [int count = 1]) {
    for (CartItem item in _items) {
      if (product.foodId == item.product.foodId) {
        _cartItemTotal += 1;
        notifyListeners();
      }

      if (product.foodId == item.product.foodId) {
        calculateTotal('add', product.price);
        item.count += 1;
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
          item.count += 1;
          calculateTotal('add', item.product.price);
          _cartItemTotal += 1;
        }

        if (action == 'remove') {
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


  String get subtotal => _subtotal > 0 ? _subtotal.toStringAsFixed(2) : 0.00.toStringAsFixed(2);

  String get tax => _tax > 0 ? _tax.toStringAsFixed(2) : 0.00.toStringAsFixed(2);

  String get tip => _tip.toStringAsFixed(2);

  String get total => _total > 0 ? _total.toStringAsFixed(2) : 0.00.toStringAsFixed(2);

  double get tipPercent => _tipPercent;

  double get customTip => _customTip;

  double get deliveryFee => _deliveryFee;

  int get rewardPoint => _rewardPoint;

  void isCustomTip(bool isCustom, String tip) {
    _isCustomTip = isCustom;
    _customTip = double.parse(tip);
    calculateTotal('add', 0);

    notifyListeners();
  }

  void calculateTotal(action, price, [count = 1]) {
    action == 'add' ? _subtotal += (price * count) : _subtotal -=
    (price * count);
    _tax = double.parse((_subtotal * 0.07).toStringAsFixed(2));
    _tip = !_isCustomTip ? double.parse(((_subtotal + _tax) * _tipPercent).toStringAsFixed(2)) : _customTip;
    _total = double.parse((_subtotal + _tax + _tip + (_isDelivery ? deliveryFee : 0.00) - (_rewardPoint != 0 ? (_rewardPoint/100) : 0.00)).toStringAsFixed(2));
  }

  void clearTip() {
    _tipPercent = 0.0;

    calculateTotal('add', 0);
    notifyListeners();
  }

  void clearCustomTip() {
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


  getAddress(uid) async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection(
        'users/$uid/address').getDocuments();

    if (querySnapshot.documents.length > 0) {
      querySnapshot.documents.forEach((f) {
        _street = f.data['street'];
        _city = f.data['city'];
        _zipCode = f.data['zipcode'];
        _apt = f.data['apt'];
        _businessName = f.data['business'];
        _distance = f.data['distance'];
        _address = '$_street, \n$_city, $zipCode ${apt != '' ? 'Apt ': ''}$apt';
      });
      await calculateDeliveryFee(_distance);
    } else {
      _address = '';
    }

    notifyListeners();
  }

  saveAddress(uid, changeStreet, changeCity, changeZipCode, changeApt, changeBusiness) async {
    if (_street != changeStreet ||
        _city != changeCity ||
        _zipCode != changeZipCode||
        _apt!= changeApt ||
        _businessName != changeBusiness
    ) {

      // it will return the value of lat and long
      // geolocation[0] = lat, geolocation[1] = long
      var geolocation = await geoCoding(changeStreet, changeCity);

      var calcDistance = await calculateDistance(geolocation[0], geolocation[1]);

      await Firestore.instance.collection('users/$uid/address').document(
          'details').setData(
          {
            'street': changeStreet,
            'city': changeCity,
            'zipcode': changeZipCode,
            'apt': changeApt,
            'business': changeBusiness,
            'distance': calcDistance,
          },
        merge: true,
      );
      getAddress(uid);
    }

  }

  calculateDeliveryFee(int dis){
    double mile = dis / 1609.34;
    if(mile < 2.1){
      _deliveryFee = 2.0;
    } else if(mile >= 2.1 && mile <= 6.9){
      _deliveryFee = mile.ceilToDouble();
    } else {
      print('Unable to deliver');
    }
    calculateTotal('add', 0);
    notifyListeners();
  }

  Future<dynamic> geoCoding(street, city) async {
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?'
        'address=$street,'
        '+$city,+MA&'
        'key=AIzaSyBr8V73HvpVK27Uw7XkDT6Mdwz_wWHQ-ek';

    var result = await http.get(url);
    var data = jsonDecode(result.body);

    var lat = data['results'][0]['geometry']['location']['lat'];
    var long = data['results'][0]['geometry']['location']['lng'];

    return [lat, long];
  }

  Future<dynamic> calculateDistance(lat, long) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial'
        '&origins=42.274220,-71.024369'
        '&destinations=$lat, $long'
        '&key=AIzaSyBr8V73HvpVK27Uw7XkDT6Mdwz_wWHQ-ek';
    var result = await http.get(url);
    var data = jsonDecode(result.body);

    return data['rows'][0]['elements'][0]['distance']['value'];
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
    _isCustomTip = false;
    _customTip = 0;
    _isDelivery = false;
    _choice = '';
    _rewardPoint = 0;
    notifyListeners();
  }

  void clearValueUponLogout(){
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
    _tipPercent = 0;
    _isCustomTip = false;
    _customTip = 0;
    _deliveryFee = 0;
    _cartItemTotal = 0;
    _items = [];
    notifyListeners();
  }
}