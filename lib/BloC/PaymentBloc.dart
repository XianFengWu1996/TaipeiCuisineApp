import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/Model/Order.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/Payment/ConfirmationPage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

// ----------------------------------------------------------------
// Payment Functionality
// ----------------------------------------------------------------

class PaymentBloc with ChangeNotifier {
  //options and general variables
  String _paymentMethod = '';
  String _idempotencyKey = Uuid().v4();
  String _orderNumber = '';
  String _uid = '';
  int _total = 0;
  bool _sameAsDelivery = false;
  bool _saveCard = false;
  List<Order> _currentOrder = [];

  int get total => _total;
  String get orderNumber => _orderNumber;
  String get paymentMethod => _paymentMethod;
  bool get sameAsDelivery => _sameAsDelivery;
  bool get saveCard => _saveCard;
  List<Order> get currentOrder => _currentOrder;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // =======================================
  //billing details
  // =======================================
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phoneNumber;
  String _street = '';
  String _city = '';
  String _zip;
  String _cofId = '';
  String _customerId = '';
  String _brand = '';
  String _lastFourDigit = '';

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get street => _street;
  String get city => _city;
  String get zip => _zip;
  String get cofId => _cofId;
  String get customerId => _customerId;
  String get lastFourDigit => _lastFourDigit;

  // =======================================
  // Methods
  // =======================================

  void getPaymentMethod(String type) {
    _paymentMethod = type;
    notifyListeners();
  }

  void showAddressInput(bool value) {
    _sameAsDelivery = value;
    notifyListeners();
  }

  void checkSaveCard(bool value) {
    _saveCard = value;
    notifyListeners();
  }

  void resetPaymentMethod() {
    _sameAsDelivery = false;
    _paymentMethod = '';
    notifyListeners();
  }

  // =======================================
  // Billing related
  // =======================================

  //get the values from the form and save it to the variables in the provider
  void saveBillingInfo({first, last, email, phone, street, city, zip}) async {
    _firstName = first;
    _lastName = last;
    _email = email;
    _phoneNumber = phone;
    _street = street;
    _city = city;
    _zip = zip;

    notifyListeners();
  }

//   get the total and format it to cents for square
  void getTotal(String total) {
    _total = (double.parse(total) * 100).toInt();
  }

  // retrieve billing info from database
  retrieveBillingInfo(uid) async {
    _uid = uid;

    await Firestore.instance
        .collection('users/$uid/billings')
        .document('details')
        .get()
        .then((value) {
      var v = value.data;
      if (value.data != null) {
        _firstName = v['firstName'] == null ? '' : v['firstName'];
        _lastName = v['lastName'] == null ? '' : v['lastName'];
        _email = v['email'] == null ? '' : v['email'];
        _phoneNumber = v['phone'] == null ? '' : v['phone'];
        _street = v['street'] == null ? '' : v['street'];
        _city = v['city'] == null ? '' : v['city'];
        _zip = v['zip'] == null ? '' : v['zip'];
        _brand = v['brand'] == null ? '' : v['brand'];
        _lastFourDigit = v['lastFourDigit'] == null ? '' : v['lastFourDigit'];
        _customerId = v['customerId'] == null ? '' : v['customerId'];
        _cofId = v['cofId'] == null ? '' : v['cofId'];
      }
    });
    return;
  }

  // ===========================================
  //  Square Payment Methods
  // ===========================================

  // if the customer wants to save the card on file make a request to Square endpoint
  // createCustomer() method will create the customer and return the customer_id upon completion

  String customerEndPoint = 'https://connect.squareupsandbox.com/v2/customers';
  String paymentEndPoint = 'https://connect.squareupsandbox.com/v2/payments';
  Map<String, String> headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization":
        "Bearer EAAAECrURINgpXaOtJARN8yucdgjdZancyd3MhoMQQkqeFnICsnYtLIq_4kk8FOS",
  };

  void payment(CartBloc cartBloc, FunctionalBloc functionalBloc, total) async {
    int amount = (total / 100).toInt();

    var contact = Contact((b) => b
      ..givenName = "$_firstName"
      ..familyName = "$_lastName"
      ..addressLines = ListBuilder(['$_street'])
      ..city = "$_city"
      ..countryCode = "USA"
      ..email = "$_email"
      ..phone = "$_phoneNumber"
      ..postalCode = "$_zip");

    await InAppPayments.setSquareApplicationId(
        'sandbox-sq0idb-OaWeqv8Fp9so8TD1y_UmCA');

    await InAppPayments.startCardEntryFlowWithBuyerVerification(
        onBuyerVerificationSuccess: (BuyerVerificationDetails result) async {
          Get.close(2);
          functionalBloc.toggleLoading();
          await chargeCard(result, cartBloc, functionalBloc);
          functionalBloc.toggleLoading();

          Get.off(Confirmation());
        },
        onBuyerVerificationFailure: (ErrorInfo errorInfo) {
          print('errorinfo $errorInfo');
        },
        buyerAction: 'Charge',
        money: Money((b) => b
          ..amount = amount
          ..currencyCode = 'USD'),
        contact: contact,
        squareLocationId: 'XBKSBRXWASMMT',
        collectPostalCode: true,
        onCardEntryCancel: () {});
  }

  // create a customer with square, this will generate an customer id
  Future<dynamic> createCustomer() async {
    try {
      var response = await http.post(customerEndPoint,
          headers: headers,
          body: jsonEncode({
            "idempotency_key": '$_idempotencyKey',
            "given_name": _firstName,
            "family_name": _lastName,
            "email_address": _email,
            "phone_number": _phoneNumber,
            "address": {
              "address_line_1": '$_street',
              "address_line_2": '',
              'locality': '$_city',
              'administrative_district_level_1': 'MA',
              'postal_code': '$_zip',
              'country': 'US'
            }
          }));
      _customerId = jsonDecode(response.body)['customer']['id'];
      // returns the customer id required for saving card
      return _customerId;
    } catch (error) {
      Get.snackbar(error.code, error.message);
    }
  }

  // save the card to the customer file
  Future<dynamic> saveCardOnFile(BuyerVerificationDetails result, FunctionalBloc functionalBloc) async {
    String customerId = _customerId == '' ? await createCustomer() : _customerId;

    // make a request to the endpoint to save the card to Square Api
    String url =
        'https://connect.squareupsandbox.com/v2/customers/$customerId/cards';

      try{
        var response = await http.post(url,
            headers: headers,
            body: jsonEncode({
              'card_nonce': '${result.nonce}',
              'cardholder_name': '$firstName $lastName',
              'billing_address': {
                'postal_code': '${result.card.postalCode}',
                'country': 'US'
              },
            }));

        var data = jsonDecode(response.body);
        // if the response does not return an error
        if(data['errors'] != null){
          _errorMessage = data['errors'][0]['category'];
        } else {
          //save the data to the variable
          _cofId = data['card']['id'];
          _brand = data['card']['card_brand'];
          _lastFourDigit = data['card']['last_4'];

          return data['card']['id'];
        }
      } catch(error){
        _errorMessage = 'Failed to save card information to Square.';
      }

  }

//   Charge the card for the  first time, if the user decide not to save card,
//   nonce will be use to make an one time charge to the user
  chargeCard(
      BuyerVerificationDetails result,
      CartBloc bloc,
      FunctionalBloc functionalBloc) async {
    String id = saveCard ? await saveCardOnFile(result, functionalBloc) : result.nonce;

   try{
     var response = await http.post(
       paymentEndPoint,
       headers: headers,
       body: jsonEncode({
         "idempotency_key": _idempotencyKey,
         "autocomplete": true,
         "amount_money": {
           "amount": _total,
           "currency": "USD",
         },
         "customer_id": _customerId,
         "source_id": id,
       }),
     );
     String status = jsonDecode(response.body)['payment']['status'];

     if(jsonDecode(response.body)['errors'] != null){
       // savedCard allow the customer to save the card information for express checkout in the future
       if (saveCard && status == 'COMPLETED') {
         await Firestore.instance
             .collection('users/$_uid/billings')
             .document('details')
             .setData({
           "firstName": _firstName,
           "lastName": _lastName,
           "email": _email,
           "phone": _phoneNumber,
           "street": _street,
           "city": _city,
           "zip": _zip,
           "customerId": _customerId,
           "cofId": _cofId,
           "brand": _brand,
           "lastFourDigit": _lastFourDigit,
         }, merge: true);
       }

       // handles the reward point and order
       if (status == 'COMPLETED') {
         manageRewardPoint(
             point: bloc.rewardPoint,
             total: double.parse(bloc.total),
             orderNumber: jsonDecode(response.body)['payment']['order_id'],
             percentage: 5,
             method: 'Card'
         );

         sendOrderToDb(
             orderId: jsonDecode(response.body)['payment']['order_id'],
             items: bloc.items,
             deliveryAddress: bloc.isDelivery ? '$_street, $_city, MA, $_zip' : '',
             delivery: bloc.isDelivery,
             subtotal: bloc.subtotal,
             tax: bloc.tax,
             deliveryFee: bloc.deliveryFee,
             tip: bloc.tip,
             total: _total,
             count: bloc.cartItemTotal,
             idKey: _idempotencyKey,
             pointEarned: _pointEarned,
             pointUsed: bloc.rewardPoint,
             method: 'Card');
       }

       _orderNumber = jsonDecode(response.body)['payment']['order_id'];
       return jsonDecode(response.body)['payment']['order_id'];
     } else {
       _errorMessage = jsonDecode(response.body)['errors'][0]['category'];
       return _errorMessage;
     }
   } catch(error){
     _errorMessage = 'Failed to charge card, try again later.';
   }


  }

  //charge the card on file with square
  chargeCardOnFile(CartBloc bloc) async {
    try{
      // make http request to Square payment for Card on file
      var response = await http.post(
        paymentEndPoint,
        headers: headers,
        body: jsonEncode({
          "idempotency_key": _idempotencyKey,
          "autocomplete": true,
          "amount_money": {
            "amount": _total,
            "currency": "USD",
          },
          "customer_id": _customerId,
          "source_id": _cofId,
        }),
      );
      var data = jsonDecode(response.body);


      if(data['errors'] == null){
        manageRewardPoint(
            point: bloc.rewardPoint,
            total: double.parse(bloc.total),
            orderNumber: jsonDecode(response.body)['payment']['order_id'],
            percentage: 5,
            method: 'Card'
        );

        _orderNumber = data['payment']['order_id'];
        // make an order and place it to the database
        sendOrderToDb(
            orderId: data['payment']['order_id'],
            items: bloc.items,
            deliveryAddress: bloc.isDelivery ? '$_street, $_city, MA, $_zip' : '',
            delivery: bloc.isDelivery,
            subtotal: bloc.subtotal,
            tax: bloc.tax,
            deliveryFee: bloc.deliveryFee,
            tip: bloc.tip,
            total: _total,
            count: bloc.cartItemTotal,
            idKey: _idempotencyKey,
            pointEarned: _pointEarned,
            pointUsed: bloc.rewardPoint,
            method: 'Card');

        return data['payment']['order_id'];
      } else {
        _errorMessage = data['errors'][0]['category'];
      }
    } catch(error){
      _errorMessage = 'Failed to charge card on file. Try again later';}
  }

  chargeCash(CartBloc bloc) {
    _orderNumber = Uuid().v4();
    manageRewardPoint(
      point: bloc.rewardPoint,
      total: double.parse(bloc.total),
      orderNumber: _orderNumber,
      percentage: 10,
      method: 'Cash'
    );

    try{
      sendOrderToDb(
        orderId: _orderNumber,
        items: bloc.items,
        deliveryAddress: bloc.isDelivery ? '$_street, $_city, MA, $_zip' : '',
        delivery: bloc.isDelivery,
        subtotal: bloc.subtotal,
        tax: bloc.tax,
        deliveryFee: bloc.deliveryFee,
        tip: bloc.tip,
        total: _total,
        count: bloc.cartItemTotal,
        method: 'Cash',
        pointEarned: _pointEarned,
        pointUsed: bloc.rewardPoint,
      );
    } catch(e){
      _errorMessage = 'Failed to send order to restaurant, try again later';
    }


  }

  void manageRewardPoint({int point, double total, String orderNumber, int percentage, method}){
    if(point > 0){
      calculateRewardPoint(
        action: 'subtract',
        orderId: orderNumber,
        ptUsed: point,
        total: total,
        percentage: 0,
      );
    }

    calculateRewardPoint(
      action: 'add',
      percentage: percentage,
      total: total,
      method: method,
      orderId: orderNumber,
    );
  }

  //send the order to the database
  void sendOrderToDb({
    orderId,
    items,
    deliveryAddress,
    delivery,
    subtotal,
    tax,
    deliveryFee,
    tip,
    total,
    method,
    count,
    idKey,
    pointEarned,
    pointUsed
  }) async {
    List<Map> listOfItems = [];

    for (var item in items) {
      var map = {
        'foodId': item.product.foodId,
        'foodName': item.product.foodName,
        'price': item.product.price,
        'count': item.count,
      };
      listOfItems.add(map);
    }

    await Firestore.instance
        .collection('users/$_uid/order')
        .document('$orderId')
        .setData({
      "orderId": orderId,
      "items": listOfItems,
      "deliveryAddress": deliveryAddress,
      'delivery': delivery,
      "subtotal": subtotal,
      "tax": tax,
      "deliveryFee": deliveryFee,
      "tip": tip,
      "total": total,
      "method": method,
      "status": 'Placed',
      "totalCount": count,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "idempodency_key": idKey,
      "pointEarned": pointEarned,
      "pointUsed": pointUsed,
    }, merge: true);
  }

  //Rewards point
  int _rewardPoint = 0;
  int _pointEarned = 0;
  var _pointDetail = [];

  int get rewardPoint => _rewardPoint;
  int get pointEarned => _pointEarned;


  retrieveRewardPoints(uid) async {
    await Firestore.instance
        .collection('users/$uid/rewards')
        .document('points')
        .get()
        .then((value) {
          if(value.exists){
            _rewardPoint = value.data['point'];
            _pointDetail = value.data['pointDetails'];
          }
    });

    return;
  }

  void calculateRewardPoint({String action, int percentage, double total, String method, orderId, ptUsed}) async {
    //action can either be add or subtract
    //depending on the action, we can decide to subtract the point or add the point
    _pointEarned = (total * percentage).toInt().round();

    action == 'add' ? _rewardPoint +=_pointEarned : _rewardPoint -= ptUsed;

    Map<String, dynamic> detail = {
      'action': action,
      'amount': action == 'add' ? _pointEarned : ptUsed,
      'method': action == 'add' ? method : '',
      'orderId': orderId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    _pointDetail.insert(0, detail);

    await Firestore.instance.collection('users/$_uid/rewards').document('points').setData({
      'point': _rewardPoint,
      'pointDetails': _pointDetail
    }, merge: true);
  }


  void clearErrorMessage(){
    _errorMessage = '';
    notifyListeners();
  }

  //clear value after checkout
  void clearAfterCheckout() {
    _paymentMethod = '';
    _idempotencyKey = Uuid().v4();
    _orderNumber = '';
    _total = 0;
    _sameAsDelivery = false;
    _saveCard = false;
    _pointEarned = 0;
    _rewardPoint = 0;
    _pointDetail = [];
  }
}
