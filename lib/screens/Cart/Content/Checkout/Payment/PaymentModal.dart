import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/components/BottomSheet.dart';
import 'package:food_ordering_app/components/Chips.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/CheckoutScreen.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/Payment/ConfirmationPage.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/Payment/PaymentForm.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class PaymentModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BottomSheetHeader(
              title: 'Choose Payment Method',
              subtitle: cartBloc.total,
              onPressed: (){
                Navigator.pop(context);
                paymentBloc.resetPaymentMethod();
              },
            ),
            Column(
              children: <Widget>[
                SelectionChip(
                  title: 'Cash',
                  icon: FontAwesome.money,
                  selected: paymentBloc.paymentMethod == 'cash',
                  onSelected: (value) {
                    paymentBloc.getPaymentMethod('cash');
                  },
                ),
                paymentBloc.cofId != ''
                    ? SelectionChip(
                        title: 'xx-${paymentBloc.lastFourDigit}',
                        icon: FontAwesome.credit_card,
                        selected: paymentBloc.paymentMethod == 'saved',
                        onSelected: (value) {
                          paymentBloc.getPaymentMethod('saved');
                        },
                      )
                    : Container(),
                SelectionChip(
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
                          ConfirmationSlider(
                            onConfirmation: () async {
                              if (paymentBloc.paymentMethod == 'saved') {
                                Get.close(2);
                                functionalBloc.toggleLoading();
                                await paymentBloc.chargeCardOnFile(cartBloc);
                                functionalBloc.toggleLoading();

                                if(paymentBloc.errorMessage != ''){
                                  Get.defaultDialog(
                                    title: 'Unexpected Error',
                                    content: Text(paymentBloc.errorMessage),
                                    confirm: FlatButton(onPressed: (){
                                      paymentBloc.clearErrorMessage();
                                      Get.back();
                                      print(paymentBloc.errorMessage);
                                    }, child: Text('Okay'))
                                  );
                                } else {
                                  Get.off(Confirmation());
                                }
                              }

                              if (paymentBloc.paymentMethod == 'cash') {
                                await paymentBloc.chargeCash(cartBloc);

                                if(paymentBloc.errorMessage != ''){
                                  Get.defaultDialog(
                                    title: 'Unexpected Error',
                                    content: Text(paymentBloc.errorMessage),
                                    confirm: FlatButton(onPressed: (){},
                                        child: Text('Okay'))
                                  );
                                } else {
                                  Get.off(Confirmation());
                                }

                              }
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
