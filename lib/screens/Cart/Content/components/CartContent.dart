import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/CheckoutScreen.dart';
import 'package:food_ordering_app/screens/Cart/Content/components/CartCard.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

class CartContent extends StatelessWidget {
  static const id = 'cart_screen';

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: cartBloc.items.length > 0
              ? ListView.builder(
              itemCount: cartBloc.items.length,
              itemBuilder: (context, index) {
                var item = cartBloc.items[index].product;
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Remove',
                      color: Colors.red[400],
                      icon: FontAwesome.trash,
                      onTap: () {
                        cartBloc.deleteItem(item.foodId,
                            cartBloc.items[index].count, item.price);
                      },
                    ),
                  ],
                  child: CartCard(index: index, item: item,),
                );
              })
              : Center(child: Text('${functionalBloc.selectedValue == 'english' ? 'Empty Cart' : '您的购物车还是空的'}')),
        ),
        Container(
          height: 200,
          child: Column(
            children: <Widget>[
              functionalBloc.selectedValue == 'english' ? Text('Subtotal: \$${cartBloc.subtotal.toStringAsFixed(2)}') : Text('税前总额: \$${cartBloc.subtotal.toStringAsFixed(2)}'),
              FlatButton(
                color: Colors.red[400],
                onPressed: () async {
                  if(TimeOfDay.now().hour * 60 + TimeOfDay.now().minute >= 660 && TimeOfDay.now().hour * 60 + TimeOfDay.now().minute <= 1310){
                    if (cartBloc.items.isNotEmpty) {
                      if (cartBloc.subtotal < 15) {
                        cartBloc.checkChoice('pickup');
                      }

                      if(cartBloc.googleIos == ''){
                        await paymentBloc.retrieveBillingInfo();
                        await paymentBloc.retrieveRewardPoints();
                        await paymentBloc.retrieveCustomerInfo();
                        await cartBloc.retrieveKeys();
                        await paymentBloc.retrieveKey();
                      }
                      cartBloc.calculateLunchDiscount();

                      Get.to(CheckoutScreen());
                    } else {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Add items to the cart before checkout'),
                          ));
                    }
                  } else {
                    Get.snackbar('Sorry we are closed', 'The operating hours are from 11am - 9:50pm', backgroundColor: Colors.orange, colorText: Colors.white);
                  }

                },
                child: Text('${functionalBloc.selectedValue == 'english' ? 'Checkout': '结账 / 付款'}', style: TextStyle(color: Colors.white),),
              ),
              FlatButton(
                color: Colors.red[400],
                onPressed: () {
                  cartBloc.clearCart();
                },
                child:
                Text('${functionalBloc.selectedValue == 'english' ? 'Clear Cart' : '清空购物车'}', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
