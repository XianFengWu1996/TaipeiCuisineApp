import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Order/components/OrderStream.dart';

class OrderCanncelled extends StatelessWidget {
  final String uid;
  OrderCanncelled({this.uid});

  @override
  Widget build(BuildContext context) {
    return OrderStream(
      uid: uid,
      status: 'Cancelled',
      emptyStatus: 'No cancelled order',
    );
  }
}
