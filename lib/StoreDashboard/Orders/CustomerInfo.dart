import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderConstant.dart';
import 'package:flutter/material.dart';

class CustomerInfo extends StatelessWidget {
  CustomerInfo({this.data});
  final data;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 15, top: 10, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '订单号： ${data['orderId']}',
            style: info,
          ),
          Text(
            '名字： ${data['customerName']}',
            style: info,
          ),
          data['delivery']
              ? Text(
            '地址： ${data['deliveryAddress']}',
            style: info,
          )
              : Container(),
          Text(
            '电话号码： ${data['customerPhone']}',
            style: info,
          ),
        ],
      ),
    );
  }
}
