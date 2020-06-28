import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/Model/Product.dart';
import 'package:provider/provider.dart';

class CartCard extends StatelessWidget {
  CartCard({this.index, this.item});

  final Product item;
  final int index;

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Card(
      child: ListTile(
        leading: Text('${item.foodId}.'),
        title: Text('${functionalBloc.selectedValue == 'enlgish' ? item.foodName : item.foodChineseName}'),
        subtitle: Text('\$${item.price}'),
        trailing: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  cartBloc.updateQuantity('remove', item.foodId, );
                },
              ),
              Text('${cartBloc.items[index].count}', style: TextStyle(fontSize: 18),),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  cartBloc.updateQuantity('add', item.foodId);
                },
              ),

            ],
          ),
        )



      ),
    );
  }
}