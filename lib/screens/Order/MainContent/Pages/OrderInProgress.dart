import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Order/components/OrderStream.dart';

class OrderInProgress extends StatelessWidget {
  final String uid;
  OrderInProgress({this.uid});

  @override
  Widget build(BuildContext context) {
    return OrderStream(
      uid: uid,
      status: 'Placed',
      emptyStatus: 'No order is placed',
    );

  }
}
