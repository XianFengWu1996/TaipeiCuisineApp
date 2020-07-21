import 'package:TaipeiCuisine/components/Chips/TipChip.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/Payment/PaymentPage.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/Comments.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutChoice.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutSummary.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/OrderList.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/Address.dart';
import 'package:TaipeiCuisine/components/Divider/Divider.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/Payment/PaymentModal.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/PersonInfo.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/Reward.dart';
import 'package:TaipeiCuisine/screens/Home.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${functionalBloc.selectedLanguage == 'english' ? 'Checkout' : '结账 / 付款'}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Get.offAll(Home());
            },
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ModalProgressHUD(
          inAsyncCall: functionalBloc.loading,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                //Chip to choose pick up or delivery
                CheckoutChoice(),

                LineDivider(),

                //Cards for selecting the address and payments
                AddressCard(),

                PersonInfo(),

                LineDivider(),
                // The list of cart items
                OrderList(),

                LineDivider(),
                //Select the amount of reward point for redemption
                RewardInput(),

                LineDivider(),

                // Chips for selecting the amount of tips
                TipSelection(),

                LineDivider(),

                //Button for adding comments
                Comments(),

                LineDivider(),
                //Summary of the order
                CheckoutSummary(),

                FlatButton(
                  child: Text(
                      '${functionalBloc.selectedLanguage == 'english' ? 'Proceed To Payment' : '选择付款方式'}'),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                  textColor: Colors.white,
                  onPressed: () {
                    paymentBloc.setValue('sameAsDelivery', functionalBloc.deliveryAddress != '' ? true : false);
                    if (TimeOfDay.now().hour * 60 + TimeOfDay.now().minute >=
                            functionalBloc.storeOpen &&
                        TimeOfDay.now().hour * 60 + TimeOfDay.now().minute <=
                            functionalBloc.storeClose) {
                      if (cartBloc.isDelivery) {
                        if (functionalBloc.deliveryAddress != '') {
                          if (functionalBloc.customerLastName != '' || functionalBloc.customerFirstName != '' || functionalBloc.customerPhoneNumber != '') {
                            if (cartBloc.tipPercent != 0.0 || cartBloc.tipPercent == .0000000001 || cartBloc.tipPercent == 0.0000001) {
                              paymentBloc.setValue('getTotal', cartBloc.total);
                              MediaQuery.of(context).size.height > 812 ? Get.bottomSheet(PaymentModal(), backgroundColor: Colors.white) : Get.to(PaymentPage());
                            } else {
                              Get.snackbar(
                                  functionalBloc.selectedLanguage == 'english'
                                      ? 'Missing Tip for driver'
                                      : '未选择司机的小费',
                                  functionalBloc.selectedLanguage == 'english'
                                      ? 'Please select tip for the driver, if you wish to pay in cash, select Cash.'
                                      : '请选择给予司机的小费，如果你想选择给现金小费，选择现金',
                                  backgroundColor: Colors.orange[300],
                                  colorText: Colors.white);
                            }
                          } else {
                            Get.snackbar(
                                functionalBloc.selectedLanguage == 'english'
                                    ? 'Missing Information'
                                    : '未填写个人信息',
                                functionalBloc.selectedLanguage == 'english'
                                    ? 'Please fillout the missing information. (Name, phone, or both)'
                                    : '请填写您完整个人信息（姓名，电话，或者 姓名和电话）',
                                backgroundColor: Colors.orange[300],
                                colorText: Colors.white);
                          }
                        } else {
                          Get.snackbar(
                              functionalBloc.selectedLanguage == 'english'
                                  ? 'Missing Address'
                                  : '未填写地址',
                              functionalBloc.selectedLanguage == 'english'
                                  ? 'Missing delivery address, please provide your delivery address.'
                                  : '未填写送餐地址，请填写您想送餐的地址',
                              backgroundColor: Colors.orange[300],
                              colorText: Colors.white);
                        }
                      } else {
                        // Check list for pick up
                        if (functionalBloc.customerLastName != '' ||
                            functionalBloc.customerFirstName != '' ||
                            functionalBloc.customerPhoneNumber != '') {
                          paymentBloc.setValue('getTotal', cartBloc.total);
                          MediaQuery.of(context).size.height > 812
                              ? Get.bottomSheet(PaymentModal(),
                                  backgroundColor: Colors.white)
                              : Get.to(PaymentPage());
                        } else {
                          Get.snackbar(
                              functionalBloc.selectedLanguage == 'english'
                                  ? 'Missing Information'
                                  : '未填写个人信息',
                              functionalBloc.selectedLanguage == 'english'
                                  ? 'Please fill out the missing information. (Name, phone, or both)'
                                  : '请填写您完整个人信息（姓名，电话，或者 姓名和电话）',
                              backgroundColor: Colors.orange[300],
                              colorText: Colors.white);
                        }
                      }
                    }else {
                      Get.snackbar('Sorry we are closed', 'The operating hours are from 11am - ${
                      functionalBloc.storeClose / 60}: ${functionalBloc.storeClose % 60}pm',
                          backgroundColor: Colors.orange, colorText: Colors.white);
                    }
                  },
                  color: Colors.red[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
