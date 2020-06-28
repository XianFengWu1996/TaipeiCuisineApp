import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:provider/provider.dart';



class OrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Container(
      height: 350,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: cartBloc.items.length,
        itemBuilder: (context, index) {
          var item = cartBloc.items[index];
          return Card(
            child: ListTile(
              title: Text(
                  '${item.product.foodId}. '
                    '${functionalBloc.selectedValue == 'english'
                      ? item.product.foodName
                      : item.product.foodChineseName
                  }'),
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
