import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/Model/Product.dart';
import 'package:provider/provider.dart';

class CartCard extends StatelessWidget {
  CartCard({this.index, this.item});

  final Product item;
  final int index;

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);

    return Card(
      child: ListTile(
        title: Text('${item.foodName}'),
        subtitle: FlatButton(
          child: Icon(FontAwesome.minus_circle),
          onPressed: () {
            cartBloc.updateQuantity('remove', item.foodId);
          },
        ),
        trailing: Text('${cartBloc.items[index].count}'),
        leading: FlatButton(
          child: Icon(FontAwesome.plus_circle),
          onPressed: () {
            cartBloc.updateQuantity('add', item.foodId);
          },
        ),
      ),
    );
  }
}