import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/components/BottomSheet.dart';
import 'package:TaipeiCuisine/components/Chips.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/Payment/ConfirmationPage.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/Payment/PaymentForm.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class PaymentModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BottomSheetHeader(
            title: '${functionalBloc.selectedValue == 'english' ? 'Payment Methods' : '付款方式'}',
            subtitle: '${functionalBloc.selectedValue == 'english' ? 'Total: \$' : '总额:\$'}${cartBloc.total.toStringAsFixed(2)}',
            onPressed: (){
              Get.close(1);
              paymentBloc.resetPaymentMethod();
            },
          ),
          ListView(
            shrinkWrap: true,
            children: [
              SelectionChip(
                title: functionalBloc.selectedValue == 'english' ? 'Cash' : '现金',
                icon: FontAwesome.money,
                rewardPercent: 'Earn 5%',
                selected: paymentBloc.paymentMethod == 'cash',
                onSelected: (value) {
                  paymentBloc.getPaymentMethod('cash');
                },
              ),
              paymentBloc.cofId != ''
                  ? SelectionChip(
                title: functionalBloc.selectedValue == 'english' ? 'xx-${paymentBloc.lastFourDigit}' : '尾号 xx-${paymentBloc.lastFourDigit}',
                icon: FontAwesome.credit_card,
                rewardPercent: 'Earn 2%',
                selected: paymentBloc.paymentMethod == 'saved',
                onSelected: (value) {
                  paymentBloc.getPaymentMethod('saved');
                },
              ) : Container(),
              SelectionChip(
                title: functionalBloc.selectedValue == 'english' ? 'Add Credit / Debit Card' : '添加新的信用卡',
                icon: FontAwesome.plus,
                rewardPercent: 'Earn 2%',
                selected: paymentBloc.paymentMethod == 'card',
                onSelected: (value) {
                  paymentBloc.getPaymentMethod('card');
                  Get.to(PaymentForm());
                },
              ),
            ],
          ),

          RaisedButton(
            onPressed: () {
              if(paymentBloc.paymentMethod != ''){
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
                                functionalBloc.toggleLoading('start');
                                await paymentBloc.chargeCardOnFile(cartBloc);
                                functionalBloc.toggleLoading('reset');

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
                            text: '${functionalBloc.selectedValue == 'english' ? 'Send to Kitchen': '发送订单到餐厅' }',
                          )
                        ],
                      );
                    });
              } else {
                Get.snackbar('${functionalBloc.selectedValue == 'english' ? 'Select your payment method' : '选择您的付款方式'}','',
                    backgroundColor: Colors.orange, colorText: Colors.white);
              }

            },
            child: Text(
              '${functionalBloc.selectedValue == 'english' ? 'Place Order' : '下单'}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            padding: EdgeInsets.only(top: 20, bottom: 20),
            color: Colors.red[400],
          )

        ]
    );
  }
}
