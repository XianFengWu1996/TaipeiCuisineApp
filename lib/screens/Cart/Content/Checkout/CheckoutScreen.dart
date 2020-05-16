import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutChoice.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutSummary.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/OrderList.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/Address.dart';
import 'package:food_ordering_app/components/Chips.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/Payment/PaymentModal.dart';
import 'package:food_ordering_app/screens/Home.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  static const id = 'check_out';

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
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
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 25),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              //Chip to choose pick up or delivery
              CheckoutChoice(),

              LineDivider(),

              //Cards for selecting the address and payments
              AddressCard(),

              cartBloc.isDelivery ? LineDivider() : Container(),
              // The list of cart items
              OrderList(cartBloc: cartBloc),

              LineDivider(),
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

                                    if(point >= (double.parse(cartBloc.total) * 100)){
                                      cartBloc.useRewardPoint((double.parse(cartBloc.total) * 100).toInt());
                                    } else {
                                      cartBloc.useRewardPoint(point);
                                    }
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

              LineDivider(),

              // Chips for selecting the amount of tips
              TipSelection(),

              LineDivider(),

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
      ),
    );
  }
}
