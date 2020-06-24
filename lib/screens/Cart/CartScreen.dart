import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/components/CartContent.dart';
import 'package:food_ordering_app/screens/Home.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const id = 'cart_screen';

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: functionalBloc.selectedValue == 'english' ? Text('Cart') : Text('购物车'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.home), onPressed: (){
            Get.offAll(Home());
          },)
        ],
      ),
      body: CartContent(),
    );
  }
}
