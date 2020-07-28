import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderConstant.dart';
import 'package:flutter/material.dart';

class StoreOrderList extends StatelessWidget {

  StoreOrderList({this.foodItems});

  final foodItems;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: foodItems.length > 4
          ? MediaQuery.of(context).size.height - 450
          : 350,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: foodItems.length,
          itemBuilder: (context, i) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]),
              ),
              child: ListTile(
                leading: Text(
                  'x${foodItems[i]['count']}',
                  style: dishMain,
                ),
                title: Text(
                  '${foodItems[i]['foodId']} . ${foodItems[i]['foodChineseName']}',
                  style: dishMain,
                ),
                subtitle: Text(
                  '${foodItems[i]['foodName']}',
                  style: dishSub,
                ),
                trailing: Text(
                  '\$${foodItems[i]['price'].toStringAsFixed(2)}',
                  style: dishMain,
                ),
              ),
            );
          }),
    );
  }
}
