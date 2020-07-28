import 'package:TaipeiCuisine/components/Chips/PaymentChip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/components/BottomSheet/BottomSheet.dart';
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
            title: '${functionalBloc.selectedLanguage == 'english' ? 'Payment Methods' : '付款方式'}',
            subtitle: '${functionalBloc.selectedLanguage == 'english' ? 'Total: \$' : '总额:\$'}${cartBloc.total.toStringAsFixed(2)}',
            onPressed: (){
              Get.close(1);
              paymentBloc.setValue('resetPaymentMethod', false);
            },
          ),
          ListView(
            shrinkWrap: true,
            children: [
              PaymentChip(
                title: functionalBloc.selectedLanguage == 'english' ? 'Cash' : '现金',
                icon: FontAwesome.money,
                rewardPercent: 'Earn ${functionalBloc.cashReward}%',
                selected: paymentBloc.paymentMethod == 'cash',
                onSelected: (value) {
                  paymentBloc.setValue('getPaymentMethod','cash');
                },
              ),
              functionalBloc.billingCofId != ''
                  ? PaymentChip(
                title: functionalBloc.selectedLanguage == 'english' ? 'xx-${functionalBloc.billingLastFourDigit}' : '尾号 xx-${functionalBloc.billingLastFourDigit}',
                subtitle: 'Powered by Square',
                icon: FontAwesome.credit_card,
                rewardPercent: 'Earn ${functionalBloc.cardReward}%',
                selected: paymentBloc.paymentMethod == 'saved',
                onSelected: (value) {
                  paymentBloc.setValue('getPaymentMethod','saved');
                },
              ) : Container(),
              PaymentChip(
                title: functionalBloc.selectedLanguage == 'english' ? 'Add Credit / Debit Card' : '添加新的信用卡',
                subtitle: 'Powered by Square',
                icon: FontAwesome.plus,
                rewardPercent: 'Earn ${functionalBloc.cardReward}%',
                selected: paymentBloc.paymentMethod == 'card',
                onSelected: (value) {
                  paymentBloc.setValue('getPaymentMethod','card');
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
                                functionalBloc.setValue('loading','start');
                                await paymentBloc.retrieveUnprocessed();
                                await paymentBloc.chargeCardOnFile(cartBloc, functionalBloc);
                                functionalBloc.setValue('loading','reset');

                                if(paymentBloc.errorMessage != ''){
                                  Get.defaultDialog(
                                      title: 'Unexpected Error',
                                      content: Text(paymentBloc.errorMessage),
                                      confirm: FlatButton(onPressed: (){
                                        paymentBloc.setValue('resetErrMsg', '');
                                        Get.back();
                                        print(paymentBloc.errorMessage);
                                      }, child: Text('Okay'))
                                  );
                                } else {
                                  Get.off(Confirmation());
                                }
                              }

                              if(paymentBloc.paymentMethod == 'card'){
                                await paymentBloc.retrieveUnprocessed();
                              }

                              if (paymentBloc.paymentMethod == 'cash') {
                                await paymentBloc.chargeCash(cartBloc: cartBloc, functionalBloc: functionalBloc
                                );

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
                            text: '${functionalBloc.selectedLanguage == 'english' ? 'Send to Kitchen': '发送订单到餐厅' }',
                          )
                        ],
                      );
                    });
              } else {
                Get.snackbar('${functionalBloc.selectedLanguage == 'english' ? 'Select your payment method' : '选择您的付款方式'}','',
                    backgroundColor: Colors.orange, colorText: Colors.white);
              }

            },
            child: Text(
              '${functionalBloc.selectedLanguage == 'english' ? 'Place Order' : '下单'}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            padding: EdgeInsets.only(top: 20, bottom: 15),
            color: Colors.red[400],
          )

        ]
    );
  }
}
