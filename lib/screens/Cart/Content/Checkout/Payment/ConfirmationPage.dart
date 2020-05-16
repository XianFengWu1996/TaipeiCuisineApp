import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/components/Buttons/Rectangular.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutSummary.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/OrderList.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Home.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Confirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc funcBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Confirmation'),
          leading: Text(''),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Order Confirmation',
                    style: TextStyle(fontSize: 30),
                  ),
                  LineDivider(),
                  Text('Order# ${paymentBloc.orderNumber}'),
                  Text('${cartBloc.isDelivery ? 'Delivery' : 'Pickup'}'),
                  cartBloc.isDelivery ?
                    Text('${cartBloc.street}, ${cartBloc.apt == '' ? '' : '${cartBloc.apt},'} ${cartBloc.city}, ${cartBloc.zipCode}')
                    : Container(),
                  LineDivider(),
                  cartBloc.businessName != ''
                      ? Text(cartBloc.businessName)
                      : Container(),
                  Text('Estimate time for ${cartBloc.isDelivery ? 'delivery' : 'pickup'} '
                      'is about ${cartBloc.isDelivery ? '45-60min' : '15-20min'}'),
                  Text('(Larger orders might take 10-15min more to prepare)'),
                  LineDivider(),
                  OrderList(cartBloc: cartBloc),
                  LineDivider(),
                  CheckoutSummary(),
                  Center(
                    child: RectangularLogin(
                      onPressed: () {
                        funcBloc.changeTab(2);
                        paymentBloc.clearAfterCheckout();
                        cartBloc.clearValueUponCheckout();
                        Get.offAll(Home());
                      },
                      title: 'Return to Home',
                      color: Colors.red[400],
                      vertical: 10,
                      horizontal: 15,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
