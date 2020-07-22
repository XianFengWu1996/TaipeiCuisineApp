import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/CheckoutScreen.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/CartCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
                      child: CartCard(
                        index: index,
                        item: item,
                      ),
                    );
                  })
              : Center(
                  child: Text(
                      '${functionalBloc.selectedLanguage == 'english' ? 'Empty Cart' : '您的购物车还是空的'}')),
        ),
        Row(
          children: [
            Expanded(
                child: FlatButton(
              color: Colors.red[400],
              child: Text(
                '${functionalBloc.selectedLanguage == 'english' ? 'Checkout' : '结账'}   \$${cartBloc.subtotal.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              padding: MediaQuery.of(context).size.height > 812
                  ? EdgeInsets.all(19.5)
                  : EdgeInsets.all(16.8),
              onPressed: () async {
                if (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute >= functionalBloc.storeOpen && TimeOfDay.now().hour * 60 + TimeOfDay.now().minute <= functionalBloc.storeClose) {
                  if (cartBloc.items.isNotEmpty) {
                    if (cartBloc.subtotal < 15) {
                      cartBloc.setValue('checkChoice', 'pickup');
                    }
                    await paymentBloc.retrieveRewardPoints();

                    await cartBloc.calculateLunchDiscount(
                        functionalBloc.lunchStart, functionalBloc.lunchEnds);

                    Get.to(CheckoutScreen());
                  } else {
                    Get.snackbar(
                        '${functionalBloc.selectedLanguage == 'english' ? 'Add dishes to cart before checkout' : '结账前请添加你想购买的菜品'}',
                        '',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.red);
                  }
                } else {
                  Get.snackbar('Sorry we are closed',
                      'The operating hours are from 11:00 - ${(functionalBloc.storeClose ~/ 60)}: ${(functionalBloc.storeClose % 60)}',
                      backgroundColor: Colors.orange, colorText: Colors.white);
                }
              },
            )),
            VerticalDivider(
              width: 3,
            ),
            FlatButton(
              child: Icon(
                FontAwesome.trash,
                color: Colors.white,
              ),
              padding: MediaQuery.of(context).size.height > 812
                  ? EdgeInsets.all(18)
                  : EdgeInsets.all(16.8),
              color: Colors.red[400],
              onPressed: () {
                cartBloc.clearCart();
              },
            ),
          ],
        ),
      ],
    );
  }
}
