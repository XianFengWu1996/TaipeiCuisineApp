import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';



class OrderList extends StatelessWidget {

  OrderList({this.cartBloc});

  final CartBloc cartBloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: cartBloc.items.length,
        itemBuilder: (context, index) {
          var item = cartBloc.items[index];
          return Card(
            child: ListTile(
              title: Text(
                  '${item.product.foodId}. ${item.product.foodName}'),
              subtitle:
              Text('\$${item.product.price}    x ${item.count}'),
              trailing: Text(
                  '\$${(item.product.price * item.count).toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}
