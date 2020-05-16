import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Order/components/OrderStream.dart';

class OrderCompleted extends StatelessWidget {
  final String uid;
  OrderCompleted({this.uid});

  @override
  Widget build(BuildContext context) {
    return OrderStream(
      uid: uid,
      status: 'Completed',
      emptyStatus: 'No past order',
    );
  }
}
