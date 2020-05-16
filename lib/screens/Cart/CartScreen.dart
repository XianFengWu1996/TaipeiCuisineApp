import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Home.dart';
import 'package:food_ordering_app/screens/Cart/Content/CartContent.dart';

class CartScreen extends StatelessWidget {
  static const id = 'cart_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.home), onPressed: (){
            Navigator.pushReplacementNamed(context, Home.id);
          },)
        ],
      ),
      body: CartContent(),
    );
  }
}
