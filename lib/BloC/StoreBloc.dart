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
    await Firestore.instance.collection('order').document('$orderId').setData({
      'status': 'Completed'
    }, merge: true);
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
//        "Authorization": 'Bearer EAAAECrURINgpXaOtJARN8yucdgjdZancyd3MhoMQQkqeFnICsnYtLIq_4kk8FOS',
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