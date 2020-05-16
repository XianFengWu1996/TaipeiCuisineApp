import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/Chips.dart';
import 'package:food_ordering_app/components/Payment/ConfirmationPage.dart';
import 'package:food_ordering_app/components/Payment/PaymentForm.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class PaymentModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cartBloc = Provider.of<CartBloc>(context);
    var paymentBloc = Provider.of<PaymentBloc>(context);

    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                height: 85,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                          paymentBloc.resetPaymentMethod();
                        }),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Choose Payment Method',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Total: \$${cartBloc.total}',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(''),
                    Text(''),
                  ],
                )),
            Column(
              children: <Widget>[
                PaymentSelectionChip(
                  title: 'Cash',
                  icon: FontAwesome.money,
                  selected: paymentBloc.paymentMethod == 'cash',
                  onSelected: (value) {
                    paymentBloc.getPaymentMethod('cash');
                  },
                ),
                paymentBloc.cofId != ''
                    ? PaymentSelectionChip(
                        title: 'xx-${paymentBloc.lastFourDigit}',
                        icon: FontAwesome.credit_card,
                        selected: paymentBloc.paymentMethod == 'saved',
                        onSelected: (value) {
                          paymentBloc.getPaymentMethod('saved');
                        },
                      )
                    : Container(),
                PaymentSelectionChip(
                  title: 'Add card ',
                  icon: FontAwesome.plus,
                  selected: paymentBloc.paymentMethod == 'card',
                  onSelected: (value) {
                    paymentBloc.getPaymentMethod('card');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PaymentForm();
                    }));
                  },
                ),
              ],
            ),
            FlatButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        backgroundColor: Color(0x00000000),
                        children: <Widget>[
                          ConfirmationSlider(onConfirmation: () async {
                            if (paymentBloc.paymentMethod == 'saved') {
                              await paymentBloc.chargeCardOnFile(cartBloc);
                            }

                            if (paymentBloc.paymentMethod == 'cash') {
                              paymentBloc.chargeCash(cartBloc);
                            }
                            Get.off(Confirmation());
                          },
                          foregroundColor: Colors.red[400],
                            text: 'Send to Kitchen',
                          )
                        ],
                      );
                    });
              },
              child: Text(
                'Place Order',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              padding: EdgeInsets.only(top: 20, bottom: 20),
              color: Colors.red[400],
            )
          ]),
    );
  }
}
