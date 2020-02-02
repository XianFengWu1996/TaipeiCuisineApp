import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';

class CartContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var bloc = Provider.of<CartBloc>(context);

    return Consumer<CartBloc>(
        builder:(context, cart, child){
          return ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index){
                var item = cart.items[index].product;
                return Card(
                  child: ListTile(
                    title: Text('${item.foodName}'),
                    subtitle: FlatButton(
                      child: Icon(FontAwesome.minus_circle),
                      onPressed: (){
                        cart.updateQuantity('remove', item.foodId);
                      },
                    ),
                    trailing: Text('${cart.items[index].count}'),
                    leading:
                    FlatButton(
                      child: Icon(FontAwesome.plus_circle),
                      onPressed: (){
                        cart.updateQuantity('add', item.foodId);
                      },
                    ),
                  ),
                );
              }
          );

        }
    );


  }
}


