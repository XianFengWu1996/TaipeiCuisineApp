import 'package:flutter/material.dart';

class OrderBloc with ChangeNotifier{
  String _orderStatus = 'inProgress';

  String get orderStatus => _orderStatus;

  changeStatus(String status){
    _orderStatus = status;
    notifyListeners();
  }
}