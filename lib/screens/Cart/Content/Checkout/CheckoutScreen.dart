import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/components/CheckoutComponents/PageComponents/CheckoutChoice.dart';
import 'package:food_ordering_app/components/CheckoutComponents/PageComponents/CheckoutSummary.dart';
import 'package:food_ordering_app/components/CheckoutComponents/PageComponents/OrderList.dart';
import 'package:food_ordering_app/components/CheckoutComponents/PageComponents/Address.dart';
import 'package:food_ordering_app/components/CheckoutComponents/Parts/Chips.dart';
import 'package:food_ordering_app/components/CheckoutComponents/Parts/CheckoutDivider.dart';
import 'package:food_ordering_app/components/Payment/PaymentModal.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  static const id = 'check_out';

  @override
  Widget build(BuildContext context) {
    var cartBloc = Provider.of<CartBloc>(context);
    var paymentBloc = Provider.of<PaymentBloc>(context);
    TextEditingController _pointController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Home.id);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 25),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            //Chip to choose pick up or delivery
            CheckoutChoice(),

            CheckoutDivider(),

            //Cards for selecting the address and payments
            AddressCard(),

            cartBloc.isDelivery ? CheckoutDivider() : Container(),
            // The list of cart items
            OrderList(cartBloc: cartBloc),

            CheckoutDivider(),
            //Select the amount of reward point for redemption
            Column(
              children: <Widget>[
                Text('Point Available: ${paymentBloc.rewardPoint}'),
                Container(
                  width: 250,
                  child: TextFormField(
                    controller: _pointController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: '100 pts = \$1',
                        contentPadding: EdgeInsets.all(5.0),
                        suffixIcon: IconButton(
                            icon: Icon(
                              FontAwesome.check_circle_o,
                              size: 30,
                            ),
                            onPressed: () {
                              if (_pointController.text != '') {
                                int point = int.parse(_pointController.text);
                                if (point <= paymentBloc.rewardPoint) {
                                  cartBloc.useRewardPoint(point);
                                } else {

                                }
                              }
                              FocusScope.of(context).requestFocus(FocusNode());
                            }),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          width: 1,
                        ))),
                  ),
                ),
                cartBloc.rewardPoint > 0 ? Text('Point Remaining: ${paymentBloc.rewardPoint - cartBloc.rewardPoint}') : Container(),
              ],
            ),

            CheckoutDivider(),

            // Chips for selecting the amount of tips
            TipSelection(),

            CheckoutDivider(),

            //Summary of the order
            CheckoutSummary(),

            FlatButton(
              child: Text('Proceed To Payment'),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 13),
              textColor: Colors.white,
              onPressed: () {
                paymentBloc.getTotal(cartBloc.total);
                showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (context) {
                      return PaymentModal();
                    });
              },
              color: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }
}
