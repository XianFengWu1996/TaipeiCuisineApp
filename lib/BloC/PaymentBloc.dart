import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/Model/Order.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/Payment/ConfirmationPage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';
import 'dart:convert';

// ----------------------------------------------------------------
// Payment Functionality
// ----------------------------------------------------------------

class PaymentBloc with ChangeNotifier {
  //Get user information from firebase once logged in
  FirebaseUser _user;

  //options and general variables
  String _paymentMethod = '';
  String _idempotencyKey = randomAlphaNumeric(18);
  String _orderNumber = '';
  int _total = 0;
  bool _sameAsDelivery = true;
  bool _saveCard = false;
  List<Order> _currentOrder = [];
  String _comments = '';

  int get total => _total;
  String get orderNumber => _orderNumber;
  String get paymentMethod => _paymentMethod;
  bool get sameAsDelivery => _sameAsDelivery;
  bool get saveCard => _saveCard;
  List<Order> get currentOrder => _currentOrder;
  String get comments => _comments;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // =======================================
  // Checkout Page Related Methods
  // =======================================

  saveCustomerInfo({firstName, lastName, phone, FunctionalBloc functionalBloc}) async {
    try{
      functionalBloc.setValue('customerInfo', {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'verifiedNumbers': phone
      });

      await Firestore.instance.collection('users/${_user.uid}/customer_information').document('details').setData({
        'customer': {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'verifiedNumbers': functionalBloc.verifiedNumbers
        }
      }, merge: true);
      notifyListeners();
    } catch(e){
      Get.snackbar('Error', 'An unexpected error has occurred, try restarting the app.', colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  // ===========================================
  //  Square Payment Methods
  // ===========================================

  // if the customer wants to save the card on file make a request to Square endpoint
  // createCustomer() method will create the customer and return the customer_id upon completion

  String _token = '';
  String _appId = '';
  String _locationId = '';

  String customerEndPoint = 'https://connect.squareupsandbox.com/v2/customers';
  String paymentEndPoint = 'https://connect.squareupsandbox.com/v2/payments';

  void payment(CartBloc cartBloc, FunctionalBloc functionalBloc, total) async {
    int amount = (total / 100).toInt();

    var contact = Contact((b) => b
      ..givenName = "${functionalBloc.billingFirstName}"
      ..familyName = "${functionalBloc.billingLastName}"
      ..addressLines = ListBuilder(['${functionalBloc.billingStreet}'])
      ..city = "${functionalBloc.billingCity}"
      ..countryCode = "USA"
      ..email = "${_user.email != null ? _user.email : _user.providerData[0].email}"
      ..phone = "${functionalBloc.billingPhone}"
      ..postalCode = "${functionalBloc.billingZip}");

    await InAppPayments.setSquareApplicationId(
        '$_appId');

    await InAppPayments.startCardEntryFlowWithBuyerVerification(
        onBuyerVerificationSuccess: (BuyerVerificationDetails result) async {
          Get.close(2);
          functionalBloc.setValue('loading','start');
          await chargeCard(result, cartBloc, functionalBloc);
          functionalBloc.setValue('loading','reset');

          Get.off(Confirmation());
        },
        onBuyerVerificationFailure: (ErrorInfo errorInfo) {
          Get.snackbar('${errorInfo.code}', '${errorInfo.message}', backgroundColor: Colors.red, colorText: Colors.white);
        },
        buyerAction: 'Charge',
        money: Money((b) => b
          ..amount = amount
          ..currencyCode = 'USD'),
        contact: contact,
        squareLocationId: '$_locationId',
        collectPostalCode: true,
        onCardEntryCancel: () {});
  }

  // create a customer with square, this will generate an customer id
  Future<dynamic> createCustomer(FunctionalBloc functionalBloc) async {
    try {
      var response = await http.post(customerEndPoint,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization":
            "Bearer $_token",
          },
          body: jsonEncode({
            "idempotency_key": '$_idempotencyKey',
            "given_name": functionalBloc.billingFirstName,
            "family_name": functionalBloc.billingLastName,
            "email_address": '${_user.email != null ? _user.email : _user.providerData[0].email}',
            "phone_number": functionalBloc.billingPhone,
            "address": {
              "address_line_1": '${functionalBloc.billingStreet}',
              "address_line_2": '',
              'locality': '${functionalBloc.billingCity}',
              'postal_code': '${functionalBloc.billingZip}',
              'country': 'US'
            }
          }));
      // returns the customer id required for saving card
      functionalBloc.setValue('customerId', jsonDecode(response.body)['customer']['id']);
      return jsonDecode(response.body)['customer']['id'];
    } catch (error) {
      Get.snackbar(error.code, error.message);
    }
  }

  // save the card to the customer file
  Future<dynamic> saveCardOnFile(BuyerVerificationDetails result, FunctionalBloc functionalBloc) async {
    String customerId = functionalBloc.billingCustomerId == '' ? await createCustomer(functionalBloc) : functionalBloc.billingCustomerId;

    // make a request to the endpoint to save the card to Square Api
    String url =
        'https://connect.squareupsandbox.com/v2/customers/$customerId/cards';

      try{
        var response = await http.post(url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization":
              "Bearer $_token",
            },
            body: jsonEncode({
              'card_nonce': '${result.nonce}',
              'cardholder_name': '${functionalBloc.billingFirstName} ${functionalBloc.billingLastName}',
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
          functionalBloc.setValue('card_info', {
            'cofId': data['card']['id'],
            'brand' : data['card']['card_brand'],
            'lastFourDigit' : data['card']['last_4'],
          });

          return data['card']['id'];
        }
      } catch(error){
        _errorMessage = 'Failed to save card information to Square.';
      }

  }

//   Charge the card for the  first time, if the user decide not to save card,
//   nonce will be use to make an one time charge to the user
  chargeCard(BuyerVerificationDetails result, CartBloc cartBloc, FunctionalBloc functionalBloc) async {
    String id = saveCard ? await saveCardOnFile(result, functionalBloc) : result.nonce;

   try{
     var response = await http.post(
       paymentEndPoint,
       headers: {
         "Accept": "application/json",
         "Content-Type": "application/json",
         "Authorization":
         "Bearer $_token",
       },
       body: jsonEncode({
         "idempotency_key": _idempotencyKey,
         "autocomplete": true,
         "amount_money": {
           "amount": _total,
           "currency": "USD",
         },
         "customer_id": functionalBloc.billingCustomerId,
         "source_id": id,
       }),
     );
     String status = jsonDecode(response.body)['payment']['status'];

     _orderNumber = jsonDecode(response.body)['payment']['order_id'];

     if(jsonDecode(response.body)['errors'] == null){
       // savedCard allow the customer to save the card information for express checkout in the future
       if (saveCard && status == 'COMPLETED') {
         await Firestore.instance
             .collection('users/${_user.uid}/customer_information').document('details').setData({
          'billing': {
            "firstName": functionalBloc.billingFirstName,
            "lastName": functionalBloc.billingLastName,
            "phone": functionalBloc.billingPhone,
            "street": functionalBloc.billingStreet,
            "city": functionalBloc.billingCity,
            "zip": functionalBloc.billingZip,
            "customerId": functionalBloc.billingCustomerId,
            "cofId": functionalBloc.billingCofId,
            "brand": functionalBloc.billingBrand,
            "lastFourDigit": functionalBloc.billingLastFourDigit,
          }}, merge: true);}

       // handles the reward point and order
       if (status == 'COMPLETED') {
         manageRewardPoint(
             point: cartBloc.rewardPoint,
             total: cartBloc.total,
             orderNumber: jsonDecode(response.body)['payment']['order_id'],
             percentage: functionalBloc.cardReward,
             method: 'Card'
         );

         sendOrderToDb(
             orderId: _orderNumber,
             items: cartBloc.items,
             deliveryAddress: cartBloc.isDelivery ? '${functionalBloc.deliveryStreet}, ${functionalBloc.deliveryCity}, MA, ${functionalBloc.deliveryZipCode}' : '',
             delivery: cartBloc.isDelivery,
             subtotal: cartBloc.subtotal,
             calcSubtotal: cartBloc.calcSubtotal,
             lunchDiscount: cartBloc.lunchDiscount,
             tax: cartBloc.tax,
             deliveryFee: functionalBloc.deliveryFee,
             tip: cartBloc.tip,
             total: _total,
             count: cartBloc.cartItemTotal,
             idKey: _idempotencyKey,
             pointEarned: _pointEarned,
             pointUsed: cartBloc.rewardPoint,
             customerName: functionalBloc.customerFirstName + ' ' + functionalBloc.customerLastName,
             customerPhone: functionalBloc.customerPhoneNumber,
             customerComment: _comments,
             paymentId: jsonDecode(response.body)['payment']['id'],
             method: 'Card');
       }
     } else {
       _errorMessage = jsonDecode(response.body)['errors'][0]['category'];
       return _errorMessage;
     }
   } catch(error){
     _errorMessage = 'Failed to charge card, try again later.';
   }
  }

  //charge the card on file with square
  chargeCardOnFile(CartBloc cartBloc, FunctionalBloc functionalBloc) async {
    try{
      // make http request to Square payment for Card on file
      var response = await http.post(
        paymentEndPoint,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization":
          "Bearer $_token",
        },
        body: jsonEncode({
          "idempotency_key": _idempotencyKey,
          "autocomplete": true,
          "amount_money": {
            "amount": _total,
            "currency": "USD",
          },
          "customer_id": functionalBloc.billingCustomerId,
          "source_id": functionalBloc.billingCofId,
        }),
      );
      var data = jsonDecode(response.body);


      if(data['errors'] == null){
        manageRewardPoint(
            point: cartBloc.rewardPoint,
            total: cartBloc.total,
            orderNumber: jsonDecode(response.body)['payment']['order_id'],
            percentage: functionalBloc.cardReward,
            method: 'Card'
        );

        _orderNumber = data['payment']['order_id'];
        // make an order and place it to the database
        sendOrderToDb(
            orderId: data['payment']['order_id'],
            items: cartBloc.items,
            deliveryAddress: cartBloc.isDelivery ? '${functionalBloc.deliveryStreet}, ${functionalBloc.deliveryCity}, MA, ${functionalBloc.deliveryZipCode}' : '',
            delivery: cartBloc.isDelivery,
            subtotal: cartBloc.subtotal,
            calcSubtotal: cartBloc.calcSubtotal,
            lunchDiscount: cartBloc.lunchDiscount,
            tax: cartBloc.tax,
            deliveryFee: functionalBloc.deliveryFee,
            tip: cartBloc.tip,
            total: _total,
            count: cartBloc.cartItemTotal,
            idKey: _idempotencyKey,
            pointEarned: _pointEarned,
            pointUsed: cartBloc.rewardPoint,
            customerName:  functionalBloc.customerFirstName + ' ' + functionalBloc.customerLastName,
            customerPhone: functionalBloc.customerPhoneNumber,
            customerComment: _comments,
            paymentId: data['payment']['id'],
            method: 'Card');

      } else {
        _errorMessage = data['errors'][0]['category'];
      }
    } catch(error){
      _errorMessage = 'Failed to charge card on file. Try again later';}
  }

  chargeCash({CartBloc cartBloc, FunctionalBloc functionalBloc}) {
    _orderNumber = randomAlphaNumeric(18);
    manageRewardPoint(
      point: cartBloc.rewardPoint,
      total: cartBloc.total,
      orderNumber: _orderNumber,
      percentage: functionalBloc.cashReward,
      method: 'Cash'
    );

    try{
      sendOrderToDb(
        orderId: _orderNumber,
        items: cartBloc.items,
        deliveryAddress: cartBloc.isDelivery ? '${functionalBloc.deliveryStreet}, ${functionalBloc.deliveryCity}, MA, ${functionalBloc.deliveryZipCode}' : '',
        delivery: cartBloc.isDelivery,
        subtotal: cartBloc.subtotal,
        calcSubtotal: cartBloc.calcSubtotal,
        lunchDiscount: cartBloc.lunchDiscount,
        tax: cartBloc.tax,
        deliveryFee: functionalBloc.deliveryFee,
        tip: cartBloc.tip,
        total: _total,
        count: cartBloc.cartItemTotal,
        method: 'Cash',
        pointEarned: _pointEarned,
        pointUsed: cartBloc.rewardPoint,
        customerName: functionalBloc.customerFirstName + ' ' + functionalBloc.customerLastName,
        customerPhone: functionalBloc.customerPhoneNumber,
        customerComment: _comments,
        paymentId: ''
      );
    } catch(e){
      _errorMessage = 'Failed to send order to restaurant, try again later';
    }
  }

  // ===========================================
  //  Reward Point Related
  // ===========================================

  int _rewardPoint = 0;
  int _pointEarned = 0;
  var _pointDetail = [];

  int get rewardPoint => _rewardPoint;
  int get pointEarned => _pointEarned;

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

  retrieveRewardPoints() async {
    try{
      await Firestore.instance
          .collection('users/${_user.uid}/rewards')
          .document('points')
          .get()
          .then((value) {
        if(value.exists){
          _rewardPoint = value.data['point'];
          _pointDetail = value.data['pointDetails'];
        }
      });
    }catch(e){
      Get.snackbar('Error', 'Failed to retrieve reward points', backgroundColor: Colors.red, colorText: Colors.white);
    }

  }

  void calculateRewardPoint({String action, int percentage, double total, String method, orderId, ptUsed}) async {
    //action can either be add or subtract
    //depending on the action, we can decide to subtract the point or add the point
    _pointEarned = (total * percentage).ceilToDouble().toInt();

    action == 'add' ? _rewardPoint +=_pointEarned : _rewardPoint -= ptUsed;

    Map<String, dynamic> detail = {
      'action': action,
      'amount': action == 'add' ? _pointEarned : ptUsed,
      'method': action == 'add' ? method : '',
      'orderId': orderId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    _pointDetail.insert(0, detail);

    try{
      await Firestore.instance.collection('users/${_user.uid}/rewards').document('points').setData({
        'point': _rewardPoint,
        'pointDetails': _pointDetail
      }, merge: true);
    } catch(e){
      Get.snackbar('Error', 'Failed to save reward points', backgroundColor: Colors.red, colorText: Colors.white);
    }

  }

  // ===========================================
  //  Other
  // ===========================================
  //send the order to the database
  void sendOrderToDb({
    orderId, items, deliveryAddress, delivery, subtotal, calcSubtotal, tax, deliveryFee, tip, total,
    method, count, idKey, pointEarned, pointUsed, customerName, customerPhone, customerComment,
    paymentId, lunchDiscount
  }) async {
    List<Map> listOfItems = [];

    for (var item in items) {
      var map = {
        'foodId': item.product.foodId,
        'foodName': item.product.foodName,
        'foodChineseName': item.product.foodChineseName,
        'price': item.product.price,
        'count': item.count,
      };
      listOfItems.add(map);
    }

    await Firestore.instance
        .collection('users/${_user.uid}/order')
        .document('$orderId')
        .setData({
      "orderId": orderId,
      "items": listOfItems,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerComments': customerComment,
      "deliveryAddress": deliveryAddress,
      'delivery': delivery,
      "subtotal": subtotal,
      "calcSubtotal": calcSubtotal,
      "lunchDiscount": lunchDiscount,
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



    await Firestore.instance
        .collection('order')
        .document('${DateTime.now().year}')
        .collection('${DateTime.now().month}')
         .document('$orderId')
        .setData({
      "orderId": orderId,
      "items": listOfItems,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerComments': customerComment,
      "deliveryAddress": deliveryAddress,
      'delivery': delivery,
      "subtotal": subtotal,
      "calcSubtotal": calcSubtotal,
      "lunchDiscount": lunchDiscount,
      "tax": tax,
      "deliveryFee": deliveryFee,
      "tip": tip,
      "total": total,
      "method": method,
      "status": 'Placed',
      "totalCount": count,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "month": DateTime.now().month + 1,
      "year": DateTime.now().year,
      "idempodency_key": idKey,
      "pointEarned": pointEarned,
      "pointUsed": pointUsed,
      'paymentId': paymentId,
      'userId': _user.uid,
    }, merge: true);
  }

  //clear value after checkout
  void clearAfterCheckout() {
    _paymentMethod = '';
    _comments = '';
    _idempotencyKey = randomAlphaNumeric(18);
    _orderNumber = '';
    _total = 0;
    _sameAsDelivery = false;
    _saveCard = false;
    _pointEarned = 0;
    _pointDetail = [];
  }

  clearAllValueUponLogout(){
    _user = null;
    _paymentMethod = '';
    _idempotencyKey = randomAlphaNumeric(18);
    _orderNumber = '';
    _total = 0;
    _sameAsDelivery = false;
    _saveCard = false;
    _currentOrder = [];
    _comments = '';
    _errorMessage = '';
    _rewardPoint = 0;
    _pointEarned = 0;
    _pointDetail = [];
    _appId = '';
    _token = '';
    _locationId = '';
    notifyListeners();
  }

  setValue(String type, dynamic value){
    switch(type){
      case 'saveUser':
        _user = value;
        break;
      case 'getPaymentMethod':
        _paymentMethod = value;
        break;
      case 'resetPaymentMethod':
        _sameAsDelivery = value;
        _paymentMethod = '';
        break;
      case 'sameAsDelivery':
        _sameAsDelivery = value;
        break;
      case 'saveCard':
        _saveCard = value;
        break;
      case 'getTotal':
        // get the total and format it to cents for square
        _total = (value * 100).toInt();
        break;
      case 'getComments':
        _comments = value;
        break;
      case 'resetErrMsg':
        _errorMessage = value;
        break;
      case 'getKey':
        _token = value['token'];
        _appId = value['appId'];
        _locationId = value['locationId'];
        break;
      default:
        return;
    }
    notifyListeners();
  }
}
