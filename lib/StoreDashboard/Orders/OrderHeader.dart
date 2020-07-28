import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderConstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';

class OrderHeader extends StatelessWidget {
  final data;

  OrderHeader({this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: data['delivery']
          ? ListTile(
        title: Text(
          'Delivery',
          style: heading,
        ),
        subtitle: Text(
            '${data['method'] == 'Card' ? 'Prepaid with Credit Card' : 'Cash'}', style: heading),
        leading: Icon(FontAwesome.car, size: 40,),
        trailing: IconButton(icon: Icon(Icons.close, size: 40,),
            onPressed: () {
              Get.back();
            }),
      )
          : ListTile(
        title: Text('Pickup', style: heading,),
        subtitle: Text('${data['method'] == 'Card' ? 'Prepaid with Credit Card' : 'Cash'}', style: subtitle),
        leading: Icon(FontAwesome.shopping_bag, size: 40,),
        trailing: IconButton(icon: Icon(Icons.close, size: 40),
            onPressed: () {
              Get.back();
            }),
      ),
    );
  }
}
