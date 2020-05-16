import 'package:flutter/cupertino.dart';

class Order {
  final String orderId;
  final List items;
  final int createdAt;
  final String deliveryAddress;
  final String subtotal;
  final String tax;
  final String deliveryFee;
  final String tip;
  final String total;
  final String methods;
  final bool completed;

  Order({
    @required this.orderId,
    @required this.items,
    @required this.createdAt,
    @required this.deliveryAddress,
    @required this.subtotal,
    @required this.tax,
    @required this.deliveryFee,
    @required this.tip,
    @required this.total,
    @required this.methods,
    this.completed = false,
  });
}
