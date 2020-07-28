import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class StoreBloc extends ChangeNotifier {
  FirebaseUser _user;

  FirebaseUser get user => _user;

  saveLocalUser(user) {
    _user = user;
    notifyListeners();
  }

  orderConfirmed(orderId) async {
    await Firestore.instance
        .collection('order/${DateTime.now().year}/${DateTime.now().month}')
        .document('$orderId')
        .setData({'status': 'Completed'}, merge: true);
  }

  //Report
  String _monthDropdown = '${DateTime.now().month - 1}';
  String _yearDropdown = '${DateTime.now().year}';
  String _summary = 'summary';
  String _details = 'details';
  List<DocumentSnapshot> _reportSnapshot = [];

  String get monthDropdown => _monthDropdown;
  String get yearDropdown => _yearDropdown;
  String get summary => _summary;
  String get details => _details;
  List<DocumentSnapshot> get reportSnapshot => _reportSnapshot;

  //Report Summary
  double _reportSubtotal = 0;
  double _reportDiscount = 0;
  double _reportTax = 0;
  double _reportTip = 0;
  double _reportRefund = 0;
  double _reportTotal = 0;

  double get reportSubtotal => _reportSubtotal;
  double get reportDiscount => _reportDiscount;
  double get reportTax => _reportTax;
  double get reportTip => _reportTip;
  double get reportRefund => _reportRefund;
  double get reportTotal => _reportTotal;

  getTotalReports() async {
    _reportSubtotal = 0;
    _reportDiscount = 0;
    _reportTax = 0;
    _reportTip = 0;
    _reportRefund = 0;
    _reportTotal = 0;
    await Firestore.instance
        .collection('order/$_yearDropdown/${int.parse(_monthDropdown) + 1}')
        .orderBy('createdAt', descending: true)
        .getDocuments()
        .then((value) {
      _reportSnapshot = value.documents;

      value.documents.forEach((element) {
        print(element.data['refund_amount']);

        _reportSubtotal +=
            (element.data['subtotal'] - element.data['lunchDiscount']);
        _reportDiscount += (element.data['pointUsed']);
        _reportTax += element.data['tax'];
        _reportTip += element.data['tip'];
        _reportRefund += element.data['refund_amount'];
        _reportTotal += element.data['total'];

      });

    });
    notifyListeners();
  }

  setValue(type, value) {
    switch (type) {
      case 'month':
        _monthDropdown = value;
        break;
      case 'year':
        _yearDropdown = value;
        break;
      case 'summary':
        _summary = value;
        break;
      case 'details':
        _details = value;
        break;
      default:
        return;
    }
    notifyListeners();
  }

  logout() async {
    await FirebaseAuth.instance.signOut();

    _user = null;
    _reportSubtotal = 0;
    _reportDiscount = 0;
    _reportTax = 0;
    _reportTip = 0;
    _reportTotal = 0;
    _monthDropdown = '${DateTime.now().month - 1}';
    _yearDropdown = '${DateTime.now().year}';
    _summary = 'summary';
    _details = 'details';
    notifyListeners();
  }

  completePayment({token, paymentEndpoint}) async {
    await Firestore.instance
        .collection('unprocessed')
        .document('${DateTime.now().month}${DateTime.now().day}')
        .get()
        .then((value) {
      List paymentList = value.data['paymentId'];
      paymentList.forEach((element) async {
        // make a http request to square to complete the orders
        var response = await http.post(
          '$paymentEndpoint/${element['paymentId']}/complete',
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
        );

        print(response.body);
      });
    });
  }

  cancelOrder({paymentId, token, data, reward, paymentEndpoint}) async {
    var response = await http.post(
      '$paymentEndpoint/$paymentId/cancel',
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if(data['method'] == 'Card'){
      if(jsonDecode(response.body)['payment']['status'] == 'CANCELED'){
        // set the amount that was refund to the database
        await Firestore.instance
            .collection('order/${data['year']}/${data['month']}')
            .document('${data['orderId']}')
            .setData({
          'cancel_amount': data['total'],
          'cancel': true,
          'total': 0,
        }, merge: true);

        // retrieve the current reward points of the user
        var point;
        var pointDetails = [];
        await Firestore.instance
            .collection('users/${data['userId']}/rewards')
            .document('points')
            .get()
            .then((value) {
          point = value.data['point'];
          pointDetails = value.data['pointDetails'];
        });

        // calculate the rewards needed to be subtracted
        // then save the new points to the database
        var newPoint =
        (point - (data['total'] * (reward / 100))).ceilToDouble().toInt();
        pointDetails.insert(0, {
          'action': 'subtract',
          'amount': (data['total'] * (reward / 100)).ceilToDouble().toInt(),
          'createdAt': Timestamp.now().millisecondsSinceEpoch,
          'orderId': data['orderId'],
          'method': 'card',
          'refund': false,
          'cancel': true,
        });

        await Firestore.instance
            .collection('users/${data['userId']}/rewards')
            .document('points')
            .setData({
          'point': newPoint,
          'pointDetails': pointDetails,
        }, merge: true);

        await Firestore.instance
            .collection('users/${data['userId']}/order')
            .document('${data['orderId']}')
            .setData({
          'cancel_amount': data['total'],
          'cancel': true,
          'total': 0,
        }, merge: true);
      }
    }

    if(data['method'] == 'Cash') {
      // set the amount that was refund to the database
      await Firestore.instance
          .collection('order/${data['year']}/${data['month']}')
          .document('${data['orderId']}')
          .setData({
        'cancel_amount': data['total'],
        'cancel': true,
        'total': 0,
      }, merge: true);

      // retrieve the current reward points of the user
      var point;
      var pointDetails = [];
      await Firestore.instance
          .collection('users/${data['userId']}/rewards')
          .document('points')
          .get()
          .then((value) {
        point = value.data['point'];
        pointDetails = value.data['pointDetails'];
      });

      // calculate the rewards needed to be subtracted
      // then save the new points to the database
      var newPoint =
      (point - (data['total'] * (reward / 100))).ceilToDouble().toInt();
      pointDetails.insert(0, {
        'action': 'subtract',
        'amount': (data['total'] * (reward / 100)).ceilToDouble().toInt(),
        'createdAt': Timestamp.now().millisecondsSinceEpoch,
        'orderId': data['orderId'],
        'method': 'card',
        'refund': false,
        'cancel': true,
      });

      await Firestore.instance
          .collection('users/${data['userId']}/rewards')
          .document('points')
          .setData({
        'point': newPoint,
        'pointDetails': pointDetails,
      }, merge: true);

      await Firestore.instance
          .collection('users/${data['userId']}/order')
          .document('${data['orderId']}')
          .setData({
        'cancel_amount': data['total'],
        'cancel': true,
        'total': 0,
      }, merge: true);
    }

  }

  requestRefund({data, token, amount, reward, refundEndpoint}) async {
    try {
      if (data['method'] == 'Card') {
        // make a request to square refund endpoint for the refund amount
        await http.post(
          '$refundEndpoint',
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: jsonEncode({
            'idempotency_key': data['idempodency_key'],
            "amount_money": {"amount": amount, "currency": "USD"},
            'payment_id': data['paymentId']
          }),
        );

        // set the amount that was refund to the database
        await Firestore.instance
            .collection('order/${data['year']}/${data['month']}')
            .document('${data['orderId']}')
            .setData({
          'refund_amount': amount,
          'refund': true,
          'total': data['total'] - amount,
        }, merge: true);

        // retrieve the current reward points of the user
        var point;
        var pointDetails = [];
        await Firestore.instance
            .collection('users/${data['userId']}/rewards')
            .document('points')
            .get()
            .then((value) {
          point = value.data['point'];
          pointDetails = value.data['pointDetails'];
        });

        // calculate the rewards needed to be subtracted
        // then save the new points to the database
        var newPoint =
            (point - (amount * (reward / 100))).ceilToDouble().toInt();
        pointDetails.insert(0, {
          'action': 'subtract',
          'amount': (amount * (reward / 100)).ceilToDouble().toInt(),
          'createdAt': Timestamp.now().millisecondsSinceEpoch,
          'orderId': data['orderId'],
          'method': 'card',
          'refund': true,
          'cancel': false,
        });

        await Firestore.instance
            .collection('users/${data['userId']}/rewards')
            .document('points')
            .setData({
          'point': newPoint,
          'pointDetails': pointDetails,
        }, merge: true);

        await Firestore.instance
            .collection('users/${data['userId']}/order')
            .document('${data['orderId']}')
            .setData({
          'refund_amount': amount,
          'refund': true,
          'total': data['total'] - amount,
        }, merge: true);
      }

      if (data['method'] == 'Cash') {
        // set the amount that was refund to the database
        await Firestore.instance
            .collection('order/${data['year']}/${data['month']}')
            .document('${data['orderId']}')
            .setData({
          'refund_amount': amount,
          'refund': true,
          'total': data['total'] - amount,
        }, merge: true);

        // retrieve the current reward points of the user
        var point;
        var pointDetails = [];
        await Firestore.instance
            .collection('users/${data['userId']}/rewards')
            .document('points')
            .get()
            .then((value) {
          point = value.data['point'];
          pointDetails = value.data['pointDetails'];
        });

        // calculate the rewards needed to be subtracted
        // then save the new points to the database
        var newPoint =
            (point - (amount * (reward / 100))).ceilToDouble().toInt();
        pointDetails.insert(0, {
          'action': 'subtract',
          'amount': (amount * (reward / 100)).ceilToDouble().toInt(),
          'createdAt': Timestamp.now().millisecondsSinceEpoch,
          'orderId': data['orderId'],
          'method': 'card',
          'refund': true,
          'cancel': false,
        });

        await Firestore.instance
            .collection('users/${data['userId']}/rewards')
            .document('points')
            .setData({
          'point': newPoint,
          'pointDetails': pointDetails,
        }, merge: true);

        await Firestore.instance
            .collection('users/${data['userId']}/order')
            .document('${data['orderId']}')
            .setData({
          'refund_amount': amount,
          'refund': true,
          'total': data['total'] - amount,
        }, merge: true);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong',
          colorText: Colors.white, backgroundColor: Colors.red[400]);
    }
  }
}


//  API still in beta testing, might implement in next version
//  addCharge({token, locationId, orderId, idKey, amount}) async{
//   try{
//     var response = await http.put(
//         'https://connect.squareupsandbox.com/v2/locations/$locationId/orders/$orderId',
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": 'Bearer $token',
//         }, body: jsonEncode({
//       "idempotency_key": "$idKey",
//       "order": {
//         "location_id": 'XBKSBRXWASMMT',
//         "version": 2,
//
//       },
//     }));
//     print(response.body);
//     print(locationId);
//
//   }catch(e){
//     print(e);
//   }
//  }

//  RaisedButton(onPressed: (){
//  storeBloc.addCharge(
//    locationId: functionalBloc.squareLocationId,
//    token: functionalBloc.squareToken,
//    orderId: widget.ds[widget.index]['square_order_id'],
//    idKey: widget.ds[widget.index]['idempodency_key'],
//    amount: 500
//  );
//}, child: Text('Additional Charge'),),