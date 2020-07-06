import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoreBloc extends ChangeNotifier{

  FirebaseUser _user;

  FirebaseUser get user => _user;

  saveLocalUser(user){
    _user = user;
    notifyListeners();
  }

  orderConfirmed(orderId)async{
    await Firestore.instance.collection('order/${DateTime.now().year}/${DateTime.now().month}')
        .document('$orderId').setData({
      'status': 'Completed'
    }, merge: true);
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
  double _reportTotal = 0;

  double get reportSubtotal => _reportSubtotal;
  double get reportDiscount => _reportDiscount;
  double get reportTax => _reportTax;
  double get reportTip => _reportTip;
  double get reportTotal => _reportTotal;

  getTotalReports() async {
    _reportSubtotal = 0;
    _reportDiscount = 0;
    _reportTax = 0;
    _reportTip = 0;
    _reportTotal = 0;
    await Firestore.instance.collection('order/$_yearDropdown/${int.parse(_monthDropdown) + 1}').orderBy('createdAt', descending: true).getDocuments().then((value) {
      _reportSnapshot = value.documents;

      value.documents.forEach((element) {
        _reportSubtotal += (element.data['subtotal'] - element.data['lunchDiscount']);
        _reportDiscount += (element.data['pointUsed']);
        _reportTax += element.data['tax'];
        _reportTip += element.data['tip'];
        _reportTotal += element.data['total'];
      });
    });
    notifyListeners();
  }

  changeValue(type , value){
    switch(type){
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
    notifyListeners();
  }

  cancelOrder(){

  }


//  requestRefund({idKey, amount, paymentId}) async{
//    var response = await http.post(
//      'https://connect.squareup.com/v2/refunds',
//      headers: {
//        "Accept": "application/json",
//        "Content-Type": "application/json",
//        "Authorization": 'Bearer ',
//      },
//      body: jsonEncode({
//        'idempotency_key': idKey,
//        'amount_money': amount,
//        'payment_id': paymentId
//      }),
//    );
//    print(response.body);
//  }


}